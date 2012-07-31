package NetEngine
{
	import com.greensock.TweenNano;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.getTimer;
	
	import org.osflash.signals.Signal;

	public final class NetPlug extends EventDispatcher
	{
		// Successful connection signal
		public const SocketConnectedSignal : Signal = new Signal();
		
		// The server closed the connection. Not dispatched if calling the local Disconnect
		public const SocketClosedSignal : Signal = new Signal();
		
		// Any kind of socket error. The string contains detailed information.
		public const SocketErrorSignal : Signal = new Signal(String);
		

		public function AddClient(client : Object) : void
		{
			if (mClientList.indexOf(client) != -1)
				throw new Error("AddClient: Duplicated");
			
			mClientList.push(client);	
		}
		
		public function RemoveClient(client : Object) : void
		{
			if (mClientList.indexOf(client) == -1)
				throw new Error("RemoveClient: Unknown client");

			if (mPendingReturns != null)
			{
				// We forget about all the pending returns to the client we are removing
				for (var c:int=0; c < mPendingReturns.length; c++)
				{
					if ((mPendingReturns[c].Response as InvokeResponse).Client == client)
					{
						mPendingReturns.splice(c, 1);
						c--;
					}
				}
			}
			
			mClientList.splice(mClientList.indexOf(client), 1);
		}
		
		public function Connect(uri : String) : void
		{
			if (mSocket != null)
				throw new Error("Disconnect first");
			
			mNextInvokationID = 0;
			mNextMessageLength = -1;		
			mPendingReturns = new Array();
			mSocket = new Socket();
			
			mSocket.addEventListener(Event.CLOSE, OnSocketClose);
			mSocket.addEventListener(Event.CONNECT, OnSocketConnect);
			mSocket.addEventListener(IOErrorEvent.IO_ERROR, OnSocketIOError);
			mSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, OnSocketSecurityError);
			mSocket.addEventListener(ProgressEvent.SOCKET_DATA, OnSocketData);
			
			mSocket.endian = Endian.LITTLE_ENDIAN; 
			
			var serverName : String = uri.substring(0, uri.indexOf(":"));
			var port : int = parseInt(uri.substring(uri.indexOf(":") + 1));
			
			mSocket.connect(serverName, port);
		}

		public function Disconnect() : void
		{
			if (mSocket != null)
			{
				// The close event is dispatched only when the server closes the connection; 
				// it is not dispatched when you call the Socket.close() method.
				mSocket.close();
				
				// We copy the socket behaviour. If called here, we don't dispatch any event
				Destroy();
			}
		}

		private function Destroy() : void
		{
			TweenNano.killTweensOf(OnKeepAlive);
			mLastInvokeTime = -1;
			
			mSocket.removeEventListener(Event.CLOSE, OnSocketClose);
			mSocket.removeEventListener(Event.CONNECT, OnSocketConnect);
			mSocket.removeEventListener(IOErrorEvent.IO_ERROR, OnSocketIOError);
			mSocket.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, OnSocketSecurityError);
			mSocket.removeEventListener(ProgressEvent.SOCKET_DATA, OnSocketData);
			mSocket = null;
			
			mPendingReturns = null;
			mNextMessageLength = -1;
			mNextInvokationID = -1;
		}

		public function Invoke(funcName : String, response : InvokeResponse, ...args) : void
		{
			if (mSocket == null)
				throw new Error("Socket closed: " + funcName);

			var objectToSerialize : NetInvokeMessage = new NetInvokeMessage();
			objectToSerialize.InvokationID = NextInvokationID;
			objectToSerialize.ReturnID = -1;
			objectToSerialize.WantsReturn = false;
			objectToSerialize.MethodName = funcName;
			objectToSerialize.Params = args;
			
			if (response != null)
			{
				if (mClientList.indexOf(response.Client) == -1)
					throw new Error("Invoke: The response target must be our client, methodName " + funcName);
				
				objectToSerialize.WantsReturn = true;
				mPendingReturns.push(new PendingReturn(objectToSerialize.InvokationID, 
													   objectToSerialize.MethodName, response));
			}
			
			// We need to know the length in bytes beforehand
			var amfObject : ByteArray = new ByteArray();
			amfObject.endian = Endian.LITTLE_ENDIAN;
			amfObject.writeObject(objectToSerialize);

			mSocket.writeInt(amfObject.length + 4);
			mSocket.writeBytes(amfObject);
			mSocket.flush();
			
			mLastInvokeTime = getTimer();
		}
		
		
		private function OnSocketData(e:ProgressEvent):void
		{
			try
			{
				while (mSocket.bytesAvailable > 0)
				{
					if (mNextMessageLength == -1)
					{
						// If we don't have the header, we leave the bytes in the buffer for the next call and just abort the read
						if (mSocket.bytesAvailable < 4)
							break;
						
						mNextMessageLength = mSocket.readInt();
					}
					
					if (mNextMessageLength != -1)
					{
						if (mNextMessageLength <= 4)
						{
							ErrorMessages.LogToServer("OnSocketData: WTF01 " + mNextMessageLength);
							break;
						}
						
						// We don't have the complete payload -> abort and wait till next read
						if (mSocket.bytesAvailable < mNextMessageLength - 4)
							break;
						
						var availableBefore : uint = mSocket.bytesAvailable; 
						var obj : Object = mSocket.readObject();
						
						if (obj == null)
						{
							ErrorMessages.LogToServer("OnSocketData: WTF02 " + mNextMessageLength + " - " + availableBefore);
							break;	// Good night and good luck!
						}
											
						ProcessNetInvoke(obj);
						
						// Inside the func.apply there may be a reenter into OnSocketClose!!
						if (mSocket == null)
							break;
	
						var availableAfter : uint = mSocket.bytesAvailable;
						var realReaded : uint = availableBefore - availableAfter;
						
						// AMF objects have padding at the end => The readObject won't reach the end of this message.
						if (realReaded < mNextMessageLength - 4)
						{
							mSocket.readBytes(new ByteArray(), 0, mNextMessageLength - 4 - realReaded);
						}
						
						// Next message
						mNextMessageLength = -1;
					}
				}
			}
			catch(e : Error)
			{
				ErrorMessages.LogToServer("General error in OnSocketData: " + e.toString());
			}
		}
		
		private function ProcessNetInvoke(netInvoke : Object) : void
		{
			var invokationID : int = netInvoke.InvokationID;
			var returnID : int = netInvoke.ReturnID;
			var wantsReturn : Boolean = netInvoke.WantsReturn;
			var methodName : String = netInvoke.MethodName;
			var params : Array = netInvoke.Params;
						
			if (returnID != -1)
			{
				try
				{
					var pendingReturn : PendingReturn = PopPendingReturn(invokationID, methodName);
					
					// When we remove a client, all its pending returns are removed too. A server return may arrive later.
					// For example, AcceptChallenge: the match is started (and therefore room left) before the return is received.
					if (pendingReturn != null)
					{					
						// This will reenter into OnSocketClose if there's a pending close after a Read!!!!!
						(pendingReturn.Response.Callback as Function).apply(null, params);
					}
				}
				catch (e : Error)
				{
					ErrorMessages.LogToServer("NetPlug.ProcessNetInvoke RETURN: " +  methodName + " - " + e.toString());						
				}
			}
			else
			{
				try
				{
					// We look for the FIRST client that contains the method (would it be useful to invoke multiple clients?)
					var invokeClient : Object = LookForClientWithMethodName(methodName);
					
					if (invokeClient == null)
						throw new Error("Method not known among our clients");
					
					(invokeClient[methodName] as Function).apply(null, params);
				}
				catch (e : Error)
				{
					ErrorMessages.LogToServer("NetPlug.ProcessNetInvoke: " +  methodName + " - " + e.toString());						
				}
			}
		}
		
		private function LookForClientWithMethodName(methodName:String) : Object
		{
			for each(var cl : Object in mClientList)
			{
				if (cl.hasOwnProperty(methodName) && cl[methodName] is Function)
					return cl;
			}
			return null;
		}			
		
		private function PopPendingReturn(invokationID : int, methodName : String) : PendingReturn
		{
			for each(var obj : PendingReturn in mPendingReturns)
			{
				if (obj.MethodName == methodName &&	obj.InvokationID == invokationID)
				{
					mPendingReturns.splice(mPendingReturns.indexOf(obj), 1);
					return obj;
				}
			}
			return null;
		}
		
		private function OnSocketConnect(e:Event) : void
		{
			SocketConnectedSignal.dispatch();
			
			mLastInvokeTime = getTimer();
			
			TweenNano.delayedCall(KEEP_ALIVE_TIME, OnKeepAlive);
		}
		
		private function OnKeepAlive() : void
		{
			var elapsed : int = getTimer() - mLastInvokeTime;
		
			if (elapsed > KEEP_ALIVE_TIME * 1000)
			{
				mSocket.writeInt(4);
				mSocket.flush();
				
				mLastInvokeTime = getTimer();
			}
			
			TweenNano.delayedCall(KEEP_ALIVE_TIME, OnKeepAlive);
		}		
		
		private function OnSocketIOError(e:IOErrorEvent) : void
		{	
			Destroy();
			
			SocketErrorSignal.dispatch("IOErrorEvent");
		}
		
		private function OnSocketSecurityError(e:SecurityErrorEvent) : void
		{
			Destroy();
			
			SocketErrorSignal.dispatch("SecurityErrorEvent");
		}
		
		private function OnSocketClose(e:Event) : void
		{
			Destroy();
			
			SocketClosedSignal.dispatch();
		}
		
		private function get NextInvokationID() : int
		{
			return mNextInvokationID++;
		}
		
		private const KEEP_ALIVE_TIME : int = 60;	// seconds 
		
		private var mNextInvokationID : int;
		private var mPendingReturns : Array;
		private var mNextMessageLength : int = -1;
		
		private var mSocket : Socket;
		private var mClientList : Array = new Array();	// Clients aren't lost when disconnected
		
		private var mLastInvokeTime : int = -1;
	}
}

import NetEngine.InvokeResponse;

class PendingReturn
{
	public var InvokationID : int;
	public var MethodName : String;
	public var Response : InvokeResponse;
	
	public function PendingReturn(i:int, m:String, r:InvokeResponse):void
	{
		InvokationID = i;
		MethodName = m;
		Response = r;
	}
}
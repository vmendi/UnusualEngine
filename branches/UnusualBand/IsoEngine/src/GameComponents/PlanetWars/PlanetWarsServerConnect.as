package GameComponents.PlanetWars
{
	import GameComponents.GameComponent;

	import flash.events.Event;

	import it.gotoandplay.smartfoxserver.SFSEvent;
	import it.gotoandplay.smartfoxserver.SmartFoxClient;


	public final class PlanetWarsServerConnect extends GameComponent
	{
		public var AutoConnect : Boolean = true;
		public var ServerIP : String = "127.0.0.1";
		public var ServerPort : int = 9339;

		public var Zone : String = "PlanetWars";
		public var UserName : String = "Zincuntrin";
		public var UserPass : String = "";

		public function IsSelfUserID(userID:int) : Boolean { return userID == mSmartFox.myUserId; }

		override public function OnStart() : void
		{
			if (AutoConnect)
				Connect();
		}

		override public function OnStop() : void
		{
			if (mSmartFox != null && mSmartFox.isConnected)
			{
				mSmartFox.disconnect();
				RemoveListeners();
				mSmartFox = null;
			}
		}

		private function SubscribeListeners() : void
		{
			mSmartFox.addEventListener(SFSEvent.onConnection, OnConnection);
			mSmartFox.addEventListener(SFSEvent.onLogin, OnLogin);
			mSmartFox.addEventListener(SFSEvent.onRoomListUpdate, OnRoomListUpdate);

			mSmartFox.addEventListener(SFSEvent.onUserEnterRoom, ReDispatchServerEvent);
			mSmartFox.addEventListener(SFSEvent.onUserLeaveRoom, ReDispatchServerEvent);
			mSmartFox.addEventListener(SFSEvent.onJoinRoom, ReDispatchServerEvent);
			mSmartFox.addEventListener(SFSEvent.onJoinRoomError, ReDispatchServerEvent);
			mSmartFox.addEventListener(SFSEvent.onPublicMessage, ReDispatchServerEvent);
			mSmartFox.addEventListener(SFSEvent.onUserVariablesUpdate, ReDispatchServerEvent);
			mSmartFox.addEventListener(SFSEvent.onExtensionResponse, ReDispatchServerEvent);
		}

		private function RemoveListeners() : void
		{
			mSmartFox.removeEventListener(SFSEvent.onConnection, OnConnection);
			mSmartFox.removeEventListener(SFSEvent.onLogin, OnLogin);
			mSmartFox.removeEventListener(SFSEvent.onRoomListUpdate, OnRoomListUpdate);

			mSmartFox.removeEventListener(SFSEvent.onUserEnterRoom, ReDispatchServerEvent);
			mSmartFox.removeEventListener(SFSEvent.onUserLeaveRoom, ReDispatchServerEvent);
			mSmartFox.removeEventListener(SFSEvent.onJoinRoom, ReDispatchServerEvent);
			mSmartFox.removeEventListener(SFSEvent.onJoinRoomError, ReDispatchServerEvent);
			mSmartFox.removeEventListener(SFSEvent.onPublicMessage, ReDispatchServerEvent);
			mSmartFox.removeEventListener(SFSEvent.onUserVariablesUpdate, ReDispatchServerEvent);
			mSmartFox.removeEventListener(SFSEvent.onExtensionResponse, ReDispatchServerEvent);
		}

		private function ReDispatchServerEvent(event:Event) : void
		{
			dispatchEvent(event);
		}

		public function Connect() : void
		{
			mSmartFox = new SmartFoxClient();
			//mSmartFox.debug = true;

			SubscribeListeners();
			mSmartFox.connect(ServerIP, ServerPort);
		}

		private function OnRoomListUpdate(event:SFSEvent):void
		{
			trace("ServerConnect.as: Received rooms, " + event.params.roomList.length)

			if (mSmartFox.activeRoomId == -1)
				mSmartFox.joinRoom("Planet 01", "", false, false, -1);
		}

		private function OnLogin(event:SFSEvent):void
		{
			if (event.params.success as Boolean)
				trace("ServerConnect.as: Successfully logged in as " + event.params.name)
			else
				trace("ServerConnect.as: Zone login error; the following error occurred: " + event.params.error)
		}

		private function OnConnection(event:SFSEvent) : void
		{
			if (event.params.success as Boolean)
			{
				trace("ServerConnect.as: Connection successfull");
				dispatchEvent(new Event("ConnectionReady"));
                mSmartFox.login(Zone, UserName, UserPass);
	        }
	        else
	        {
	        	trace("ServerConnect.as: Can't connect!");
	        }
		}

		public function SendPublicMessage(msg:String):void
		{
			mSmartFox.sendPublicMessage(msg);
		}

		public function SetUserVariables(obj:Object):void
		{
			mSmartFox.setUserVariables(obj);
		}

		public function SendCommand(command : String, params : Object) : void
		{
			if (params == null)
				params = new Object();

			mSmartFox.sendXtMessage("PlanetWars", command, params, SmartFoxClient.XTMSG_TYPE_JSON);
		}


		private var mSmartFox : SmartFoxClient;
	}
}
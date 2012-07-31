package GameComponents.Multiplayer
{
	import GameComponents.GameComponent;

	import flash.events.Event;

	import it.gotoandplay.smartfoxserver.SFSEvent;
	import it.gotoandplay.smartfoxserver.SmartFoxClient;


	public final class ServerConnect extends GameComponent
	{
		public var AutoConnect : Boolean = true;
		public var ServerIP : String = "192.168.1.2";
		public var ServerPort : int = 9339;

		public var Zone : String = "UnusualMMO";

		public function IsSelfUserID(userID:int) : Boolean { return userID == mSmartFox.myUserId; }

		override public function OnStart() : void
		{
			if (TheGameModel.GlobalGameState.SmartFoxClient != null)
			{
				// La conexión ya nos viene de un mapa anterior
				mSmartFox = TheGameModel.GlobalGameState.SmartFoxClient;
				SubscribeListeners();

				// Nos unimos a la nueva habitación del mapa
				mSmartFox.joinRoom(ExtractFileName(TheGameModel.GameModelUrl), "", false, false, -1);
			}
			else
			if (AutoConnect)
				Connect();
		}

		override public function OnStop() : void
		{
			if (TheGameModel.TheIsoEngine.IsEditor)
			{
				if (mSmartFox != null && mSmartFox.isConnected)
				{
					mSmartFox.disconnect();
					RemoveListeners();
					mSmartFox = null;
				}
			}
			else
			{
				// Lo dejamos ahí para el siguiente GameModel
				TheGameModel.GlobalGameState.SmartFoxClient = mSmartFox;
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
				mSmartFox.joinRoom(ExtractFileName(TheGameModel.GameModelUrl), "", false, false, -1);
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
                mSmartFox.login(Zone, "", "");
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

		private function ExtractFileName(url : String) : String
		{
			var pointIdx : int = url.lastIndexOf(".");
			var slashIdx : int = url.lastIndexOf("/");

			var ret : String = "";

			if (pointIdx != -1 && slashIdx != -1)
				ret = url.substring(slashIdx+1, pointIdx);

			return ret;
		}

		private var mSmartFox : SmartFoxClient;
	}
}
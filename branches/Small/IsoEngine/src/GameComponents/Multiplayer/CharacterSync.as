package GameComponents.Multiplayer
{
	import GameComponents.Character;
	import GameComponents.GameComponent;
	
	import flash.events.Event;
	
	import it.gotoandplay.smartfoxserver.SFSEvent;
	import it.gotoandplay.smartfoxserver.data.User;
	
	import utils.GenericEvent;
	import utils.Point3;

	public final class CharacterSync extends GameComponent
	{
		public function get TheUser() : User { return mUser; }
		public function set TheUser(val:User) : void { mUser = val; }
		public function   IsTheUserSerializable() : Boolean { return false; }

		override public function OnStart() : void
		{
			mServerConnect = TheGameModel.FindGameComponentByShortName("ServerConnect") as ServerConnect;
			mCharacter = TheAssetObject.FindGameComponentByShortName("Character") as Character;

			if (!mCharacter.MouseControlled)
				TheIsoComponent.WorldPos = new Point3(mUser.getVariable("px") as Number, 0, mUser.getVariable("pz") as Number);
			else
				WriteLocalPosToUser();

			SubscribeListeners();
		}

		private function WriteLocalPosToUser() : void
		{
			var pos : Point3 = TheIsoComponent.WorldPos;			
			var obj : Object = new Object;
			obj["px"] = pos.x;
			obj["pz"] = pos.z;
			mServerConnect.SetUserVariables(obj);
		}

		override public function OnStop():void
		{
			RemoveListeners();
		}

		private function SubscribeListeners() : void
		{
			if (mCharacter.MouseControlled)
			{
				mCharacter.addEventListener("NavigationStart", OnNavigationStart);
				mCharacter.addEventListener("NavigationEnd", OnNavigationEnd);
			}
			else
			{
				mServerConnect.addEventListener(SFSEvent.onPublicMessage, OnPublicMessage);
				mServerConnect.addEventListener(SFSEvent.onUserVariablesUpdate, OnUserVariablesUpdate);
			}
		}

		private function RemoveListeners() : void
		{
			if (mCharacter.MouseControlled)
			{
				mCharacter.removeEventListener("NavigationStart", OnNavigationStart);
				mCharacter.removeEventListener("NavigationEnd", OnNavigationEnd);
			}
			else
			{
				mServerConnect.removeEventListener(SFSEvent.onPublicMessage, OnPublicMessage);
			}
		}
		
		private function OnUserVariablesUpdate(event:SFSEvent):void
		{
			if (mUser != null && mUser.getId() != event.params.user.getId())
				return;
				
			var changedVars:Array = event.params.changedVars;

		    if (changedVars["px"] != null || changedVars["pz"] != null)
		    {
		    	TheIsoComponent.WorldPos = new Point3(event.params.user.getVariable("px") as Number, 0, mUser.getVariable("pz") as Number);
		    }
		}

		private function OnNavigationStart(event:GenericEvent):void
		{
			mServerConnect.SendPublicMessage("Goto:" + (event.Data as Point3).toString());
		}

		private function OnNavigationEnd(event:Event):void
		{
			WriteLocalPosToUser();
		}

		private function OnPublicMessage(event:SFSEvent):void
		{
			var msg : String = event.params.message;

			if (mUser != null && event.params.sender.getId() == mUser.getId())
			{
				var command : String = "Goto:";

				if (msg.indexOf(command) == 0)
				{
					var vectString : String = msg.substr(command.length);
					var thePoint : Point3 = Point3.Point3FromString(vectString);
					mCharacter.NavigateTo(thePoint);
				}
			}
		}

		private var mUser : User;
		private var mCharacter : Character;
		private var mServerConnect : ServerConnect;
	}
}
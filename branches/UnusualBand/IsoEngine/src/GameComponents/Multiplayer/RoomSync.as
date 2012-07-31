package GameComponents.Multiplayer
{
	import GameComponents.Character;
	import GameComponents.GameComponent;
	import GameComponents.Interaction;

	import it.gotoandplay.smartfoxserver.SFSEvent;
	import it.gotoandplay.smartfoxserver.data.Room;
	import it.gotoandplay.smartfoxserver.data.User;

	import utils.Point3;

	public final class RoomSync extends GameComponent
	{
		override public function OnStart() : void
		{
			mServerConnect = TheGameModel.FindGameComponentByShortName("ServerConnect") as ServerConnect;
			SubscribeListeners();
		}

		private function SubscribeListeners() : void
		{
			mServerConnect.addEventListener(SFSEvent.onUserEnterRoom, OnUserEnterRoom);
			mServerConnect.addEventListener(SFSEvent.onUserLeaveRoom, OnUserLeaveRoom);
			mServerConnect.addEventListener(SFSEvent.onJoinRoom, OnJoinRoom);
			mServerConnect.addEventListener(SFSEvent.onJoinRoomError, OnJoinRoomError);
		}

		private function OnJoinRoom(event:SFSEvent):void
		{
			var joinedRoom:Room = event.params.room;

    		trace("RoomSync.as: Room " + joinedRoom.getName() + " joined successfully")

    		// El primero que creamos, nada mas unirnos a la habitación, es el character controlado por el player
			TheGameModel.CreateSceneObjectFromMovieClip("AvatarChica", "CharacterSync") as CharacterSync;

			// Y ahora el resto que ya están ahí
			var users:Array = joinedRoom.getUserList();

			for each(var user:User in users)
			{
				if (mServerConnect.IsSelfUserID(user.getId()))
					continue;

				CreateNewRemoteCharacter(user);
			}

			// Una vez que estamos en la habitación, tenemos que activar todos los componentes de juego, que vienen desactivados desde el editor
			var interacts : Array = TheGameModel.FindAllGameComponentsByShortName("Interaction");

			for each(var interaction : Interaction in interacts)
				interaction.Enabled = true;
		}


		private function CreateNewRemoteCharacter(user:User): void
		{
			var newChar : Character = TheGameModel.CreateSceneObjectFromMovieClip("AvatarChica", "Character") as Character;
			var charSync : CharacterSync = newChar.TheAssetObject.FindGameComponentByShortName("CharacterSync") as CharacterSync;

			charSync.TheUser = user;
			newChar.MouseControlled = false;
			newChar.CamFollow = false;

			mPlayersInRoom[user.getName()] = newChar;
		}

		private function OnJoinRoomError(event:SFSEvent):void
		{
			trace("RoomSync.as: Room join error; the following error occurred: " + event.params.error)
		}

		private function OnUserEnterRoom(event:SFSEvent) : void
		{
			CreateNewRemoteCharacter(event.params.user);
		}

		private function OnUserLeaveRoom(event:SFSEvent) : void
		{
			var leavingPlayer : Character = mPlayersInRoom[event.params.userName];

			TheGameModel.DeleteSceneObject(leavingPlayer.TheSceneObject);

			delete mPlayersInRoom[event.params.userName];
		}

		private var mPlayersInRoom : Object = new Object;
		private var mServerConnect : ServerConnect;
	}
}
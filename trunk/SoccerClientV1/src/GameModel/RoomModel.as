package GameModel
{
	import NetEngine.InvokeResponse;
	import NetEngine.NetPlug;
	
	import SoccerServerV1.MainService;
	import SoccerServerV1.TransferModel.vo.TeamDetails;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.Responder;
	import mx.rpc.events.ResultEvent;
	
	import utils.Delegate;

	[Bindable]
	public final class RoomModel extends EventDispatcher
	{
		public function RoomModel(conn : NetPlug, mainService : MainService, mainModel : MainGameModel)
		{
			mMainModel = mainModel;
			mMainService = mainService;
			
			mServerConnection = conn;			
			mServerConnection.AddClient(this);
			
			// Inmutables, se bindan forever
			mPlayersInRoom = new ArrayCollection();
			mReceivedChallenges = new ArrayCollection();
		}
		
		public function LogOff() : void
		{
			mServerConnection.RemoveClient(this);
		}		
		
		public  function get RoomName() : String { return mRoomName; }
		private function set RoomName(v:String) : void { mRoomName = v; }
				
		public  function get PlayersInRoom() : ArrayCollection { return mPlayersInRoom; }
		private function set PlayersInRoom(v:ArrayCollection) : void { throw "Inmutable"; }
				
		public  function get ReceivedChallenges() : ArrayCollection { return mReceivedChallenges; }
		private function set ReceivedChallenges(v:ArrayCollection) : void { throw "Inmutable"; }
		

		public function PushedRefreshPlayersInRoom(roomName : String,  players : ArrayCollection) : void
		{
			mPlayersInRoom.removeAll();
			
			for each(var player : Object in players)
			{
				mPlayersInRoom.addItem(new RealtimePlayer(player));
			}
			
			RoomName = roomName;
		}
		
		public function PushedNewPlayerJoinedTheRoom(newPlayer : Object) : void
		{
			PlayersInRoom.addItem(new RealtimePlayer(newPlayer));
		}
		
		public function PushedPlayerLeftTheRoom(leftPlayer : Object) : void
		{
			var playerInRoom : RealtimePlayer = FindPlayerInRoom(leftPlayer);
			
			if (Selected == playerInRoom)
				Selected = null;
			
			mPlayersInRoom.removeItemAt(mPlayersInRoom.getItemIndex(playerInRoom));
			
			for each(var challenge : ReceivedChallenge in mReceivedChallenges)
			{
				if (challenge.SourcePlayer == playerInRoom)
				{
					mReceivedChallenges.removeItemAt(mReceivedChallenges.getItemIndex(challenge));
					break;
				}
			}
		}
		
		public function PushedNewChallenge(fromServer : Object) : void
		{
			var newChallenge : ReceivedChallenge = new ReceivedChallenge(fromServer);
			newChallenge.SourcePlayer = FindPlayerInRoom(fromServer.SourcePlayer);
			
			if (newChallenge.SourcePlayer == null)
				throw "Challenge from player not in room";
			
			mReceivedChallenges.addItem(newChallenge);
			newChallenge.SourcePlayer.IsChallengeSource = true;
			
			if (Selected == newChallenge.SourcePlayer)
				SelectedChallenge = newChallenge;
		}
		
		// Cada vez que viene un object desde el servidor, no conserva la identidad obviamente...
		private function FindPlayerInRoom(playerFromServer : Object) : RealtimePlayer
		{
			for each(var playerInRoom : RealtimePlayer in mPlayersInRoom)
			{
				if (playerInRoom.ClientID == playerFromServer.ClientID &&
					playerInRoom.Name == playerFromServer.Name)
					return playerInRoom;
			}
			return null;
		}
		
		private function FindPlayerInRoomByID(clientID : int) : RealtimePlayer
		{
			for each(var playerInRoom : RealtimePlayer in mPlayersInRoom)
			{
				if (playerInRoom.ClientID == clientID)
					return playerInRoom;
			}
			return null;
		}
		
		public function get SelectedChallenge() : ReceivedChallenge { return mSelectedChallenge; }
		public function set SelectedChallenge(v:ReceivedChallenge) : void
		{ 
			mSelectedChallenge = v;
			
			if (mSelectedChallenge != null && Selected != mSelectedChallenge.SourcePlayer)
				Selected = mSelectedChallenge.SourcePlayer;
		}
		
		
		public function Challenge(other : RealtimePlayer, msg:String, matchLengthMinutes : int, turnLengthSeconds: int) : void
		{
			mServerConnection.Invoke("Challenge", new InvokeResponse(this, OnChallengeResponse), 
									 other.ClientID, msg, matchLengthMinutes*60, turnLengthSeconds);
		}
		
		private function OnChallengeResponse(clientID : int) : void
		{
			if (clientID != -1)
			{
				var other : RealtimePlayer = FindPlayerInRoomByID(clientID);
				if (other != null)
					other.IsChallengeTarget = true;
			}
		}
		
		public function get Selected() : RealtimePlayer { return mSelected; }
		public function set Selected(v:RealtimePlayer) : void 
		{ 
			mSelected = v;
			
			if (mSelected != null && mSelected.IsChallengeSource)
			{
				var theChallenge : ReceivedChallenge = FindChallengeOf(mSelected);
				if (SelectedChallenge != theChallenge)
					SelectedChallenge = theChallenge;
			}
			else
			{
				if (SelectedChallenge != null)
					SelectedChallenge = null;
			}

			if (mSelected != null)
			{
				// Pedimos los details del nuevo equipo seleccionado
				mMainService.RefreshTeamDetails(mSelected.FacebookID, new mx.rpc.Responder(Delegate.create(OnRefreshTeamDetailsResponded, mSelected), 
																						   ErrorMessages.Fault));
			}
		}
		
		private function OnRefreshTeamDetailsResponded(e:ResultEvent, theRealtimePlayer : RealtimePlayer) : void
		{
			theRealtimePlayer.TheTeamDetails = e.result as TeamDetails;
		}
		
		private function FindChallengeOf(player : RealtimePlayer) : ReceivedChallenge
		{
			for each(var challenge : ReceivedChallenge in mReceivedChallenges)
			{
				if (challenge.SourcePlayer == mSelected)
					return challenge;
			}
			return null;
		}
		
		
		public function AcceptSelectedChallengeMatch(callback : Function) : void
		{
			mServerConnection.Invoke("AcceptChallenge", new InvokeResponse(this, Delegate.create(OnAcceptChallengeResponded, callback)), 
									 SelectedChallenge.SourcePlayer.ClientID);
		}
		
		// Es posible que quedamos aceptar un partido que ya no existe => bSuccess = false
		// Aunque la señal de verdad es la PushedMatchStarted que se recibe fuera de la habitación
		private function OnAcceptChallengeResponded(bSuccess : Boolean, callback : Function) : void
		{
			if (callback != null)
				callback(bSuccess);
		}
		
		private var mMainService : MainService;
		private var mMainModel : MainGameModel;
		
		private var mServerConnection:NetPlug;
		
		private var mRoomName : String = "";
		private var mSelected : RealtimePlayer;
		private var mSelectedChallenge : ReceivedChallenge;
		private var mSelectedTeamDetails : TeamDetails;
		
		[ArrayElementType("ReceivedChallenge")]
		private var mReceivedChallenges : ArrayCollection;		
		
		[ArrayElementType("RealtimePlayer")] 
		private var mPlayersInRoom : ArrayCollection;
	}
}
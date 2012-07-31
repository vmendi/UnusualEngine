package GameModel
{	
	import SoccerServerV1.MainService;
	import SoccerServerV1.TransferModel.vo.SoccerPlayer;
	import SoccerServerV1.TransferModel.vo.Team;
	import SoccerServerV1.TransferModel.vo.TeamDetails;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.rpc.Responder;
	import mx.rpc.events.ResultEvent;
	
	import utils.Delegate;
 	
	public class TeamModel extends EventDispatcher
	{
		public function TeamModel(mainService : MainService, mainModel : MainGameModel)
		{
			mMainService = mainService;
			mMainModel = mainModel;
			
			// Un nuevo paradigma de exposición de datos directos desde el modelo interno hacia afuera
			// vs el antiguo de guardarnos aqui nuestra propia variable: mPlayerTeam
			BindingUtils.bindSetter(function (e:Object) : void { dispatchEvent(new Event("PlayerTeamDetailsChanged")); }, 
									mMainService.GetModel(), "RefreshSelfTeamDetailsResult");
		}

		public function HasTeam(response : Function):void
		{
			mMainService.HasTeam(new mx.rpc.Responder(Delegate.create(OnHasTeamResponse, response), ErrorMessages.Fault));
		}
		private function OnHasTeamResponse(e:ResultEvent, callback:Function):void
		{
			if (callback != null)
			{
				// Garantizamos que si tenemos equipo, estamos refrescados
				if (e.result as Boolean)
					RefreshTeam(function () : void { callback(true); });
				else
					callback(false);
			}
		}
		
		public function RefreshTeam(callback : Function) : void
		{
			mMainService.RefreshTeam(new Responder(Delegate.create(OnRefreshTeamResponse, callback), ErrorMessages.Fault));
		}
		
		public function CreateTeam(name : String, predefinedTeamID : int, success : Function, failed : Function):void
		{
			mMainService.CreateTeam(name, predefinedTeamID,
									new Responder(Delegate.create(OnTeamCreatedResponse, success, failed), ErrorMessages.Fault));	
		}
		private function OnTeamCreatedResponse(e:ResultEvent, success:Function, failed:Function):void
		{
			if (e.result)
				RefreshTeam(success);
			else
				failed();
		}
				
		private function OnRefreshTeamResponse(e:ResultEvent, callback : Function) : void
		{
			mPlayerTeam = e.result as Team;
			
			UpdateFieldPositions();
									
			if (callback != null)
				callback();
			
			dispatchEvent(new Event("PlayerTeamChanged")); 
			dispatchEvent(new Event("SelectedSoccerPlayerQualityChanged"));
			
			RefreshTeamDetails();
		}
		
		private function IsSubstitute(player : SoccerPlayer) : Boolean
		{
			return player.FieldPosition >= 100;
		}
		
		private function UpdateFieldPositions() : void
		{
			mFieldSoccerPlayers = new ArrayCollection();
			mSubstituteSoccerPlayers = new ArrayCollection();
			
			if (mPlayerTeam != null)
			{
				for each(var soccerPlayer : SoccerPlayer in mPlayerTeam.SoccerPlayers)
				{
					if (!IsSubstitute(soccerPlayer))
						mFieldSoccerPlayers.addItem(soccerPlayer);
					else
						mSubstituteSoccerPlayers.addItem(soccerPlayer);
				}
			}
			
			mFieldSoccerPlayers.sort = new Sort();
			mFieldSoccerPlayers.sort.fields = [ new SortField("FieldPosition") ];
			mFieldSoccerPlayers.refresh();
			mSubstituteSoccerPlayers.sort = new Sort();
			mSubstituteSoccerPlayers.sort.fields = [ new SortField("FieldPosition") ];
			mSubstituteSoccerPlayers.refresh();

			dispatchEvent(new Event("FieldSoccerPlayersChanged"));
			dispatchEvent(new Event("SubstituteSoccerPlayersChanged"));
		}
				
		public function SwapFormationPosition(first : SoccerPlayer, second : SoccerPlayer) : void
		{
			mMainService.SwapFormationPosition(first.SoccerPlayerID, second.SoccerPlayerID, ErrorMessages.FaultResponder);
			
			var swap : int = first.FieldPosition;
			first.FieldPosition = second.FieldPosition;
			second.FieldPosition = swap;
			
			UpdateFieldPositions();
		}
		
		static public function GetQualityFor(soccerPlayer : SoccerPlayer) : Number
		{
			return Math.round((soccerPlayer.Power + soccerPlayer.Sliding + soccerPlayer.Weight) / 3);
		}
		
		public function AssignSkillPoints(weight : int, sliding : int, power : int) : void
		{
			if (SelectedSoccerPlayer == null)
				throw "WTF";
			
			mMainService.AssignSkillPoints(SelectedSoccerPlayer.SoccerPlayerID, weight, sliding, power, ErrorMessages.FaultResponder);
			
			SelectedSoccerPlayer.Weight += weight;
			SelectedSoccerPlayer.Sliding += sliding;
			SelectedSoccerPlayer.Power += power;
			
			mPlayerTeam.SkillPoints -= weight + sliding + power;
			
			dispatchEvent(new Event("SelectedSoccerPlayerQualityChanged"));
		}
		
		public function RefreshTeamDetails() : void
		{
			mMainService.RefreshSelfTeamDetails(ErrorMessages.FaultResponder);	
		}
				
		[Bindable(event="PlayerTeamChanged")]
		public function get TheTeam() : Team { return mPlayerTeam; }
		
		[Bindable(event="PlayerTeamDetailsChanged")]
		public function get TheTeamDetails() : TeamDetails { return mMainService.GetModel().RefreshSelfTeamDetailsResult; }
		
		[Bindable(event="PlayerTeamChanged")]
		public function get PredefinedTeamName() : String 
		{
			if (mPlayerTeam != null)
				return mMainModel.ThePredefinedTeamsModel.GetNameByID(mPlayerTeam.PredefinedTeamID);
			return null;
		}
		
		[Bindable(event="PlayerTeamChanged")]
		public function get PredefinedTeamID() : int 
		{
			if (mPlayerTeam != null)
				return mPlayerTeam.PredefinedTeamID;
			return -1;
		}
		
		[Bindable(event="FieldSoccerPlayersChanged")]
		public function get FieldSoccerPlayers() : ArrayCollection { return mFieldSoccerPlayers; }
		
		[Bindable(event="SubstituteSoccerPlayersChanged")]
		public function get SubstituteSoccerPlayers() : ArrayCollection { return mSubstituteSoccerPlayers; }
		
		[Bindable]
		public function get SelectedSoccerPlayer() : SoccerPlayer { return mSelectedSoccerPlayer; }
		public function set SelectedSoccerPlayer(s : SoccerPlayer) : void 
		{ 
			mSelectedSoccerPlayer = s;
			dispatchEvent(new Event("SelectedSoccerPlayerQualityChanged"));
		}
		
		// TODO: Si tuvieramos el SoccerPlayer nuestro y no el del servidor, podriamos ponerle un Quality bindable
		[Bindable(event="SelectedSoccerPlayerQualityChanged")]
		public function get SelectedSoccerPlayerQuality() : Number { return GetQualityFor(mSelectedSoccerPlayer); }
		
		
		// El MatchResult entra desde el servidor MainRealtime
		public function AmITheWinner(matchResult : Object) : Boolean
		{
			var bRet : Boolean = false;
			
			if (matchResult.ResultPlayer1.Goals != matchResult.ResultPlayer2.Goals)
			{
				var winner : Object = matchResult.ResultPlayer1.Goals > matchResult.ResultPlayer2.Goals? 
									  matchResult.ResultPlayer1 : 
									  matchResult.ResultPlayer2;
				
				if (TheTeam.Name == winner.Name)
					bRet = true;
			}
			
			return bRet;
		}
		
		public function GetOpponentName(matchResult : Object) : String
		{
			var oppName : String = matchResult.ResultPlayer1.Name;
			
			if (matchResult.ResultPlayer1.Name == TheTeam.Name)
				oppName = matchResult.ResultPlayer2.Name;
			
			return oppName;
		}
				
		private var mFieldSoccerPlayers : ArrayCollection;
		private var mSubstituteSoccerPlayers : ArrayCollection;
		private var mSelectedSoccerPlayer : SoccerPlayer;
		
		private var mMainModel : MainGameModel;
		private var mMainService : MainService;
		
		private var mPlayerTeam : Team;	
	}
}
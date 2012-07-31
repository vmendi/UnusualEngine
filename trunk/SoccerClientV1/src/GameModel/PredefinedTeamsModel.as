package GameModel
{
	import SoccerServerV1.MainService;
	import SoccerServerV1.MainServiceModel;
	import SoccerServerV1.TransferModel.vo.PredefinedTeam;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.Responder;
	import mx.rpc.events.ResultEvent;
	
	import utils.Delegate;

	public final class PredefinedTeamsModel extends EventDispatcher
	{
		public function PredefinedTeamsModel(mainService : MainService, mainModel : MainGameModel)
		{
			mMainService = mainService;
			mMainServiceModel = mMainService.GetModel();
			mMainModel = mainModel;
		}
		
		public function InitialRefresh(callback : Function) : void
		{
			mMainService.RefreshPredefinedTeams(new Responder(Delegate.create(OnRefreshPredefinedTeamsResponse, callback), ErrorMessages.Fault));
		}		
		
		private function OnRefreshPredefinedTeamsResponse(e : ResultEvent, callback : Function):void
		{
			mPredefinedTeams = e.result as ArrayCollection;
			mPredefinedTeamNames = new ArrayCollection();
			
			for each(var predefTeam : PredefinedTeam in mPredefinedTeams)
			{
				mPredefinedTeamNames.addItem(predefTeam.Name);
			}
			
			if (callback != null)
				callback();
			
			dispatchEvent(new Event("PredefinedTeamNamesChanged"));
		}
				
		public function GetIDByName(name : String) : int
		{
			for each(var team : PredefinedTeam in mPredefinedTeams)
			{
				if (team.Name == name)
					return team.PredefinedTeamID;
			}
			return -1;
		}
		
		public function GetNameByID(predefinedTeamID : int) : String
		{
			for each(var team : PredefinedTeam in mPredefinedTeams)
			{
				if (team.PredefinedTeamID == predefinedTeamID)
					return team.Name;
			}
			return null;
		}
			
		[Bindable(event="PredefinedTeamNamesChanged")]
		public function get PredefinedTeamNames() : ArrayCollection { return mPredefinedTeamNames; }
		

		private var mMainModel : MainGameModel;
		private var mMainService : MainService;
		private var mMainServiceModel : MainServiceModel;
		
		private var mPredefinedTeams : ArrayCollection;
		private var mPredefinedTeamNames : ArrayCollection;
	}
}
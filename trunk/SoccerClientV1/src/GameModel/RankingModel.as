package GameModel
{
	import GameView.Team.Team;
	
	import SoccerServerV1.MainService;
	import SoccerServerV1.TransferModel.vo.RankingPage;
	import SoccerServerV1.TransferModel.vo.RankingTeam;
	import SoccerServerV1.TransferModel.vo.TeamMatchStats;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.Responder;
	import mx.rpc.events.ResultEvent;

	public final class RankingModel extends EventDispatcher
	{
		public function RankingModel(mainService : MainService, mainModel : MainGameModel)
		{
			mMainService = mainService;
			mMainGameModel = mainModel;
		}
		
		public function RefreshAndSelectSelf() : void
		{			
			mMainService.RefreshSelfRankingPage(new mx.rpc.Responder(OnRefreshRankingPageRespondedSelectSelf, ErrorMessages.Fault));
		}
		
		private function OnRefreshMatchStatsResponded(e:ResultEvent) : void
		{
			mSelectedRankingTeamMatchStats = e.result as TeamMatchStats;
			dispatchEvent(new Event("SelectedRankingTeamMatchStatsChanged"));
		}
				
		public function NextRankingPage() : void
		{
			if (mCurrentRankingPage.PageIndex < mCurrentRankingPage.TotalPageCount-1)
			{
				mMainService.RefreshRankingPage(mCurrentRankingPage.PageIndex+1, 
												new mx.rpc.Responder(OnRefreshRankingPageResponded, ErrorMessages.Fault)); 
			}
		}
		
		public function PrevRankingPage() : void
		{
			if (mCurrentRankingPage.PageIndex > 0)
			{
				mMainService.RefreshRankingPage(mCurrentRankingPage.PageIndex-1, 
												new mx.rpc.Responder(OnRefreshRankingPageResponded, ErrorMessages.Fault)); 
			}
		}
		
		private function OnRefreshRankingPageRespondedSelectSelf(e:ResultEvent) : void
		{
			OnRefreshRankingPageResponded(e);
			
			// Nosotros estamos seguro en esta pagina
			for each(var rankingTeam : RankingTeam in mCurrentRankingPage.Teams)
			{
				if (rankingTeam.Name == mMainGameModel.TheTeamModel.TheTeam.Name)
				{
					// Esto provocara un refresco de las SelectedRankingTeamStats
					SelectedRankingTeam = rankingTeam;
					break;
				}
			}
		}
		
		private function OnRefreshRankingPageResponded(e:ResultEvent) : void
		{
			mCurrentRankingPage = e.result as RankingPage;
			dispatchEvent(new Event("RankingPageChanged"));
		}
		
		public function FirstPage() : void
		{
			mMainService.RefreshRankingPage(0, new mx.rpc.Responder(OnRefreshRankingPageResponded, ErrorMessages.Fault));
		}
		
		public function LastPage() : void
		{
			mMainService.RefreshRankingPage(mCurrentRankingPage.TotalPageCount-1, 
					new mx.rpc.Responder(OnRefreshRankingPageResponded, ErrorMessages.Fault));
		}
		
		[Bindable(event="RankingPageChanged")]
		public function get TheRankingPage() : RankingPage { return mCurrentRankingPage; }
		
		[Bindable(event="SelectedRankingTeamMatchStatsChanged")]
		public function get SelectedRankingTeamMatchStats() : TeamMatchStats { return mSelectedRankingTeamMatchStats; }
		
		[Bindable]
		public function get SelectedRankingTeam() : RankingTeam { return mSelectedRankingTeam; }
		public function set SelectedRankingTeam(selectedRankingTeam : RankingTeam) : void 
		{ 
			mSelectedRankingTeam = selectedRankingTeam;
			mMainService.RefreshMatchStatsForTeam(mSelectedRankingTeam.FacebookID, 
												 new mx.rpc.Responder(OnRefreshMatchStatsResponded, ErrorMessages.Fault));
		}
		
		
		private var mCurrentRankingPage : RankingPage;
		private var mSelectedRankingTeam : RankingTeam;
		private var mSelectedRankingTeamMatchStats : TeamMatchStats;
				
		private var mMainService : MainService;
		private var mMainGameModel : MainGameModel;
	}
}
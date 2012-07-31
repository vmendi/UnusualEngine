package GameModel
{	
	import SoccerServerV1.MainService;
	import SoccerServerV1.MainServiceModel;
	
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	
	import mx.collections.ArrayCollection;
	
	import utils.Delegate;

	public class MainGameModel extends EventDispatcher
	{	
		static public const POSSIBLE_MATCH_LENGTH_MINUTES : ArrayCollection = new ArrayCollection([ 10, 5, 15 ]);
		static public const POSSIBLE_TURN_LENGTH_SECONDS : ArrayCollection = new ArrayCollection([ 10, 15, 5 ]);
		
		public function MainGameModel()
		{
			mMainService = new MainServiceSoccerV1();
			
			mRealtimeModel = new RealtimeModel(mMainService, this);					
			mRankingModel = new RankingModel(mMainService, this);
			mTeamModel = new TeamModel(mMainService, this);
			mTrainingModel = new TrainingModel(mMainService, this);
			mLoginModel = new LoginModel(mMainService, this);
			mFormationModel = new FormationModel(mMainService, this);
			mSpecialTrainingModel = new SpecialTrainingModel(mMainService, this);
			mPredefinedTeamsModel = new PredefinedTeamsModel(mMainService, this);	
		}

		public function InitialRefresh(callback : Function) : void
		{
			mPredefinedTeamsModel.InitialRefresh(Delegate.create(InitialRefreshStage01Completed, callback));
		}
		
		private function InitialRefreshStage01Completed(callback : Function) : void
		{
			mTrainingModel.InitialRefresh(callback);
		}
		
		public function OnCleaningShutdown() : void
		{
			mTrainingModel.CleaningShutdown();	
		}

		[Bindable(event="dummy")]
		public function get TheTrainingModel() : TrainingModel { return mTrainingModel; }
		
		[Bindable(event="dummy")]
		public function get TheSpecialTrainingModel() : SpecialTrainingModel { return mSpecialTrainingModel; }
		
		[Bindable(event="dummy")]
		public function get TheLoginModel() : LoginModel { return mLoginModel; }
		
		[Bindable(event="dummy")]
		public function get TheFormationModel() : FormationModel { return mFormationModel; }		
		
		[Bindable(event="dummy")]
		public function get TheRealtimeModel() : RealtimeModel { return mRealtimeModel; }
		
		[Bindable(event="dummy")]
		public function get TheTeamModel() : TeamModel { return mTeamModel; }
		
		[Bindable(event="dummy")]
		public function get TheRankingModel() : RankingModel { return mRankingModel; }
		
		[Bindable(event="dummy")]
		public function get ThePredefinedTeamsModel() : PredefinedTeamsModel { return mPredefinedTeamsModel; }
		
		
		private var mMainService : MainService;
		
		private var mTeamModel : TeamModel;
		private var mTrainingModel : TrainingModel;
		private var mLoginModel : LoginModel;
		private var mFormationModel : FormationModel;
		private var mSpecialTrainingModel : SpecialTrainingModel;
		private var mRankingModel : RankingModel;
		private var mPredefinedTeamsModel : PredefinedTeamsModel;
		private var mRealtimeModel : RealtimeModel;
	}
}
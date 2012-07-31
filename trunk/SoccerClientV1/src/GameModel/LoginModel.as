package GameModel
{
	import SoccerServerV1.MainService;
	import SoccerServerV1.MainServiceModel;
	import SoccerServerV1.enum.VALID_NAME;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.rpc.Responder;
	import mx.rpc.events.ResultEvent;
	
	import utils.Delegate;

	public class LoginModel extends EventDispatcher
	{
		public function LoginModel(mainService : MainService, mainModel : MainGameModel)
		{
			mMainService = mainService;
			mMainServiceModel = mMainService.GetModel();
			mMainModel = mainModel;
		}
				
		public function IsValidTeamName(name : String, onRefreshed : Function) : void
		{
			mMainService.IsNameValid(name, new mx.rpc.Responder(Delegate.create(OnIsNameValidResponse, onRefreshed), ErrorMessages.Fault));
		}
		
		private function OnIsNameValidResponse(e:ResultEvent, onRefreshed:Function):void
		{
			mIsValidTeamNameLastResult = e.result as String;
			onRefreshed(e.result);
			dispatchEvent(new Event("IsValidTeamNameLastResultChanged"));
		}
			
		[Bindable(event="IsValidTeamNameLastResultChanged")]
		public function get IsValidTeamNameLastResult() : String { return mIsValidTeamNameLastResult; }
		
		private var mIsValidTeamNameLastResult : String = VALID_NAME.EMPTY;
				
		private var mMainModel : MainGameModel;
		private var mMainService : MainService;
		private var mMainServiceModel : MainServiceModel;
	}
}
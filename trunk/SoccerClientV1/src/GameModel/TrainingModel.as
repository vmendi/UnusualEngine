package GameModel
{
	import SoccerServerV1.MainService;
	import SoccerServerV1.MainServiceModel;
	import SoccerServerV1.TransferModel.vo.PendingTraining;
	
	import com.greensock.TweenNano;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.rpc.Responder;
	import mx.rpc.events.ResultEvent;
	
	import utils.Delegate;

	public class TrainingModel extends EventDispatcher
	{
		public function TrainingModel(mainService : MainService, mainModel : MainGameModel)
		{
			mMainService = mainService;
			mMainServiceModel = mMainService.GetModel();
			mMainModel = mainModel;
			mTeamModel = mMainModel.TheTeamModel;
			
			BindingUtils.bindSetter(OnPendingTrainingChanged, mMainServiceModel, "TrainResult");
			BindingUtils.bindSetter(OnPendingTrainingChanged, mMainModel, ["TheTeamModel", "TheTeam", "PendingTraining"]);
			
			// Comentado por test "SessionKey is missing"
			//TweenNano.delayedCall(600, OnFitnessUpdateDelayedCall);
		}
		
		public function CleaningShutdown() : void
		{
			TweenNano.killTweensOf(OnFitnessUpdateDelayedCall);
			TweenNano.killTweensOf(mMainService.RefreshRemainingSecondsForPendingTraining);
			
			if (mPendingTrainingTimer != null)
			{
				mPendingTrainingTimer.stop();
				mPendingTrainingTimer = null;
			}
		}
		
		private function OnFitnessUpdateDelayedCall() : void
		{
			// Cada X tiempo el servidor quita fitness al equipo. Intentamos estar "sincronizadillos".
			mTeamModel.RefreshTeam(null);
			
			TweenNano.delayedCall(600, OnFitnessUpdateDelayedCall);
		}
		
		public function Train(trainingName : String, response:Function):void
		{
			mMainService.Train(trainingName, new mx.rpc.Responder(Delegate.create(OnTrainResponse, response), ErrorMessages.Fault));
		}
		private function OnTrainResponse(e:ResultEvent, callback:Function):void
		{
			if (callback != null)
				callback();	
		}
		
		
		public function InitialRefresh(response : Function) : void
		{
			mMainService.RefreshTrainingDefinitions(new Responder(Delegate.create(OnTrainingDefinitionsResponse, response), ErrorMessages.Fault));
		}

		private function OnTrainingDefinitionsResponse(e:ResultEvent, callback : Function):void
		{
			mTrainingDefinitions = e.result as ArrayCollection;
			
			if (callback != null)
				callback();
			
			dispatchEvent(new Event("TrainingDefinitionsChanged"));
		}

		private function OnPendingTrainingChanged(newOne : PendingTraining):void
		{
			if (mTeamModel.TheTeam == null)
				return;
			
			mTeamModel.TheTeam.PendingTraining = newOne;
			
			if (mCurrentPendingTraining != null && newOne == null)
				StopPendingTraining();
			else
			if (mCurrentPendingTraining == null && newOne != null)
				StartPendingTraining();
			else
			if (!ArePendingTrainingsEqual(mCurrentPendingTraining, newOne))
				throw "Hemos cambiado de training sin pasar por null";
			
			mCurrentPendingTraining = newOne;
			
			dispatchEvent(new Event("CurrentPendingTrainingChanged"));
		}
		
		private function ArePendingTrainingsEqual(a : PendingTraining, b : PendingTraining) : Boolean
		{
			if (a == null && b == null)
				return true;
			else if (a != null && b != null)
				return a.TimeStart.toString() == b.TimeStart.toString() && a.TimeEnd.toString() == b.TimeEnd.toString();
			
			return false;
		}
		
		private function StopPendingTraining() : void
		{
			if (mPendingTrainingTimer != null)
			{
				trace("Se acabo");
				mPendingTrainingTimer.stop();
				mPendingTrainingTimer = null;
			}
			
			dispatchEvent(new Event("RemainingSecondsChanged"));
		}
		
		private function StartPendingTraining():void
		{			
			if (mPendingTrainingTimer != null ||  mTeamModel.TheTeam.PendingTraining == null)
				throw "Analizame";
			
			trace("StartPendingTraining");
			
			mMainService.RefreshRemainingSecondsForPendingTraining(new Responder(OnRemainigSecondsResponse, ErrorMessages.Fault));
		}
		
		private function OnPendingTrainingTimer(e:Event):void
		{
			dispatchEvent(new Event("RemainingSecondsChanged"));
		}
		
		private function OnRemainigSecondsResponse(e:ResultEvent):void
		{
			var numSeconds : int = e.result as int;
			
			trace("Quedan: " + numSeconds);
			
			if (numSeconds > 0)
			{
				mPendingTrainingTimer = new Timer(1000, numSeconds);
				mPendingTrainingTimer.addEventListener(TimerEvent.TIMER, OnPendingTrainingTimer);
				mPendingTrainingTimer.addEventListener(TimerEvent.TIMER_COMPLETE, OnPendingTrainingTimerComplete);
				mPendingTrainingTimer.start();
			}
			else
			{
				mMainModel.TheTeamModel.RefreshTeam(null);
			}
			
			dispatchEvent(new Event("RemainingSecondsChanged"));
		}
		
		private function OnPendingTrainingTimerComplete(e:Event):void
		{
			trace("Tiempo completed");
			
			if (mTeamModel.TheTeam.PendingTraining == null)
				throw "Deberian habernos stopado en el refresco del PendingTraining";
			
			TweenNano.delayedCall(1, mMainService.RefreshRemainingSecondsForPendingTraining, 
								  [new Responder(OnRemainigSecondsResponse, ErrorMessages.Fault)]);
		}
		
		[Bindable(event="RemainingSecondsChanged")]
		public function get RemainingSeconds() : int
		{
			var ret : int = -1;
			
			if (mPendingTrainingTimer != null)
				ret = mPendingTrainingTimer.repeatCount - mPendingTrainingTimer.currentCount;
			else
			// Hasta que nos retornen el RemainingSeconds, devolvemos el tiempo total por definicion
			if (mCurrentPendingTraining != null)
				ret = mCurrentPendingTraining.TrainingDefinition.Time;
					
			return ret;
		}
		
		[Bindable(event="RemainingSecondsChanged")]
		public function get IsRegularTrainingAvailable() : Boolean { return RemainingSeconds == -1; }
		
		[Bindable(event="TrainingDefinitionsChanged")]
		public function get TrainingDefinitions() : ArrayCollection { return mTrainingDefinitions; }
		
		[Bindable(event="CurrentPendingTrainingChanged")]
		public function get CurrentPendingTraining() : PendingTraining { return mCurrentPendingTraining; }
		
		private var mMainService : MainService;
		private var mMainServiceModel : MainServiceModel;
		private var mMainModel : MainGameModel;
		private var mTeamModel : TeamModel;
		
		private var mPendingTrainingTimer : Timer;
		private var mCurrentPendingTraining : PendingTraining = null;
		
		private var mTrainingDefinitions : ArrayCollection;
	}
}
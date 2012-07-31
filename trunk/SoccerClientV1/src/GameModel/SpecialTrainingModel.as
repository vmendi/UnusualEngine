package GameModel
{
	import SoccerServerV1.MainService;
	import SoccerServerV1.TransferModel.vo.SpecialTraining;
	import SoccerServerV1.TransferModel.vo.SpecialTrainingDefinition;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.rpc.Responder;
	import mx.rpc.events.ResultEvent;
	
	import org.osflash.signals.Signal;
	
	import utils.Delegate;

	public final class SpecialTrainingModel extends EventDispatcher
	{
		// Esta señal marca que se ha completado un entrenamiento concreto
		public var SpecialTrainingCompleted : Signal = new Signal(SpecialTrainingDefinition);
		
		public function SpecialTrainingModel(mainService : MainService, mainModel : MainGameModel)
		{
			mMainService = mainService;
			mMainModel = mainModel;
			
			BindingUtils.bindSetter(OnSpecialTrainingsChanged, mMainModel, ["TheTeamModel", "TheTeam", "SpecialTrainings"]);
			
			ExternalInterface.addCallback("OnLikeButtonPressed", OnLikeButtonPressed);
		}
		
		public function OnLikeButtonPressed() : void
		{
			// Es posible que se pulse el boton Like antes de tener creado un equipo, por ejemplo durante la pantalla de Login.mxml
			if (mMainModel.TheTeamModel.TheTeam != null)
			{
				mMainService.OnLiked(new mx.rpc.Responder(OnLikedResponse, ErrorMessages.Fault));
			}
		}
		
		private function OnLikedResponse(e:ResultEvent) : void
		{
			mMainModel.TheTeamModel.RefreshTeam(Delegate.create(OnLikeButtonTeamRefreshed, e.result));
		}
		
		private function OnLikeButtonTeamRefreshed(specialTrainingDefinitionID : int) : void
		{
			// Ahora ya podemos señalar que se completo...
			for each(var sp : SpecialTraining in mTrainings)
			{
				if (sp.SpecialTrainingDefinition.SpecialTrainingDefinitionID == specialTrainingDefinitionID)
				{
					SpecialTrainingCompleted.dispatch(sp.SpecialTrainingDefinition);
					return;
				}
			}
			
			throw "WTF";
		}
		
		public function TrainSpecial(specTraining : SpecialTraining, response:Function = null) : void
		{
			if (specTraining.IsCompleted)
				throw "WTF";
			
			// Hemos quitado el parametro Energia del equipo. Ahora se resta de los puntos Mahou
			if (specTraining.SpecialTrainingDefinition.EnergyStep <= mMainModel.TheTeamModel.TheTeam.SkillPoints)
			{
				mMainService.TrainSpecial(specTraining.SpecialTrainingDefinition.SpecialTrainingDefinitionID, 
										  new mx.rpc.Responder(Delegate.create(OnSpecialTrainResponse, response), ErrorMessages.Fault));
				
				specTraining.EnergyCurrent += specTraining.SpecialTrainingDefinition.EnergyStep;
				
				if (specTraining.EnergyCurrent >= specTraining.SpecialTrainingDefinition.EnergyTotal)
				{
					specTraining.EnergyCurrent = specTraining.SpecialTrainingDefinition.EnergyTotal;
					specTraining.IsCompleted = true;				
					
					// Es uno de los completados...
					mCompletedTrainingIDs.addItem(specTraining.SpecialTrainingDefinition.SpecialTrainingDefinitionID);
					dispatchEvent(new Event("CompletedSpecialTrainingIDsChanged"));
				
					// Señalamos que se completo uno nuevo
					SpecialTrainingCompleted.dispatch(specTraining.SpecialTrainingDefinition);
				}
				
				mMainModel.TheTeamModel.TheTeam.SkillPoints -= specTraining.SpecialTrainingDefinition.EnergyStep;
			}
		}
		private function OnSpecialTrainResponse(e:ResultEvent, callback:Function):void
		{
			if (callback != null)
				callback(e.result);	
		}
		
		private function OnSpecialTrainingsChanged(newVal : ArrayCollection) : void
		{
			mTrainings = newVal;
			
			mCompletedTrainingIDs = new ArrayCollection();
			
			for each(var sp : SpecialTraining in mTrainings)
			{
				if (sp.IsCompleted)
					mCompletedTrainingIDs.addItem(sp.SpecialTrainingDefinition.SpecialTrainingDefinitionID);
			}
			
			dispatchEvent(new Event("SpecialTrainingsChanged"));
			dispatchEvent(new Event("CompletedSpecialTrainingIDsChanged"));
		}
		
		public function IsAvailableByRequiredXP(specialTraining : SpecialTraining) : Boolean
		{
			return specialTraining.SpecialTrainingDefinition.RequiredXP < mMainModel.TheTeamModel.TheTeam.XP;
		}
		
		[Bindable(event="SpecialTrainingsChanged")]
		public function get SpecialTrainings() : ArrayCollection { return mTrainings; }
		
		[Bindable(event="CompletedSpecialTrainingIDsChanged")]
		public function get CompletedSpecialTrainingIDs() : ArrayCollection { return mCompletedTrainingIDs;	}
		
						
		private var mTrainings : ArrayCollection;
		private var mCompletedTrainingIDs : ArrayCollection;
				
		private var mMainModel : MainGameModel;
		private var mMainService : MainService;
	}
}
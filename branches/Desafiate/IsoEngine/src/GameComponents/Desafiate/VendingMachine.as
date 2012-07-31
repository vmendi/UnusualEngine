package GameComponents.Desafiate
{
	import GameComponents.Character;
	import GameComponents.GameComponent;
	
	import Model.SceneObject;
	
	import flash.geom.Point;
	
	import utils.Delegate;

	public class VendingMachine extends GameComponent
	{
		
		override public function OnPreStart():void
		{
			mBalloon = TheGameModel.CreateSceneObjectFromMovieClip("mcBalloon", "Balloon") as Balloon;
		}

		override public function OnStart():void
		{
			mStatus = TheGameModel.FindGameComponentByShortName("GameStatus") as GameStatus;
			//mMainSalaTrabajo = TheGameModel.FindGameComponentByShortName("MainCafeteria") as MainSalaTrabajo

			mBalloon.SetColor(0xf3faf3);
			mBalloon.SetBalloon(350, new Point(110, -175));
			mBalloon.FollowObject(TheVisualObject);
			mBalloon.TheVisualObject.visible = false;
		}
		
		override public function OnStartComplete():void
		{
			mCharacter = TheGameModel.FindGameComponentByShortName("Character") as Character;
			if (TheGameModel.FindGameComponentByShortName("MiniGameManager").GetScoreForMiniGame("VendingMachine") > 0 || mStatus.Checkpoint != Checkpoints.INTER02)
			{
				TheVisualObject.gotoAndStop("empty");
			}
			else
			{
				TheVisualObject.gotoAndStop("golpeador");
			}
		}

		public function Talk(speech : Array, callback : Function) : void
		{
			mBalloon.SetSpeech(speech, Delegate.create(OnTalkEnd, callback));
		}
		
		private function OnTalkEnd(callback : Function):void
		{
			if (callback != null)
				callback();
		}
		
		public function OnCharacterInteraction(target:SceneObject):void
		{
			if (target != TheSceneObject)
				return;


			switch (mStatus.Checkpoint)
			{
				case Checkpoints.INTER02:
					if (TheGameModel.FindGameComponentByShortName("MiniGameManager").GetScoreForMiniGame("VendingMachine") <= 0)
					{
						mCharacter.MouseControlled = false;
						Talk(["¡Maldita máquina!. No quiere soltar mi bolsa de Tortillas Chips ¡y estoy muerto de hambre!", 3000], Delegate.create(LaunchVendingGame));
					}
				break;
			}
					
		}
		
		private function LaunchVendingGame():void
		{
			TheGameModel.FindGameComponentByShortName("MiniGameManager").PlayMiniGame("VendingMachine", OnVendingMachineEnd);
		}
		
		private function OnVendingMachineEnd(score : Number):void
		{
			if (score == -1)
			{
				Talk(["Bueno, no te preocupes, no es fácil.", 3000, "¡Seguiré intentándolo!", 2500], UnFreezeCharacter);
			}
			else
			{
				TheVisualObject.gotoAndStop("stop");
				Talk(["¡Perfecto, muchas gracias! Acabas de ganar 1000 Puntos Geek.", 3000], UnFreezeCharacter);
			}
		}
		
		private function UnFreezeCharacter():void
		{
			mCharacter.MouseControlled = true;
		}		
		
		private var mStatus : GameStatus;
		private var mBalloon : Balloon;
		private var mMainCafeteria : MainCafeteria;
		private var mCharacter : Character;
	}
}
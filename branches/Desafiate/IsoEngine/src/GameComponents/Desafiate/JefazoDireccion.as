package GameComponents.Desafiate
{
	import GameComponents.Character;
	import GameComponents.GameComponent;
	
	import Model.SceneObject;
	
	import flash.geom.Point;
	
	import utils.Delegate;


	/**
	 * Componente ...
	 */
	public final class JefazoDireccion extends GameComponent
	{
		override public function OnPreStart():void
		{
			mBalloon = TheGameModel.CreateSceneObjectFromMovieClip("mcBalloon", "Balloon") as Balloon;
		}

		override public function OnStart():void
		{
			mStatus = TheGameModel.FindGameComponentByShortName("GameStatus") as GameStatus;

			mBalloon.SetColor(0xffa9ab);
			mBalloon.SetBalloon(300, new Point(-325, -175));
			mBalloon.FollowObject(TheVisualObject);
			mBalloon.TheVisualObject.visible = false;
			
			if (mStatus.Checkpoint != Checkpoints.INTER02)
			{
				TheVisualObject.gotoAndStop("empty");
				TheVisualObject.InteractiveArea.visible = false;
			}
		}
		
		override public function OnStartComplete():void
		{
			mCharacter = TheGameModel.FindGameComponentByShortName("Character") as Character;
		}
		
		public function OnCharacterInteraction(target:SceneObject):void
		{
			if (target.Name == "DireccionSillon" && mStatus.Checkpoint == Checkpoints.INTER02)
			{
				Talk(["Joven, deje en paz a mi hija Paula.", 3000], null);
			}
			
			if (target != TheSceneObject)
				return;
				
			switch (mStatus.Checkpoint)
			{
				case Checkpoints.INTER02:
					if (TheGameModel.FindGameComponentByShortName("MiniGameManager").GetScoreForMiniGame("GuessPassword2") > 0)
					{
						Talk(["Ahora no puedo atenderle joven ¿No ve que estoy muy ocupado?", 3000], null);
					}
					else
					{
						mCharacter.MouseControlled = false;
						Talk(["Tarde como siempre. No logro recordar mi password, espero que pueda ayudarme.", 3000], Delegate.create(LaunchGuessPasswordGame));
					}
				break;
				case Checkpoints.TM03_START:
					Talk(["Muchacho, están teniendo problemas en la sala de reuniones. No sé qué hace aquí todavía.", 3000], null);
				break;
			}
		}		

		public function Talk(speech : Array, callback : Function):void
		{
			mBalloon.SetSpeech(speech, callback);
		}
		
		private function LaunchGuessPasswordGame():void
		{
			TheGameModel.FindGameComponentByShortName("MiniGameManager").PlayMiniGame("GuessPassword2", OnGuessPasswordEnd);
		}
		
		private function OnGuessPasswordEnd(score : Number):void
		{
			if (score == -1)
			{
				Talk(["¿Y tu eres el gurú?. Seguiré intentándolo por mi cuenta.", 3000], UnFreezeCharacter);
			}
			else
			{
				Talk(["¡Perfecto, muchas gracias! Acabas de ganar 1000 Puntos Geek.", 3000], UnFreezeCharacter);
				//mCharacter.MouseControlled = true;
			}
		}
		
		private function UnFreezeCharacter():void
		{
			mCharacter.MouseControlled = true;
		}		

		private var mStatus : GameStatus;
		private var mBalloon : Balloon;
		private var mSpeech : Array;
		private var mCallBack : Function;
		private var mCharacter : Character;
	}

}
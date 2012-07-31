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
	public final class Recepcionista extends GameComponent
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
		}

		override public function OnStartComplete():void
		{
			mCharacter = TheGameModel.FindGameComponentByShortName("Character") as Character;

			if (mStatus.Checkpoint == Checkpoints.END)
			{
				TheVisualObject.gotoAndStop("empty");
				TheVisualObject.InteractiveArea.visible = false;
			}
		}

		public function OnCharacterInteraction(target:SceneObject):void
		{
			if (target != TheSceneObject)
				return;

			switch (mStatus.Checkpoint)
			{
				case Checkpoints.INTRO:
					Talk(["Debería bajar a la sala de IT, le están esperando.",3000], null);
				break;
				case Checkpoints.INTER02:
					if (TheGameModel.FindGameComponentByShortName("MiniGameManager").GetScoreForMiniGame("SilverFlash") > 0)
					{
						Talk(["Gracias por instalarme Silverlight, ahora puedo esuchar los temas de mi grupo favorito :-)",3000], null);
					}
					else
					{
						mCharacter.MouseControlled = false;
						Talk(["¡Hola máquina! Estoy tratando de ver el website de mi grupo favorito.",3000, "Dicen que usa una tecnología increíble para ver contenidos multimedia.", 3000, "Pero hay que instalar algo y no tengo permisos ¿Puedes ayudarme?", 3000], LaunchSilverlightGame);
					}
				break;
				case Checkpoints.TM02_START:
					Talk(["¿No te has enterado? Hay un lío increíble con los servidores. Deberías ocuparte de ello.",3500], null);
				break;
				case Checkpoints.TM03_START:
					Talk(["Tienes que ir urgentemente a la sala de reuniones, te están esperando.",3000], null);
				break;
				default:
					Talk(["Odio los ordenadores, nunca me hacen caso.",3000], null);
				break;
			}
		}

		public function Talk(speech : Array, callback : Function):void
		{
			mCallBack = callback;
			mSpeech = speech;
			TalkLoop(0);
		}

		private function TalkLoop(step : Number):void
		{
			switch (step)
			{
				case 0:
					TheVisualObject.mcRecepcionista.gotoAndPlay("talk_loop");
					mBalloon.SetSpeech(mSpeech, Delegate.create(TalkLoop, 1));
				break;
				case 1:
					TheVisualObject.mcRecepcionista.gotoAndPlay("talk_end");
					if (mCallBack != null)
						mCallBack();
				break;
			}
		}

		private function LaunchSilverlightGame():void
		{
			(TheGameModel.FindGameComponentByShortName("MiniGameManager") as MiniGameManager).PlayMiniGame("SilverFlash", OnSilverlight);
		}

		private function OnSilverlight(score:int):void
		{
			mCharacter.MouseControlled = true;
			if (score <= 0)
			{
				Talk(["No te preocupes, seguiré intentándolo yo sola. Gracias de todos modos.",3000], null);
			}
			else
			{
				Talk(["¡Muchas gracias! ¿A que están bien?",7000], null);
			}
		}

		private var mStatus : GameStatus;
		private var mBalloon : Balloon;
		private var mSpeech : Array;
		private var mCallBack : Function;
		private var mCharacter : Character;

	}

}
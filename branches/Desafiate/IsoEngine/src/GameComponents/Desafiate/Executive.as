package GameComponents.Desafiate
{
	import GameComponents.Character;
	import GameComponents.GameComponent;
	
	import Model.SceneObject;
	
	import flash.geom.Point;
	
	import utils.Delegate;

	public class Executive extends GameComponent
	{
		public var BalloonX : Number = 0;
		public var BalloonY : Number = 0;
		
		override public function OnPreStart():void
		{
			mBalloon = TheGameModel.CreateSceneObjectFromMovieClip("mcBalloon", "Balloon") as Balloon;
		}

		override public function OnStart():void
		{
			mStatus = TheGameModel.FindGameComponentByShortName("GameStatus") as GameStatus;
			mMainConferencias = TheGameModel.FindGameComponentByShortName("MainConferencias") as MainConferencias;

			mBalloon.SetColor(0xdbdeea);
			mBalloon.SetBalloon(250, new Point(BalloonX, BalloonY));
			mBalloon.FollowObject(TheVisualObject);
			mBalloon.TheVisualObject.visible = false;
		}
		
		override public function OnStartComplete():void
		{
			mCharacter = TheGameModel.FindGameComponentByShortName("Character") as Character;
			
			if (mStatus.Checkpoint != Checkpoints.TM03_START)
			{
				Hide();
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
				
			if (mStatus.Checkpoint == Checkpoints.TM03_START && !mMainConferencias.PlayingTM)
			{
				Talk(["Tenemos que terminar la propuesta y apenas tenemos tiempo. Habla con el jefe.",3000], null);
			}
		}
		
		public function Hide():void
		{
			TheVisualObject.visible = false;
			/*
			TheVisualObject.gotoAndStop("empty");
			TheVisualObject.InteractiveArea.visible = false;
			*/
		}
		
		private var mStatus : GameStatus;
		private var mBalloon : Balloon;
		private var mMainConferencias : MainConferencias;
		private var mCharacter : Character;
	}
}
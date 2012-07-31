package GameComponents.Desafiate
{
	import GameComponents.GameComponent;
	
	import flash.geom.Point;


	/**
	 * Componente ...
	 */
	public final class JefazoCafeteria extends GameComponent
	{
		override public function OnPreStart():void
		{
			mBalloon = TheGameModel.CreateSceneObjectFromMovieClip("mcBalloon", "Balloon") as Balloon;
		}

		override public function OnStart():void
		{
			mStatus = TheGameModel.FindGameComponentByShortName("GameStatus") as GameStatus;

			mBalloon.SetColor(0xffa9ab);
			mBalloon.SetBalloon(300, new Point(30, -175));
			mBalloon.FollowObject(TheVisualObject);
			mBalloon.TheVisualObject.visible = false;

			if (mStatus.Checkpoint != Checkpoints.END)
			{
				Hide();
			}
		}

		public function Talk(speech : Array, callback : Function):void
		{
			mBalloon.SetSpeech(speech, callback);
		}
		
		public function Hide():void
		{
			TheVisualObject.visible = false;
		}

		private var mStatus : GameStatus;
		private var mBalloon : Balloon;
		private var mSpeech : Array;
		private var mCallBack : Function;
	}

}
package GameComponents.Desafiate
{
	import GameComponents.GameComponent;
	
	import flash.geom.Point;


	/**
	 * Componente ...
	 */
	public final class JefazoIT extends GameComponent
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

			if (mStatus.Checkpoint != Checkpoints.TM02_START)
			{
				TheVisualObject.visible = false;
			}
		}

		public function Talk(speech : Array, callback : Function):void
		{
			mBalloon.SetSpeech(speech, callback);
		}
		
		public function SetBalloon(width:Number, displacement : Point) : void
		{
			mBalloon.SetBalloon(width, displacement);
		}

		private var mStatus : GameStatus;
		private var mBalloon : Balloon;
		private var mSpeech : Array;
		private var mCallBack : Function;
	}

}
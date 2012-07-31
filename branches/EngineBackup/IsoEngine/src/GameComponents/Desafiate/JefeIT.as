package GameComponents.Desafiate
{
	import GameComponents.GameComponent;
	
	import flash.geom.Point;
	
	import utils.Delegate;
	import utils.MovieClipListener;


	/**
	 * Componente ...
	 */
	public final class JefeIT extends GameComponent
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

			MovieClipListener.AddFrameScript(TheVisualObject, "give_end", OnGiveWindowsPhone);
			MovieClipListener.AddFrameScript(TheVisualObject, "leave_end", OnLeave);

			switch (mStatus.Checkpoint)
			{
				case Checkpoints.INTRO:
					TheVisualObject.gotoAndStop("seated_working");
					mState = "seated";
				break;
				default:
					TheVisualObject.gotoAndStop("no_boss");
				break;
			}
		}

		public function Talk(speech : Array, callback : Function):void
		{
			mCallBack = callback;
			mSpeech = speech;
			TalkLoop(0);
		}

		public function SeatDown():void
		{
			mState = "seated";
			TheVisualObject.gotoAndStop("seated_idle");
		}

		public function StandUp():void
		{
			mState = "up";
			TheVisualObject.gotoAndStop("up_idle");
		}

		public function GiveWindowsPhone(callback : Function):void
		{
			mCallBackGive = callback;
			TheVisualObject.gotoAndPlay("give");
		}

		private function OnGiveWindowsPhone():void
		{
			TheVisualObject.gotoAndStop("up_idle");
			mCallBackGive();
		}

		public function Leave(callback : Function):void
		{
			mCallBackLeave = callback;
			TheVisualObject.gotoAndPlay("leave");
		}

		private function OnLeave():void
		{
			TheVisualObject.gotoAndStop("no_boss");
			mCallBackLeave();
		}

		private function TalkLoop(step : Number):void
		{
			switch (step)
			{
				case 0:
					TheVisualObject.gotoAndStop(mState+"_talk");
					mBalloon.SetSpeech(mSpeech, Delegate.create(TalkLoop, 1));
				break;
				case 1:
					TheVisualObject.gotoAndStop(mState+"_idle");
					if (mCallBack != null)
						mCallBack();
				break;
			}
		}

		private var mStatus : GameStatus;
		private var mBalloon : Balloon;
		private var mSpeech : Array;
		private var mState : String;

		private var mCallBack : Function;
		private var mCallBackGive : Function;
		private var mCallBackLeave : Function;

	}

}
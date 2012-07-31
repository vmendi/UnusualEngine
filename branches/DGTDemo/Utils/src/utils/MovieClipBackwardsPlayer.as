package utils
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class MovieClipBackwardsPlayer
	{
		public var TargetMC : MovieClip;
		
		public function MovieClipBackwardsPlayer(target : MovieClip)
		{
			TargetMC = target;
		}

		public function GotoAndStopBackwards(toLabel : String):void
		{
			TargetMC.addEventListener(Event.ENTER_FRAME, OnEnterFrame);
			mTargetLabel = toLabel;
		}
		
		private function OnEnterFrame(event:Event):void
		{
			if (TargetMC.currentFrame != MovieClipLabels.GetFrameOfLabel(mTargetLabel, TargetMC))
				TargetMC.prevFrame();
			else
				Stop()
		}
		
		public function Stop() : void
		{
			TargetMC.removeEventListener(Event.ENTER_FRAME, OnEnterFrame);
			mTargetLabel = "";
		}
		
		private var mTargetLabel : String;
	}
}
package GameComponents.ScreenSystem
{
	import flash.display.MovieClip;
	
	public class FadeTransition
	{
		public var TotalTime : Number = 1000;
		
		public function FadeTransition(totalTime : Number)
		{
			TotalTime = totalTime;
		}
		
		public function Transition(oldScreen : MovieClip, targetScreen : MovieClip, elapsedTime : Number): Boolean
		{
			var isFinished : Boolean = false;
			
			mCurrentTime += elapsedTime;
			
			if (mCurrentTime >= TotalTime)
			{
				mCurrentTime = TotalTime;
				isFinished = true;
			}
			
			var interpParam : Number = mCurrentTime / TotalTime;
			oldScreen.alpha = (1-interpParam);
			targetScreen.alpha = interpParam;
			
			return isFinished;
		}

		private var mCurrentTime : Number = 0;
	}
}
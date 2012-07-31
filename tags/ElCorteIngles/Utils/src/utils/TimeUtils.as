package utils
{
	public class TimeUtils
	{
		static public function ConvertMilisecsToString(milisecs:Number) : String
		{
			var totalSeconds : Number = milisecs/1000;
			var minutes : Number = Math.floor(totalSeconds / 60);
			var seconds : Number = Math.floor(totalSeconds % 60);

			var secondsStr : String = seconds < 10? "0"+seconds.toString() : seconds.toString();

			return minutes.toString() + ":" + secondsStr;
		}
	}
}
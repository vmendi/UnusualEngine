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
		
		static public function ConvertSecondsToString(totalSeconds:Number) : String
		{
			var minutes : Number = Math.floor(totalSeconds / 60);
			var seconds : Number = Math.floor(totalSeconds % 60);
			
			var secondsStr : String = seconds < 10? "0"+seconds.toString() : seconds.toString();
			
			return minutes.toString() + ":" + secondsStr;
		}
		
		static public function ConvertSecondsToStringWithHours(totalSeconds:Number) : String
		{
			var hours   : Number = Math.floor(totalSeconds / 3600);
			var minutes : Number = Math.floor((totalSeconds / 60) - (hours * 60));
			var seconds : Number = Math.floor(totalSeconds % 60);
			
			var minutesStr : String = minutes < 10? "0"+minutes.toString() : minutes.toString();
			var secondsStr : String = seconds < 10? "0"+seconds.toString() : seconds.toString();
						
			return hours.toString() + ":" + minutesStr + ":" + secondsStr;
		}
	}
}
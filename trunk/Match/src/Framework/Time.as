package Framework
{
	//
	// Clase para calcular el tiempo que ha pasado
	//
	public class Time
	{
		protected var LastMilliseconds:Number = 0;			// Último valor en milisegundos 
		protected var _LastElapsed:Number = 0;				// Último elapsed time en milisegundos
		
		//
		// Devuelve el tiempo en milisegundos que ha pasado desde la última vez que se llamó a GetElapsed
		//
		public function GetElapsed() : Number
		{
			// Calculamos el tiempo en este instante.
			// NOTE: El objeto 'Date' se recrea, ya que getTime siempre devuelve el valor de tiempo en la creación
			var now:Date = new Date();
			var currentMS:Number = now.getTime();
			
			// Si no se ha pasado nunca por la función asignamos el último valor al actual (elapsed será 0 )
			if( LastMilliseconds == 0 )
				LastMilliseconds = currentMS;
			
			// Calculamos la diferencia de tiempo desde la última vez hasta ahora, y guardamos el valor de ahora
			_LastElapsed = currentMS - LastMilliseconds; 
			LastMilliseconds = currentMS;
			
			return( _LastElapsed ); 
		}
		
		//
		// Obtiene el último elapsed que se calculó en milisegundos
		//
		public function get LastElapsed() : Number
		{
			return _LastElapsed;
		}
		
		
		// -----------------------------------------------------------------------------------------------
		// Utileria para convertir tiempo a formato de cadena
		// 
		
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
		
		//
		// -----------------------------------------------------------------------------------------------
		
					
	}
}
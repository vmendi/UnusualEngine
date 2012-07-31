package GameComponents.Desafiate
{
	public class Checkpoints
	{
		public static const INTRO : String = "INTRO";
		public static const TM01_START : String = "TM01_START";
		public static const INTER01 : String = "INTER01";
		public static const TM02_START : String = "TM02_START";
		public static const INTER02 : String = "INTER02";
		public static const TM03_START : String = "TM03_START";
		public static const END : String = "END";


		// Array para especificar el orden, al crear un checkpoint nuevo es obligatorio insertarlo aqui tb
		public static const ALL : Array = [ INTRO,
											TM01_START,
											INTER01,
											TM02_START,
											INTER02,
											TM03_START,
											END ];


		// Indice de un checkpoint dentro de ALL
		public static function GetIndexOf(checkPoint : String) : int
		{
			var ret : int = -1;
			for (var c:int=0; c < ALL.length; c++)
			{
				if (ALL[c] == checkPoint)
				{
					ret = c;
					break;
				}
			}
			return ret;
		}
	}
}
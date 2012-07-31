package Model
{
	import flash.geom.Point;
	
	public class IsoOrient
	{
		static public const SOUTH_EAST : int = 0;
		static public const SOUTH      : int = 1;
		static public const SOUTH_WEST : int = 2;
		static public const WEST 	   : int = 3;
		static public const NORTH_WEST : int = 4;
		static public const NORTH	   : int = 5;
		static public const NORTH_EAST : int = 6;
		static public const EAST 	   : int = 7;
		
		// Para acceder al nombre a través de STRINGS[NORTH_EAST] por ejemplo
		static public const STRINGS : Array = [ "SE", "S", "SW", "W", "NW", "N", "NE", "E" ];
		
		// Vector en espacio de mundo de cada una de las orientaciones
		static public const VECTORS : Array = [ new Point(0,-1), new Point(-1,-1), new Point(-1,0), new Point(-1,1), 
												new Point(0,1), new Point(1,1),  new Point(1,0), new Point(1,-1) ];
	}
}
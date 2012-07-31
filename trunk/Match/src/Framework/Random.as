//

package Framework
{
	public class Random
	{
		public static var Global:Random = new Random();		// Generador global de números aleatorios
	
		public static const MAX_RAND:int = 0x7fff;		// Valor máximo generado por el RAND
		
		protected var Seed:int = 0;			// Parte baja: Semilla usada para la generación del siguiente número pseudo-aleatorio
		protected var Seed2:int = 0;		// Parte alta: Semilla usada para la generación del siguiente número pseudo-aleatorio
				
		public function Random()
		{
		}

		//
		// Asigna/Obtiene la semilla utilizada para la generación de números aleatorios
		//
		public function SetSeed( seed:int ) : void
		{
			Seed = seed;
		}
		public function GetSeed( ) : int
		{
			return( Seed );
		}
		
		//
		// Genera un numero aleatorio entero entre 0 y MAX_RAND (ambos inclusive)
		//
		public function RandInt() : int
		{
  			//Seed = Seed * 214013L + 2531011L;
  			Seed = Seed * 214013 + 2531011;
  			return ( (Seed >> 16) & MAX_RAND );
		}

		
		//
		// Genera un numero aleatorio entero entre 0 y 1.0 (ambos inclusive)
		//
		public function Rand() : Number
		{
			return( RandRange( 0.0, 1.0 ) );
		}

		//
		// Genera un numero aleatorio entero entre min y max (ambos inclusive)
		//
		/*
		public function Rand( min:int, max:int ) : int
		{
  			// TODO: Verificar min < max!!!!!!!!
  			
  			var sample:int = RandInt();	// Entre 0 y MAX_RAND, ambos inclusive
  			var rand:int = ( sample * (max - min + 1) ) / (MAX_RAND + 1) + min;
  			
  			return( rand ); 
  		}
  		*/

		//
		// Genera un numero aleatorio entero entre min y max (ambos inclusive)
		//
		public function RandRange( min:Number, max:Number ) : Number
		{
  			// TODO: Verificar min < max!!!!!!!!
  			
  			var sample:Number = RandInt() as Number;	// Entre 0 y MAX_RAND, ambos inclusive
  			var rand:Number = ( sample * (max - min) ) / (MAX_RAND) + min;	// Aqui no sumo 1, porque el corte no incluye MAX_RAND con decimales
  			
  			return( rand ); 
  		}
		
		//
		// Devuelve true con el porcentaje de  probabilidad indicado 
		//
		public function Probability( percentProbability:Number ) : Boolean
		{
			var value:Number = RandRange( 0.0, 100.0 );
			if( value <= percentProbability )
				return true;
			return false;
		}
	}

}
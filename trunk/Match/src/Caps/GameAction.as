package Caps
{
	//
	// Describe una acción de juego
	//   - NetUserId
	//	 - Action:
	//     - ShootCap ( idCap, Direction, Force )
	//	   - PosBall ( idCap, Direction )
	//     - UseSkill ( skillId )
	// 
	
	public class GameAction
	{
		// *********** Identificadores de acciones posibles **********
		
		public static const None:int = 0;				// NINGUNA_ACCIÓN!
		
		// Acciones de los jugadores:
		public static const ShootCap:int = 1;			// Lanzamos una chapa con una fuerza y dirección determinadas 
		public static const PosBall:int = 2;			// Posicionamos la pelota en un ángulo de la chapa (se produce en el pase a pie)
		public static const UseSkill:int = 3;			// Usamos una habilidad
		
		public static const PlayerReady:int = 10;		// Jugador listo!
		
		// Acciones del partido:
		
		// Descripción de una acción
		
		private var ActionId:int = None;			// Identificador del tipo de acción
		private var _Params:Object = null;			// Parámetros para cada tipo de acción (son diferentes)
				
		
		// Construye una acción
		public function GameAction( actionId:int, params:Object )
		{
			Id = actionId;
			Params = params;
		}
		
		//
		// Obtiene/Asigna la accion
		//
		public function get Id(  ) : int
		{
			return( ActionId );
		}
		public function set Id( value:int ) : void
		{
			ActionId = value;
		}
		
		//
		// Obtiene/Asigna los parámetros para la acción
		// Los parámetros son objeto con variables dentro diferentes para cada tipo de acción 
		//
		public function get Params(  ) : Object
		{
			return( _Params);
		}
		public function set Params( value:Object ) : void
		{
			_Params = value;
		}
		
		//
		// Indica si la acción es valida
		//
		public function IsValid(  ) : Boolean
		{
			return( ActionId == None ? false : true );
		}
		
		//
		// Obtiene el nombre de la acción
		//
		public function get Name(  ) : String
		{
			var name:String = "";
			
			if( ActionId == None )
				name = "<None>";
			else if( ActionId == PlayerReady )
				name = "<Player Ready>";
			else 
				name = "<Unknown>";
			
			return name; 
		}
	}	
}
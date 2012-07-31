package Caps
{
	//
	// Diferentes enumeraciones que utilizaremos en el juego
	//
	public class Enums
	{
		// Jugador local y remoto
		public static const Team1:int = 0;						// Equipo 1  
		public static const Team2:int = 1;						// Equipo 2
		public static const Count_Team:int = 2;					//
		
		// Lados del campo
		public static const Left_Side:int = 0; 
		public static const Right_Side:int = 1;					 
		public static const Count_Side:int = 2;					
		
		// Colores
		public static const FriendColor:int = 0x00007e;				// Color amigo 
		public static const EnemyColor:int = 0x7e0000;				// Color enemigo
		
		// Razones por las que se cambia el turno		
		public static const TurnByTurn:int = 0;						// Cambio de turno normal
		public static const TurnByStolen:int = 2;					// Cambio de turno por robo de balón
		public static const TurnByFault:int = 3;					// Cambio de turno por falta provocada
		public static const TurnByTiroAPuerta:int = 5;				// El jugador ha declarado tiro a puerta
		public static const TurnByGoalKeeperSet:int = 6;			// El portero del equipo se ha colocado
		public static const TurnBySaquePuerta:int = 7;				// Cambio de turno para que el portero saque de puerta
		public static const TurnBySaquePuertaByFalta:int = 8;		// Cambio de turno para que el portero saque de puerta debido a una falta
		public static const TurnByLost:int = 9;						// La pelota se perdio simplemente porque quedo cerca de un contrario
				
		
		// Skills (van de 1 a 9)
		public static const Superpotencia:int = 1;					// Multiplica por X parámetro de potencia en el turno
		public static const Furiaroja:int = 2;						// Multiplica por X parámetro de ataque en el turno
		public static const Catenaccio:int = 3;						// Multiplica por X parámetro de defensa en el turno
		public static const Tiroagoldesdetupropiocampo:int = 4;		// Permite disparar desde tu propio campo
		public static const Tiempoextraturno:int = 5;
		public static const Turnoextra:int = 6;
		public static const CincoEstrellas:int = 7;					// Multiplicar por X área de influencia pase al pie / Multiplicar por X área de influencia defensa.
		public static const Verareas:int = 8;						// Muestra todas las áreas de un jugador
		public static const Manodedios:int = 9;						// No necesario declarar tiro a puerta
		
		public static const SkillFirst:int = 1;						// Primera skill  
		public static const SkillLast:int = 9;						// Última Skill
		
		
		// Validez/invalidez de un gol
		public static const GoalValid:int = 0;
		public static const GoalInvalidNoDeclarado:int = 1;
		public static const GoalInvalidPropioCampo:int = 2;		
				
		//
		// Obtiene el lado contrario al especificado
		//
		static public function AgainstSide( side:int ) : int
		{
			if( side == Left_Side )
				return( Right_Side );
			//else if( side == Right_Side )
				//return( Left_Side );
			
			return( Left_Side );
		}
	}
}
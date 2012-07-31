package Caps
{
	public class GameState
	{
		public static const Init:int = 1;			// Inicio del partido
		
		public static const NewPart:int = 2;		// Inicio de una parte
		
		public static const WaittingPlayers:int = 3; // Esperando los jugadores
		
		public static const Playing:int = 5;							// Jugando
		public static const WaittingClientsToEndShoot:int = 6;			// Nuestro disparo se ha simulado, esperando a que los demás clientes terminen de simular el disparo
		
		public static const WaitingGoal:int = 10;	// Hemos detectado gol. Estamos esperando a que llegue la confirmación desde el servidor
		
		public static const WaitGeneric:int = 66;	// Estado de espera genérico (no hace nada, se usa para esperar un evento del server que desencadena un callback)
				
		public static const EndPart:int = 15;		// Fin de una parte

		public static const EndGame:int = 20;		// Fin de juego
		
		//public static const First:int = Init;
		//public static const Last:int = EndGame;
	}
}
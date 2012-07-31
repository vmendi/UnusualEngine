package Caps
{
	//
	// Conjunto de parámetros globales a toda la aplicación
	//
	public class AppParams
	{
		public static const ClientVersion:int = 106;			// Versión del cliente
		
		// Opciones para depuración
		public static const DrawBackground:Boolean = true;		// Pintar el fondo del juego ?
		public static const DebugPhysic:Boolean = false;		// Indica si depuramos la física (pintar el mundo físico y otras cosas más )
		public static const DragPhysicObjects:Boolean = false;	// Indica si podemos arrastrar los objetos físicos con el ratón
		
		public static const Debug:Boolean = false;				// Indica que estamos en modo debug. Se habilitan trucos/trazas y similares
		public static var   OfflineMode:Boolean = false;		// Indica si debemos simular un modo Offline (para propósitos de debug)
		
		// Configuración física
		public static const PhyFPS:int = 30;					// La física se ejecuta 30 veces por segundo
		public static const PixelsPerMeter:uint = 30;			// 30 píxeles es igual a 1 metro físico
		
		// Parámetros para el GamePlay		
		public static const RadiusPaseAlPie:int = 18; //30;		// El radio en el cual si se queda la pelota despúes de chocar contigo, se queda en tu pie
		public static const RadiusSteal:int = 18; //25;			// El radio de robo  
				
		public static const MinCapImpulse:Number = 80.0;	// Intensidad MÁXIMA que se le aplica a una chapa cuando se dispara a la máxima potencia (con una chapa de potencia 0)
		public static const MaxCapImpulse:Number = 120.0;	// Intensidad MÁXIMA que se le aplica a una chapa cuando se dispara a la máxima potencia (con una chapa de potencia 100)
		
		public static const MaxHitsPerTurn:int = 2;				// Nº de disparos máximos por turno si no se toca la pelota
		public static const MaxNumPasesAlPie:int = 3;			// No de pases al pie máximos permitidos
		
		public static const DistToPutBallHandling:int = 10;		// Distancia a la chapa a la que colocamos la pelota cuando se recibe un pase al pie
		
		public static const AutoPasePermitido:Boolean = false;	// La chapa con la que se dispara puede recibir pase al pie despues de tocar el balon

		// Porcentaje de la skill restaurado por segundo para cada habilidad
		// NOTE: Las skills van de 1 - 9, el primer valor del array en la linea anterior no se utiliza!
		// 1. Superpotencia
		// 2. Furia Roja
		// 3. Catenaccio
		// 4. Tiro a gol
		// 5. Tiempo extra
		// 6. Tiro extra
		// 7. 5 Estrellas
		// 8. Ver áreas
		// 9. Mano de dios
		public static var PercentSkilLRestoredPerSec:Array = [ 0.0, 
			2.0, 1.5, 1.5, 1.0, 0.2, 0.2, 0.5, 2.0, 0.01   ];

		public static const PowerMultiplier:Number = 2.0;			// Multiplicador de potencia cuando tienes la habilidad especial "superpotencia"
		public static const ControlMultiplier:Number = 2.0;			// Multiplicador de control cuando tienes la habilidad especial
		public static const DefenseMultiplier:Number = 2.0;			// Multiplicador de defensa cuando tienes la habilidad especial
		public static const InfluencesMultiplier:Number = 2.0;		// Multiplicador de los radios de influencia
				
		public static const CoeficienteRobo:Number = 1.00; //1.25;	// Se multiplica al porcentaje de probabilidad de robo
		
		public static const ExtraTimeTurno:Number = 15.0;			// Segundos extras que se obtienen en el turno con la habilidad especial
		
		public static const VelPossibleFault:Number = 3.0;			// Velocidad MÍNIMA que debe existir para que haya posibilidad de falta. Límite inferior de falta al portero
		public static const VelFaultT1:Number = 5.0;				// Límite inferior de falta a un jugador (no portero) y límite inferior de tarjeta amarilla al portero
		public static const VelFaultT2:Number = 11.0;				// Límite inferior de tarjeta amarilla a un jugador y límite inferior de tarjeta roja al portero 
		public static const VelFaultT3:Number = 18.0;				// Límite inferior de tarjeta roja a un jugador
		
		// Parametros generados dentro de la aplicación
		public static var SharingUserName:String = "";		// Nombre de usuario utilizado para el Sharing
		
		//
		// Conversión de unidades de pantalla (pixels) a unidades del motor de física (metros)
		//
		static public function Screen2Physic( val:Number ) : Number
		{
			return( val / PixelsPerMeter );  
		}
		static public function Physic2Screen( val:Number ) : Number
		{
			return( val * PixelsPerMeter );  
		}
		
	}
}
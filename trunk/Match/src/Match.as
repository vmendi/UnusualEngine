package
{
	import Caps.AppParams;
	import Caps.Game;
	
	import Framework.AudioManager;
	import Framework.EntityManager;
	
	import Net.Server;
	
	import com.greensock.TweenMax;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	// NOTES: Especificación de características de nuestra aplicación
	// TODO: Se puede asignar aquí el nombre de la aplicación
	//[SWF(width="800", height="600", frameRate="20", backgroundColor="#445878")]
	[SWF(width="800", height="600")]
	public class Match extends Sprite
	{
		// Temporizadores de la aplicación
		// Cundo se temporiza a menos velocidad de la cual va la película, no se temporiza correctamente
		public static const APP_LOGIC_FPS:int = 30;		// FPS's a los que va la lógica
		public static const APP_DRAW_FPS:int = 30;		// FPS's a los que va el pintado
		private var AppTimer:Timer = null;				// Temporizador para la lógica de la aplicación
		private var DrawTimer:Timer = null;				// Temporizador para el pintado de la aplicación
		
		static private var Instance:Match = null;		// Instancia única de la aplicación
		
		public var DebugArea:MovieClip = new MovieClip();				// Area de pintando de información de debug. Se posiciona por delante de todo
		private var _Game:Caps.Game = new Caps.Game();					// Estructura de juego (y servidor de juego)
		
		public var Formations:Object = null;			// Hash de posiciones de formaciones ["332"][idxCap]
		
		//
		// Punto de entrada de la aplicación
		//
		public function Match()
		{
			// Configuramos el player para que no escale
			if ( stage != null )
			{
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
				trace( "Movie Frame Rate: " + stage.frameRate ); 
			}			
			
			Instance = this;	// Guardamos la instancia única
			
			// Obtenemos el nombre de usuario del "LoaderInfo"
			GetLoaderInfo();
			
			// Añadimos la zona de información de debug (por delante de todo el interface)
			addChild( DebugArea );
						
			// Inicializa el juego
			InitGame();
		}

		//
		// Inicialización del juego a través de una conexión de red que conecta nuestro cliente
		// con el servidor
		// (Deben invocarnos desde el manager)
		//
		// formations: Es un hash que mapea nombre de formación a array de puntos, por ejemplo:
		//             formations["332"] = [ new Point(100, 100), new Point(120, 120), new Point(5, 5) ];
		//
		public function Init( netConnection: Object, formations : Object ): void
		{
			AppParams.OfflineMode = false;	// No permitimos modo Offline si entramos inicializando una conexión
			this.Formations = formations;
						
			if ( netConnection != null )
			{
				Server.Ref.InitConnection( netConnection );
			}
			
			// Indicamos al servidor que nuestro cliente necesita los datos del partido para continuar 
			Server.Ref.Connection.Invoke( "OnRequestData", null );
			
			// Prueba de trackeo del mouse por la película
			if( AppParams.Debug == true )
				stage.addEventListener( MouseEvent.MOUSE_MOVE, MouseMove );
		}
		
		//
		// Inicialización del juego
		//
		public function InitGame( ): void
		{
			// Inicializamos el juego
			Game.Init();
			
			// TODO: Pruebas para visualizar la mecanica de juego
			//CreateSandBox();
			
			// Inicializamos el timer de la aplicación (para la lógica)
			//InitAppTimer();
			
			// NOTE: Utilizamos el frame en vez de timers
			addEventListener(Event.ENTER_FRAME, OnFrame );
		}
		
		//
		// Inicializamos un timer infinito que va a la frecuencia de la aplicación, e invoca "Run" a cada iteración
		//
		private function InitAppTimer() : void
		{
			// Inicializamos un timer infinito que va a la frecuencia de la aplicación, e invoca "Run" a cada iteración
			AppTimer = new Timer( 1000 / APP_LOGIC_FPS, 0 );			
			AppTimer.addEventListener( TimerEvent.TIMER, Run );
			AppTimer.start();
			
			// Inicializamos un timer infinito que va a la frecuencia de la aplicación, e invoca "Run" a cada iteración
			DrawTimer = new Timer( 1000 / APP_DRAW_FPS, 0 );			
			DrawTimer.addEventListener( TimerEvent.TIMER, Draw );
			DrawTimer.start();		
		}  
		
		
		//
		// Bucle principal de la aplicación. 
		// Se invoca a frecuencia constante de pintado del movieclip
		//
		private function OnFrame( event:Event ):void
		{
			if( stage != null && Game != null )
			{
				var elapsed:Number = 1.0 / stage.frameRate;
			
				// Ejecutamos la partida
				if( Game != null  )
				{
					Game.Run( elapsed );
					
					// Ejecuta todas las entidades
					EntityManager.Ref.Run( elapsed );
					
					// Ejecuta todas las entidades en tiempo de pintado
					EntityManager.Ref.Draw( elapsed );
				}
			}
		}			
		
		//
		// Bucle principal de la aplicación. 
		// Se invoca a frecuencia constante APP_LOGIC_FPS x Sec
		//
		private function Run( event:TimerEvent ):void
		{			
			var elapsed:Number = 1.0 / APP_LOGIC_FPS;
			
			// Ejecutamos la partida
			if( Game != null  )
			{
				Game.Run( elapsed );
				
				// Ejecuta todas las entidades
				EntityManager.Ref.Run( elapsed );
			}
		}
		//
		// Bucle principal de PINTADO de la aplicación. 
		// Se invoca a frecuencia constante APP_DRAW_FPS x Sec
		//
		private function Draw( event:TimerEvent ):void
		{			
			var elapsed:Number = 1.0 / APP_DRAW_FPS;
			
			// Ejecuta todas las entidades en tiempo de pintado
			EntityManager.Ref.Draw( elapsed );
		}

		//
		// Carga informacion desde el Loader Info
		// NOTE: El "LoaderInfo" es una propierad de cada DisplayObject. Que identifica el cargador de dicho objeto
		//
		private function GetLoaderInfo(  ):void
		{			
			var username:String = "";
			if( loaderInfo != null && loaderInfo.parameters != null ) 
				username = loaderInfo.parameters.username ? loaderInfo.parameters.username : "";
			//DefaultGameParams.SharingUserName = username;
		}
		
		//
		// Destruimos todo!
		//
		public function Shutdown( ) : void
		{
			// Detenemos los timer y los destruimos
			if( AppTimer != null )
			{
				AppTimer.stop();
				AppTimer = null;
			}
			if( DrawTimer != null )
			{
				DrawTimer.stop();
				DrawTimer = null;
			}
			// Nos desregistramos del frame
			removeEventListener( Event.ENTER_FRAME, OnFrame );

			// Esta parte de cierre de servidor no hará nada, salvo en el caso
			// en el cual se hace un Shutdown sin previamente haber cerrado el Servidor.
			if( Server.Ref.Connection != null )
			{
				throw new Error( "Se ha invocado el Shutdown sin eliminar la conexión!!!!!" );
			}
			
			// Eliminamos los elementos del framework
			EntityManager.Shutdown();
			AudioManager.Shutdown();
			
			// Más cosas a destruir
			TweenMax.killAll();
		}
		
		//
		// El cliente cierra voluntariamente el partido
		//
		public function Finish( ) : void
		{
			// Generamos un cierre voluntario
			if( Game.Interface != null )
				Game.Interface.OnAbandonar( null );
		}
		
		//
		// Propiedades : Accesors
		//
		public function get Game( ) : Caps.Game
		{
			return _Game;
		}
		static public function get Ref( ) : Match
		{
			return Instance;
		}
		
		public function MouseMove( e: MouseEvent ) :void
		{
			trace( "Mouse move recieved in : " + this.mouseX.toString() + "," + this.mouseY.toString() );   
		}
		
	}
}

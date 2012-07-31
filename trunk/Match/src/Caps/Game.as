/**
 * 
 */
package Caps
{
	import Box2D.Common.Math.b2Vec2;
	
	import Embedded.Assets;
	
	import Framework.*;
	
	import Net.Server;
	
	import com.actionsnippet.qbox.QuickBox2D;
	import com.actionsnippet.qbox.QuickContacts;
	import com.greensock.*;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.SharedObject;
	
	import mx.controls.Alert;
	import mx.events.IndexChangedEvent;
	
	import utils.GenericEvent;
	
	//
	// Representa el contenedor principal del juego
	//
	public class Game extends Server
	{
		private var PhysicManager:QuickBox2D = null;			// Manager físico, controla la escena física
		private var _Interface:GameInterface = null;			// Interface de juego
		private var Contacts : QuickContacts;					// Manager para controlar los contactos físicos entre objetos
		
		private var TouchedCaps:Array = new Array();			// Lista de chapas en las que ha rebotado la pelota antes de detenerse 
				
		// Capas de pintado
		public var GameLayer:MovieClip = null;
		public var GUILayer:MovieClip = null;
		public var PhyLayer:MovieClip = null;
		public var ChatLayer:Chat = null;						// Componente de chat
		
		// Obtejos Lógicos de GamePlay
		private var _Field:Field = null;						// El campo
		private var _Teams:Array = new Array();					// Lista de equipos (son siempre dos equipos)
		private var _Ball:BallEntity = null;					// Entidad balon
		
		// Estado lógico de la aplicación
		private var IdxCurTeam:int = Enums.Team1;				// Idice del equipo actual que le toca jugar
		private var State:int = GameState.Init;					// Estado inicial
		private var TicksInCurState:int = 0;					// Ticks en el estado actual
		private var _Part:int = 0;								// El juego se divide en 2 partes. Parte en la que nos encontramos (1=1ª 2= 2ª)
		private var RemainingHits:int = 0;						// Nº de golpes restantes permitidos antes de perder el turno
		private var RemainingPasesAlPie : int = 0;				// No de pases al pie que quedan
		private var TimeSecs:Number = 0;						// Tiempo en segundos que queda de la "mitad" actual del partido	
		public var Timeout:Number = 0;							// Tiempo en segundos que queda para que ejecutes un disparo
		public var TimeOutSent:Boolean = false;					// Controla si se ha envíado el timeout en el último ciclo de subturno
		public var TimeOutPaused:Boolean = false;				// Controla si está pausado el timeout
		
		public var ReasonTurnChanged:int = (-1);				// Razón por la que hemos cambiado al turno actual
		public var LastConflicto:Object = null;					// Último conflicto de robo que se produjo
				 
		private var IsPlaying:Boolean = false;					// Indica si estamos jugando o no. El tiempo de partido solo cambia mientras que estamos jugando
		private var CapShooting:Cap = null;						// Indica la chapa que está disparando, lo utilizamos para evitar el auto-pase
		private var LastPosBallStopped:Point = new Point(0, 0);	// Posición de la pelota antes de disparar
		
		protected var PhySimulating:Boolean = false;			// Bandera que indica si se están moviendo objetos o no
		protected var _SimulatingShoot:Boolean = false;			// Bandera que indica si estamos simulando un lanzamiento
		protected var FramesSimulating:int = 0;					// Contador de frames simulando
		protected var PlayersReady:Boolean = false;				// Bandera que indica cuando los jugadores están listos
		protected var CallbackOnAllPlayersReady:Function = null // Llamar cuando todos los jugadores están listos
		protected var Initialized:Boolean = false;				// Bandera que indica si hemos terminado de inicializar/cargar
		protected var DetectedGoal:Boolean = false;				// Bandera que indica que se ha detectado un gol. Se utiliza para no continuar detectando
		public var DetectedFault:Object = null;					// Bandera que indica Falta detectada (además objeto que describe la falta)
		
		protected var TimeCounter:Framework.Time = new Framework.Time();			// Contador de tiempo 

		public var Config:MatchConfig = new MatchConfig();		// Configuración del partido (Parámetros recibidos del servidor)
		
		public var FireCount:int = 0;							// Contador de jugadores expulsados durante el partido. 

		//
		// Inicialización del juego. Llamado localmente al comenzar
		//
		public function Init() : void
		{
			// Creamos las capas iniciales de pintado para asegurar un orden adecuado
			// TODO: Tenemos que pasar los layers a los sistemas para que se inserten adecuadamente!!
			CreateLayers();
			
			// Inicializamos física
			InitPhysics()
						
			// Creamos el campo
			_Field = new Field();
			_Field.Initialize( GameLayer );
			
			// Creamos el balón
			_Ball = new BallEntity();
			_Ball.Initialize(  );
			EntityManager.Ref.AddTagged( _Ball, "Ball" );
			
			// Creamos las porterias al final para que se pinten por encima de todo
			_Field.CreatePorterias( GameLayer );
			
			// Registramos sonidos para lanzarlos luego 
			AudioManager.AddClass( "SoundCollisionCapBall", Assets.SoundCollisionCapBall );			
			AudioManager.AddClass( "SoundCollisionCapCap", Assets.SoundCollisionCapCap );			
			AudioManager.AddClass( "SoundCollisionWall", Assets.SoundCollisionWall );
			AudioManager.AddClass( "SoundAmbience", Assets.SoundAmbience );
			
			// En modo offline : Inicializamos el partido
			// De otra forma nos lo deberá indicar el servidor
			if( AppParams.OfflineMode )
			{
				var descTeam1:Object = { 
					PredefinedTeamName: "Atlético",
					SpecialSkillsIDs: [ 1, 4, 5, 6, 7, 8, 9 ]
				}
				var descTeam2:Object = { 
					PredefinedTeamName: "Sporting",
					SpecialSkillsIDs: [ 7, 1, 3]
				}
					
				InitMatch( (-1), descTeam1, descTeam2, Enums.Team1, Config.PartTime * 2, Config.TurnTime, AppParams.ClientVersion  );
			}
		}
		
		/*
		public class RealtimePlayerData
		{
			public class SoccerPlayerData
			{
				public int	  Number;		// Dorsal
				public String Name;			
				public int    Power;
				public int    Control;
				public int    Defense;
			}
			
			public String Name;								// Nombre del equipo del player
			public String PredefinedTeamName;				// El player tiene un equipo real asociado: "Getafe"
			public int TrueSkill;							// ...Por si acaso hay que mostrarlo
			public List<int> SpecialSkillsIDs;				// Del 1 al 9
			public String Formation;						// Nombre de la formacion: "331", "322", etc..
			
			// Todos los futbolistas, ordenados según la posición/formacion. Primero siempre el portero.
			public List<SoccerPlayerData> SoccerPlayers;	
		}
		*/

		// Inicialización de los datos del partido. Invocado desde el servidor cuando le envíamos la petición de datos
		public function InitMatch( matchId:int, descTeam1:Object, descTeam2:Object, idLocalPlayerTeam:int, matchTimeSecs:int, turnTimeSecs:int, minClientVersion:int ) : void
		{
			// Verificamos la versión mínima de cliente exigida por el servidor.
			// Si no tenemos la versión correcta no podemos continuar
			if( AppParams.ClientVersion < minClientVersion )
			{
				throw new Error("El cliente no es la última versión. Limpie la caché de su navegador. Client Version: " + AppParams.ClientVersion + " Min Client Version required: " + minClientVersion );  
			}
			
			var name1:String = descTeam1.PredefinedTeamName;
			var name2:String = descTeam2.PredefinedTeamName;
			
			trace( "InitMatch: " + matchId + " Teams: " + name1 + " vs. " + name2 + " LocalPlayer: " + idLocalPlayerTeam ); 
			
			// Inicializamos la semilla del generador de números pseudo-aleatorios, para asegurar el mismo resultado
			// en los aleatorios de los jugadores
			// TODO: Deberiamos utilizar una semilla envíada desde el servidor!!!
			Framework.Random.Global.SetSeed( 1234567 ); 
						
			// Asignamos los tiempos del partido y turno
			Config.MatchId = matchId;
			Config.PartTime = matchTimeSecs / 2;
			Config.TurnTime = turnTimeSecs;
			if( AppParams.Debug == true )		// En modo debug tenemos 5 veces más de timeout
			{
				Config.TurnTime *= 4;
				this.Config.TimeToPlaceGoalkeeper *= 2;
			}
			
			// Asignamos el identificador del jugador local (a quien controlamos nosotros desde el cliente)
			Server.Ref.IdLocalUser = idLocalPlayerTeam;
						
			// Determinamos la equipación a utilizar en cada equipo.
			//   - Determinamos los grupos de equipación a los que pertenece cada equipo.
			//	 - Si son del mismo grupo:
			//		   - El jugador que NO es el LocalPlayer utiliza la equipación secundaria			
			var useSecondaryEquipment1:Boolean = false;
			var useSecondaryEquipment2:Boolean = false;
			
			var group1:int = Team.GroupTeam( descTeam1.PredefinedTeamName );
			var group2:int = Team.GroupTeam( descTeam2.PredefinedTeamName );
			if( group1 == group2 )
			{
				trace( "Los equipos pertenecen al mismo grupo de equipación. Utilizando equipación secundaria para el equipo contrario" ); 
				if( idLocalPlayerTeam == Enums.Team1 )
					useSecondaryEquipment2 = true;
				if( idLocalPlayerTeam == Enums.Team2 )
					useSecondaryEquipment1 = true;
			}
			
			// Creamos los dos equipos (utilizando la equipación indicada)
				
			var team1:Team = CreateTeam();
			team1.Init( descTeam1, Enums.Team1, useSecondaryEquipment1 );
			var team2:Team = CreateTeam();
			team2.Init( descTeam2, Enums.Team2, useSecondaryEquipment2 );
			
			// Inicializamos el interfaz de juego
			// NOTE: Es necesario que estén construidos los equipos
			_Interface = new GameInterface();
			Interface.Init();
			
			// Comienza la simulación física!!
			PhysicManager.start();
			
			// Indicamos que hemos terminado de cargar/inicializar
			Initialized = true;
			
			// Lanzamos el sonido ambiente, como música para que se detenga automaticamente al finalizar 
			AudioManager.PlayMusic( "SoundAmbience", 0.3 );
			
			// Obtenemos variables desde la URL de invocación
			/*
			var debug:Boolean = FlexGlobals.topLevelApplication.parameters.debug;
			if( debug == true )
			{
				// debug: Prueba de ralentizar un cliente
				//Match.Ref.stage.frameRate = 5;
				
				
				// debug: Prueba de retrasar la inicialización para encontrar errores!	
				Initialized = false;
				TweenMax.delayedCall (60.0, function():void 
										   {
												Initialized = true;
											} );  

			}
			*/
		}
			
			
		//
		// Inicializamos la parte física
		//
		public function InitPhysics() : void
		{
			// FRIM: Frame Rate independent Motion
			// True = Lla velocidad de la máquina y del stage no afecta al resultado, siempre dura lo mismo
			// False = La velocidad de la máquina y del stage afecta al resultado ya que cada iteración simplemente se avanza un paso. Buena para sincronía de red
			PhysicManager = new QuickBox2D( PhyLayer, { debug: AppParams.DebugPhysic, iterations: AppParams.PhyFPS, frim: false } );
			PhysicManager.gravity = new b2Vec2( 0, 0 );
			PhysicManager.createStageWalls( );
			
			// Habilitamos la posibilidad de arrastrar los cuerpos con el ratón
			if( AppParams.DragPhysicObjects == true )
				PhysicManager.mouseDrag( );
			
			// Nos registramos para sabes los contactos que se producen entre cuerpos
			Contacts = PhysicManager.addContactListener( );
			Contacts.addEventListener( QuickContacts.ADD, OnContact);
			Contacts.addEventListener( QuickContacts.RESULT, OnContact);
		}
		
		//
		// Bucle principal de la aplicación. 
		// Se invoca a frecuencia constante APP_LOGIC_FPS / Sec
		// elapsed: Tiempo que ha pasado en segundos
		//
		public function Run( elapsed:Number ) : void
		{
			// Actualizamos el estado de si estamos o no simulando
			CheckSimulating();
			
			// Ejecutamos los equipos
			if( Teams[ Enums.Team1 ] != null ) 
				Teams[ Enums.Team1 ].Run( elapsed );
			if( Teams[ Enums.Team2 ] != null )
				Teams[ Enums.Team2 ].Run( elapsed );
			
			// Calculamos el tiempo "real" que ha pasado, independiente del frame-rate
			var realElapsed:Number = TimeCounter.GetElapsed();
			realElapsed = realElapsed / 1000; 
			
			// Actualizamos el tiempo del partido (si estamos jugando)
			if( Playing == true )
			{
				TimeSecs -= realElapsed;
				
				if( TimeSecs <= 0 )
				{
					TimeSecs = 0;
					// En modo offline terminamos la parte si alcanzamos 0 de tiempo
					if( AppParams.OfflineMode )
						FinishPart( _Part, null );
				}
				
				// Mientras que se está realizando una simulación de un disparo o está ejecutando el cambio de turno, 
				// o estamos pausados, no se resta el timeout
				if( (!_SimulatingShoot) && (!this.TimeOutPaused) && (!Interface.CutSceneTurnRunning))
				{
					Timeout -= realElapsed;
					
					// Si se acaba el tiempo disponible del subturno, lanzamos el evento timeout y aseguramos que solo se mande una vez
					// NOTE: El evento de timeout solo se manda por el juador local activo.
					// NOTE: En modo offline simulamos la respuesta del server
					if( Timeout <= 0 && (!TimeOutSent) )
					{
						if( AppParams.OfflineMode )
							OnTimeout( this.CurTeam.IdxTeam );
						else if( this.CurTeam.IsLocalUser )
						{
							// Una vez envíado el tiemout no le permitimos al jugador local utilizar el interface
							EnableUserInput( false );
							Server.Ref.Connection.Invoke( "OnServerTimeout", null );
							TimeOutSent = true;		// Para que no volvamos a envíar el timeout!
						}
					}
				}

				// Actualizamos el interface visual
				Interface.Update( ); 
			}
							
			switch( State )
			{
				//
				// 
				// 
				case GameState.Init:
				{
					_Part = 1;
					
					Playing = false;				// Indica si estamos jugando o no. El tiempo de partido solo cambia mientras que estamos jugando 
										
					// Comenzamos la primera parte si los jugadores están listos
					if( Initialized == true )
					{
						ChangeState( GameState.NewPart );
					}
					
					break;
				}
				
				//
				// Nueva parte del juego! (Se divide en 2  mitades) 
				// 
				case GameState.NewPart:
				{
					TimeSecs = Config.PartTime;		// Reseteamos el tiempo del partido

					// Dependiendo de en que parte estamos, saca un equipo u otro.
					// NOTE: Solo asinamos la variable. No utilizamos la función pq no queremos mostrar el panel de turno todavía
					if( Part == 1 )
						IdxCurTeam = Enums.Team1; // SetTurn( Enums.Team1, false );
					else if( Part == 2 ) 
						IdxCurTeam = Enums.Team2; // SetTurn( Enums.Team2, false );
					
					// El interface comienza desactivado
					Interface.UserInputEnabled = false;
					
					// Espera a los jugadores y comienza del centro 
					StartCenter();
					break;
				}
					
				//
				// Esperando confirmación de los jugadores para comenzar una mitad de partido (1ª o 2ª)
				// Receibiremos una notificación del servidor PlayerReady, al tener las de todos los jugadoremos pasaremos a
				// StartCenterAllReady
				// 
				case GameState.WaittingPlayers:
				{
					break;
				}

				//
				// 
				// 
				case GameState.Playing:
				{
					// Detectamos cuando hemos disparado sobre una chapa y la simulación física ha terminado
					// SimulatingShoot se activa al disparar, pero no se desactiva nada más que cuando pasamos por 'OnShootSimulated'
					if( _SimulatingShoot == true )
					{
						// Contabilizamos el numero de frames que dura la simulación física del disparo
						FramesSimulating ++;

						// Si la física ha terminado de simular quiere decir que en nuestro cliente hemos terminado la simulación del disparo.
						// Se lo notificamos al servidor y nos quedamos a la espera de la confirmación de ambos jugadores
						if( IsPhysicSimulating == false )
						{
							// Indicamos al servidor que hemos terminado la simulación del disparo
							if( !AppParams.OfflineMode )
								Server.Ref.Connection.Invoke( "ClientEndShoot", null );
															
							// Hasta que todos los clientes no indiquen que han terminado la simulación, no tomaremos ninguna decisión
							trace( "Finalizado nuestra simulacion de disparo, esperando al otro usuario" );
							
							// Nos ponemos en modo espera de respuesta
							ChangeState( GameState.WaittingClientsToEndShoot );
						}
					}
					
					// Se encarga de mostrar los radios de influencias
					ShowInfluences( );
											
					break;
				}
					
				//
				// Nuestro disparo ya se ha simulado.
				// Esperando a que TODOS los demás clientes indiquen que han terminado la simulación
				// Recibiremos una notificacion desde el servidor "OnShootSimulated"
				//
				case GameState.WaittingClientsToEndShoot:
				{
					// En modo offline simulamos que nos llega el mensaje de que todos los clientes ya han simulado
					if( AppParams.OfflineMode )
						OnShootSimulated();
					break;
				}
					
				//
				// Hemos detectado gol en el cliente.
				// Estamos esperando a que llegue la confirmación desde el servidor 'OnGoalScored'
				// 
				case GameState.WaitingGoal:
				{
					break;
				}
					
				//
				// Estado de espera genérico (no hace nada, se usa para esperar un evento del server que desencadena un callback) 
				// 
				case GameState.WaitGeneric:
				{
					break;
				}
					
				//
				// NOTE: Solo se pasa por aquí al terminar la 1ª parte, al finalizar la segunda va directamente por Finish 
				// 
				case GameState.EndPart:
				{
					_Part++;	// Pasamos a la siguiente parte
					
					// Cambiamos a los equipos de lado de campo
					Teams[ Enums.Team1 ].InvertedSide();
					Teams[ Enums.Team2 ].InvertedSide();
					
					// Decidimos el siguiente estado en función de la mitad en la que nos encontramos 
					if( Part == 2 )
						ChangeState( GameState.NewPart );
					else if( Part == 3 )
					{
						throw new Error (IDString + "No deberíamos pasar por EndPart en la segunda parte" );
					}
					
					break;
				}
				
				//
				// 
				// 
				case GameState.EndGame:
				{
					break;
				}
			}
			
		
		}
		
		//
		// Transforma una lista de chapas en una array de chapas listo para ser enviado por red
		//
		/*
		protected function GetListToSend( capList:Array ) : Array
		{
			var listToSend:Array = new Array();
			
			for each( var cap:Cap in capList )
			{
				if( cap != null )
				{
					var desc:Object = { Id: cap.Id, x:cap.GetPos().x, y:cap.GetPos().y };
					listToSend.push( desc );
				}
			}
			
			return listToSend;
		}
		*/
		protected function GetString( capList:Array ) : String
		{
			var capListStr:String = "";
			
			for each( var cap:Cap in capList )
			{
				/*
				capListStr += 	"[Id:" +cap.Id +
								" x:" + cap.GetPos().x +
								" y:" + cap.GetPos().y + 
								"]";
				*/
				if( cap != null )
					capListStr += 	"[" +cap.Id + ":"+cap.GetPos().toString() + "]";
			}
			
			return capListStr;
		}
		
		
		//
		// Determina si estamos o no jugando.
		// El partido se detiene en numerosos eventos (goles, cambio de partes, ...)
		//
		public function get Playing() : Boolean
		{
			return IsPlaying;
		}
		public function set Playing( value:Boolean ) : void
		{
			if( IsPlaying != value )
			{
				IsPlaying = value;
			}
		}
		
		//
		// Crea los layers de pintado (MovieClip) para el juego, interface gráfico de usuario y física
		// De esta forma aseguramos el orden de pintado
		// TODO: Esta función debería pertenecerle a la aplicación???
		//
		public function CreateLayers() : void
		{
			GameLayer = new MovieClip();
			GUILayer = new MovieClip();
			PhyLayer = new MovieClip();
			
			Match.Ref.addChild( GameLayer );
			Match.Ref.addChild( PhyLayer );
			Match.Ref.addChild( GUILayer );
			
			// Nuestra caja de chat... hemos probado a anadirla a la capa de GUI (Match.Ref.Game.GUILayer), pero: 
			// - Necesitamos que el chat tenga el raton desactivado puesto que se pone por encima del campo
			// - Los movieclips hijos hacen crecer al padre, en este caso la capa de GUI.
			// - La capa de GUI sí que está mouseEnabled, como debe de ser, así q es ésta la que no deja pasar el ratón
			//   hasta el campo.
			ChatLayer = new Chat();
			Match.Ref.addChild(ChatLayer);
		}
		
		//
		// Creamos uno de los equipos
		//
		public function CreateTeam() : Team
		{
			// Creamos el equipo y lo agregamos a la lista
			var team:Team = new Team();
			_Teams.push( team );
			
			return team;
		}
		
		//
		// Propiedades : Accesors
		//
		public function get Interface( ) : GameInterface
		{
			return _Interface;
		}
		public function get Physic() : QuickBox2D
		{
			return PhysicManager;
		}
		public function get CurTeam() : Team
		{
			return( _Teams[ IdxCurTeam ] );
		}
		public function get LocalUserTeam() : Team
		{
			return( _Teams[ Server.Ref.IdLocalUser ] );
		}
		
		public function get Teams() : Array
		{
			return( _Teams );
		}
		public function get Part() : int
		{
			return( _Part );
		}
		
		public function GetField() : Field
		{
			return( _Field );
		}
		// Obtiene el tiempo trancurrido en el partido (en segundos) 
		public function get Time() : Number
		{
			return( TimeSecs );
		}
		public function get Ball() : BallEntity
		{
			return( _Ball );
		}
		
		
		//
		// Cambiamos al estado indicado
		// NOTE: Siempre utilizar este metodo para cambiar el estado
		//
		public function ChangeState( newState:int ) : void
		{
			if( State != newState )
			{
				State = newState;
				TicksInCurState = 0;		// Reseteamos los ticks dentro del estado actual
			}
		}
		
		//
		// Se llama cada vez que 2 cuerpos físicos producen un contacto
		// NOTE: - Lo utilizamos para detectar cuando se produce gol
		//		 - Detectar faltas
		//		 - Generamos un historial de contactos entre chapas, para despues determinar pase al pie
		//
		private function OnContact( e: Event ): void
		{
			// Si se ha detectado anteriormente gol, ignoramos los contactos
			if( DetectedGoal || DetectedFault)
				return;
				
			if( e.type == QuickContacts.ADD )
			{
				// Detectamos GOL: Para ello comprobamos si ha habido un contacto entre los sensores de las porterías y el balón
				var sideGoal:int = (-1);
				
				if( Contacts.isCurrentContact( _Ball.PhyBody, _Field.GoalLeft ) )
				{
					sideGoal = Enums.Left_Side;	
				}
				else if( Contacts.isCurrentContact( _Ball.PhyBody, _Field.GoalRight ) )
				{
					sideGoal = Enums.Right_Side;	
				}
				
				if( sideGoal != (-1) )
				{
					// Indicamos que hemos detectado gol, para evitar que se siga detectando y puntuemos más veces
					// En el estado StartCenter se restaura este valor.
					DetectedGoal = true;
					// Cambiamos al estado esperando gol, para que no se pase turno al detenerse la pelota o similares
					this.ChangeState( GameState.WaitingGoal );
					
					// Determinamos que equipo ha marcado gol: El equipo que está en el lado contrario a la portería donde ha entrado la pelota 
					var player:Team = TeamInSide( Enums.AgainstSide( sideGoal ) );
					
					// Comproba si ha metido un gol válido, para ello se debe cumplir lo siguiente:
					//	 - El jugador debe haber declarado "Tiro a Puerta"
					//   - El jugador que ha marcado ha lanzado la pelota desde el equipo contrario (no puedes meter gol desde tu campo) a no ser
					//	   que tenga la habilidad especial de "Tiroagoldesdetupropiocampo"
					//	   > También es válido si es en gol en propia meta
					//
					// Si el gol ha sido en propia meta siempre es válido (no evaluamos tiro declarado, etc)
					var validity : int = Enums.GoalValid;
					
					if( this.CapShooting != null && CapShooting.OwnerTeam == player )		
					{
						if (!IsTeamPosValidToScore())
							validity = Enums.GoalInvalidPropioCampo;				
						else
						if (!TiroPuertaDeclarado())
							validity = Enums.GoalInvalidNoDeclarado;
					}
					
					// Envíamos la acción al servidor para que la propague a los 2 clientes y asignamos el modo de espera que se encarga
					// de desactivar interface y pausar el time-out
					if( !AppParams.OfflineMode )
					{
						Server.Ref.Connection.Invoke( "OnGoalScored", null, player.IdxTeam, validity );
						Interface.WaitResponse();
					}
					else
						Match.Ref.Game.OnGoalScored( player.IdxTeam, validity );
					
					trace( "Gol detectado en cliente! Esperamos confirmación del servidor. Validity=" + validity.toString() );
				}
			}
			
			// ------------------------------------------------------------------------------------------
			// Generamos un historial de contactos entre chapas, para despues determinar pase al pie
			// ------------------------------------------------------------------------------------------			
			if( e.type == QuickContacts.RESULT )
			{
				// Obtenemos las entidades que han colisionado (están dentro del userData de las shapes)
				var ent1:PhyEntity = Contacts.currentResult.shape1.m_userData as PhyEntity;
				var ent2:PhyEntity = Contacts.currentResult.shape2.m_userData as PhyEntity;
				
				var ball:BallEntity = null;
				var cap:Cap = null;
								
				// Determinamos si una de las entidades colisionadas es el balón
				if( ent1 is BallEntity )
					ball = ent1 as BallEntity;
				if( ent2 is BallEntity )
					ball = ent2 as BallEntity;
				
				// Determinamos si una de las entidades colisionadas es una chapa
				if( ent1 is Cap )
					cap = ent1 as Cap;
				if( ent2 is Cap )
					cap = ent2 as Cap;
				
				// Tenemos una colisión entre una chapa y el balón? Si es así guardamos la
				// chapa en una lista para comprobar posibles "Pase al pie" a la misma
				if( cap != null && ball != null )
				{
					TouchedCaps.push( cap );
					AudioManager.Play( "SoundCollisionCapBall" );
				}
				else
				{
					// chapa / chapa
					if( ent1 is Cap && ent2 is Cap )
						AudioManager.Play( "SoundCollisionCapCap" );
					// chapa / muro 
					else if( cap != null && ( ent1 == null || ent2 == null ) ) 
						AudioManager.Play( "SoundCollisionWall" );
					// balón / muro 
					else if( ball != null && ( ent1 == null || ent2 == null ) )
						AudioManager.Play( "SoundCollisionWall" );
				}
				
				//-----------------------------------------------------------
				// Colsisión entre 2 chapas: EVALUAMOS POSIBLE FALTA
				//-----------------------------------------------------------
				
				if( ent1 is Cap && ent2 is Cap )
				{
					DetectedFault = DetectFault( Cap(ent1), Cap(ent2) );
					if( DetectedFault != null )
					{
						// Detenemos la simulación física y creamos un descriptor de falta 
						// NOTE: Al denener la simulación se detectará en el próximo tick que se ha terminado el disparo y se procesará la respuesta
						StopSimulation();
					}
				}
			}
		}
		
		//
		// Detecta una falta entre las dos chapas y retorno un objeto de falta que describe lo ocurrido
		// Además contabiliza las tarjetas amarillas
		//
		// ( Conflicto de jugadores, tarjetas, ... )
		//
		private function DetectFault( cap1:Cap, cap2:Cap ) : Object		
		{
			var fault:Object = null;
			
			// Las 2 chapas son del mismo equipo? Entonces ignoramos, no puede haber falta. 
			if( cap1.OwnerTeam != cap2.OwnerTeam )
			{
				// La chapa del equipo que tiene el turno es el ATACANTE, quien puede provocar faltas.
				// Detectamos que chapa es de las dos
				var attacker:Cap = null;
				var defender:Cap = null;
				if( cap1.OwnerTeam == CurTeam )
				{
					attacker = cap1;
					defender = cap2;
				}
				else if( cap2.OwnerTeam == CurTeam )
				{
					attacker = cap2;
					defender = cap1;
				}
				
				// Calculamos la velocidad con la que ha impactado 
				var vVel:b2Vec2 = attacker.PhyBody.body.GetLinearVelocity()
								
				// Calculamos la velocidad proyectando sobre el vector diferencial de las 2 chapas, de esta
				// forma calculamos el coeficiente de impacto real y excluye rozamientos
				var vecDiff:Point = defender.GetPos().subtract( attacker.GetPos() );
				vecDiff.normalize( 1.0 );
				var vel:Number = vVel.x * vecDiff.x + vVel.y * vecDiff.y;
				
				// Si excedemos la velocidad de 'falta' determinamos el tipo de falta
				if( vel >= AppParams.VelPossibleFault )
				{
					// Se considera falta sólo si el jugador ATACANTE no ha tocado previamente la pelota
					if( !HasTouchedBall( attacker ) )
					{
						// Creamos el objeto que describe la 'falta'
						fault = new Object();
						fault.Attacker = attacker;
						fault.Defender = defender;
						fault.YellowCard = false;
						fault.RedCard = false;
						fault.SaquePuerta = false;

						trace( "DETECTADA POSIBLE FALTA ENTRE 2 JUGADORES" );
						
						// Comprobamos si la falta ha sido al portero dentro de su area pequeña
						if( defender == defender.OwnerTeam.GoalKeeper && 
							Match.Ref.Game.GetField().IsCircleInsideArea( defender.GetPos(), 0, defender.OwnerTeam.Side) )
						{
							// Caso especial: Todo el mundo vuelve a su posición de alineación y se produce un saque de puerta.
							fault.SaquePuerta = true;
							
							// Evaluamos la gravedad de la falta. Para el portero la evaluación de tarjetas es más sensible!
							if( vel < AppParams.VelFaultT1 )	// falta normal. es el valor por defecto
								trace ( "Resultado: falta normal" )
							else if( vel < AppParams.VelFaultT2 )
								AddYellowCard( fault );	// Sacamos tarjeta amarilla (y roja si acumula 2)
							else
								fault.RedCard = true;	// Marcamos tarjeta roja
						}
						/*
						// Comprobamos caso de penalti : Falta a cualquier chapa en el area grande contrario
						else if( Match.Ref.Game.GetField().IsCircleInsideBigArea( defender.GetPos(), 0, attacker.OwnerTeam.Side) )
						{
							// TODO: PENALTIE!!!
							throw new Error( "Implementar penaltie" );
						}
						*/
						else
						{
							if( vel < AppParams.VelFaultT1 )		// La falta más leve en el caso general no es falta 
								fault = null;
							else if( vel < AppParams.VelFaultT2 )	// falta normal. es el valor por defecto
							{
								trace ( "Resultado: falta normal" )
							}
							else if( vel < AppParams.VelFaultT3 )	// Sacamos tarjeta amarilla (y roja si acumula 2)
								AddYellowCard( fault );
							else									// // Sacamos tarjeta roja (Caso de máxima fuerza) 
								fault.RedCard = true;	// Marcamos tarjeta roja	
						}
					}
				}
			} 
			
			return fault;
		}
		private function AddYellowCard( fault:Object ) : void		
		{
			// Marcamos tarjeta amarilla, la contabilizamos y si llevamos 2 marcamos roja
			fault.YellowCard = true;
			fault.Attacker.YellowCards ++;
			if( fault.Attacker.YellowCards >= 2 )
				fault.RedCard = true;
		}
		
		//
		// Comprueba si el motor físico está simulando 
		// Para saber esto iteramos por todas las entidades y comprobamos si se están moviendo 
		private function CheckSimulating() : Boolean		
		{
			var bSimulating:Boolean = false;
			
			for each( var entity:Entity in EntityManager.Ref.Items )
			{
				if( entity is PhyEntity )
				{
					var phyEntity:PhyEntity = entity as PhyEntity;
					if( phyEntity.IsMoving == true )
					{						
						bSimulating = true;
						break;
					}
				}
			}
			
			PhySimulating = bSimulating;
			
			return( bSimulating );
		}
		
		//
		// Detiene la simulación física de todas las entidades 
		// 
		private function StopSimulation() : void		
		{
			for each( var entity:Entity in EntityManager.Ref.Items )
			{
				if( entity is PhyEntity )
				{
					var phyEntity:PhyEntity = entity as PhyEntity;
					//if( phyEntity.IsMoving == true )
					{						
						phyEntity.StopMovement();
					}
				}
			}			
		}
		
		//
		// Retorna si estamos o no simulando la física
		// NOTE: Para que el resultado sea correcto debe invocarse en cada ciclo
		// el método CheckSimulating que actualiza el estado del valor devuelto en
		// este método
		//
		public function get IsPhysicSimulating() : Boolean
		{
			return PhySimulating;
		}
		
		
		//
		// Recibimos una "ORDEN" del servidor : "Disparar chapa" 
		// Signature: int targetID, float dirX, float dirY, float force
		//
		public function OnShoot( playerId:int, capID:int, dirX:Number, dirY:Number, force:Number  ) : void
		{
			// Reseteamos el tiempo de juego al efectuar un lanzamiento
			ResetTimeout();
			
			// Obtenemos la chapa que dispara
			var cap:Cap = GetCap( playerId, capID );
			if( playerId != this.CurTeam.IdxTeam )
				throw new Error(IDString + "Ha llegado un orden Shoot de un jugador que no es el actual: Shoot: Player: "+playerId + " Cap: " +capID + " RTC: " + ReasonTurnChanged );
			
			// Aplicamos habilidad especial
			if( cap.OwnerTeam.IsUsingSkill( Enums.Superpotencia ) )
			{
				force *= AppParams.PowerMultiplier;
			}
			
			// Ejecutamos el disparo en la dirección/fuerza recibida
			cap.Shoot( new Point( dirX, dirY ), force );
			
			// Indicamos que estamos simulando el disparo y guardamos la chapa que está disparando
			SimulatingShoot = true;
			CapShooting = cap;
			
			// ... el turno de lanzamiento no se consume hasta que se detenga la pelota
		}
		
		public function get SimulatingShoot( ) : Boolean
		{
			return _SimulatingShoot;
		}
		
		//
		// Indica que se ha comenzado o terminado de simular un disparo
		// NOTE: Siempre que se asigna este valor se restaura la lista de chapas tocadas
		//
		public function set SimulatingShoot( value:Boolean ) : void
		{
			// Obviamos asignaciones redundantes
			if( value != _SimulatingShoot )
			{
				// Si comienza una simulación de disparo o se termina, guardamos la posición del balón 
				// (para detectar goles desde tu campo)  
				//if( value == true )
				{
					LastPosBallStopped = Ball.GetPos();	
				}
					
				_SimulatingShoot = value;
			
				// Cada vez que empieza un disparo, reseteamos el contador de frames que ha tardado la simulación del disparo
				if( value == true )
					FramesSimulating = 0;
			}
			
			TouchedCaps.length = 0;		// Vacíamos la lista de chapas tocadas
			// Si hemos terminado la simulación, borramos la referencia a la chapa que está disparando 
			if( value == false )
				CapShooting = null;
		}
		
		//
		// El servidor nos indica que todos los clientes han terminado de simular el disparo! 
		// Evaluamos el resultado producido: ( normal, pase al pie, robo, ...)	
		//
		public function OnShootSimulated( ) : void
		{
			// Si estamos esperando la recepción de un gol, simplemente ignoramos el final de la simulación
			if( this.State == GameState.WaitingGoal )
				return;
				
			
			// Confirmamos que estamos esperando la confirmación del server de finalización de simulación
			if( this.State == GameState.WaittingClientsToEndShoot )
			{				
				var result:int = 0;
				
				// Al acabar el tiro, movemos el portero a su posición de formación en caso de saque de puerta.
				// Lo de olvidar el ReasonTurnChanged antes se hacia en OnShoot, pero como necesitamos recordar hasta el final
				// del tiro que esto ha sido un saque de puerta, ahora lo hacemos aquí.
				if ( ReasonTurnChanged == Enums.TurnBySaquePuerta || ReasonTurnChanged == Enums.TurnBySaquePuertaByFalta   )
				{
					this.CurTeam.ResetToCurrentFormationOnlyGoalKeeper();
					ReasonTurnChanged = Enums.TurnByTurn;
				}
				
				// Comprobamos si hay pase al pie:
				//   - Cuando se ha efectuado un disparo de chapa y la simulación física ha terminado 
				// 	 - La pelota debe quedarse dentro del radio de pase al pie del jugador
				var paseToCap:Cap = GetPaseAlPie();
				
				// Si se ha producido UNA FALTA cambiamos el turno al siguiente jugador como si nos hubieran robado la pelota
				// + caso saque de puerta  
				if( DetectedFault != null )
				{
					var attacker:Cap = DetectedFault.Attacker;
					var defender:Cap = DetectedFault.Defender;
					
					// Aplicamos expulsión del jugador si hubo tarjeta roja
					if( DetectedFault.RedCard == true )
					{
						result = 1;
						
						// Destruimos la chapa del equipo!
						attacker.OwnerTeam.FireCap( attacker );
					}
					else	// Hacemos retroceder al jugador que ha producido la falta
					{
						result = 2;
						
						// Calculamos el vector de dirección en el que haremos retroceder la chapa atacante
						var dir:Point = attacker.GetPos().subtract( defender.GetPos() );
						
						// Movemos la chapa en una dirección una cantidad (probamos varios puntos intermedios si colisiona) 
						Match.Ref.Game.GetField().MoveCapInDir( attacker, dir, 80, true, 4 );
					}
					
					// Tenemos que sacar de puerta?
					if( DetectedFault.SaquePuerta == true )
					{
						this.SaquePuerta( defender.OwnerTeam, true );							
					}
						// En caso contrario, Pasamos turno al otro jugador, pero SIN habilitarle el interface de entrada (indicamos que pasamos de turno por falta)
					else
					{	
						NextTurn( false, Enums.TurnByFault );	 
						if( defender.OwnerTeam.IsLocalUser )
							Interface.ShowHandleBall( defender );
					}
					
					// Reseteamos el objeto de falta
					DetectedFault = null;
				}
					// Si se ha producido pase al pie, debemos comprobar si alguna chapa enemiga está en el radio de robo de pelota
				else if( paseToCap != null )
				{
					// Comprobamos si alguien del equipo contrario puede robar el balón al jugador que le hemos pasado y obtenemos el conflicto
					LastConflicto = new Object();
					
					var stealer:Cap = CheckConflictoSteal( paseToCap, LastConflicto );
					var stolenProduced:Boolean = false;
					
					if( stealer != null )
						stolenProduced = this.ResolveConflicto( LastConflicto );
					
					// Si se produce el robo, activamos el contralador de pelota al usuario que ha robado el pase y pasamos el turno
					if( stolenProduced )
					{
						result = 4;
						
						// TODO: Muchas cosas a la vez esto probablemente en arquitectura de red dará problemas
						// Pasamos turno al otro jugador, pero SIN habilitarle el interface de entrada (indicamos que pasamos de turno por robo)
						NextTurn( false, Enums.TurnByStolen );
						if( stealer.OwnerTeam.IsLocalUser )
							Interface.ShowHandleBall( stealer );
					}
					else
					{
						// Si nadie consiguió robar la pelota activamos el contralador de pelota al usuario que ha recibido el pase
						// Además pintamos un mensaje de pase al pie adecuado (con conflicto o sin conflicto de intento de robo)
						// NOTE: No consumimos el turno hasta que el usuario coloque la pelota!
						result = 5;
						
						// Además si era el último sub-turno le damos un sub-turno EXTRA. Mientras hagas pase al pie puedes seguir tirando
						if( RemainingHits == 1 )
							RemainingHits++;
						
						// Mostramos el cartel de pase al pie en los 2 clientes!
						Interface.OnMsgPasePie( stealer ? true : false, LastConflicto );
						
						// Si no somos el 'LocalUser', solo esperamos la respuesta del otro cliente
						if( paseToCap.OwnerTeam.IsLocalUser )
							Interface.ShowHandleBall( paseToCap );
						
						RemainingPasesAlPie--;
						
						// Si este ha sido el último pase al pie, informamos al player
						if (RemainingPasesAlPie == 0)
							Interface.OnLastPaseAlPie();
					}
				}
				else	// No ha habido falta y no se ha producido pase al pie					
				{	
					// Cuando no hay pase al pie pero la chapa se queda cerca de un contrario, la perdemos directamente!
					// (pero: unicamente cuando hayamos tocado la pelota con una de nuestras chapas, es decir, permitimos mover una 
					// chapa SIN tocar el balón y que no por ello lo pierdas)
					var potentialStealer : Cap = GetPotencialStealer(AgainstTeam(CurTeam));
					
					if (potentialStealer != null && HasTouchedBallAny(this.CurTeam))
					{
						result = 10;
						
						// Igual que en el robo con conflicto pero con una reason distinta para que el interfaz muestre un mensaje diferente
						NextTurn( false, Enums.TurnByLost );
						if( potentialStealer.OwnerTeam.IsLocalUser )
							Interface.ShowHandleBall( potentialStealer );
					}
					else
					{
						// simplemente consumimos uno de los 3 turnos
						result = 11;
						ConsumeTurn();
					}
				}
				
				// Notificamos al servidor el resultado cálculado
				//var listToSend:Array = GetListToSend( this._Teams[0]+ this._Teams[ 1 ] );
				var capListStr:String = "T1: "+GetString( this._Teams[0].CapsList );
				capListStr += "T2: "+GetString( this._Teams[1].CapsList );
				capListStr += " B:" + this.Ball.GetPos().toString();
				var countTouchedCaps:int = TouchedCaps.length;
				
				if( !AppParams.OfflineMode )
					Server.Ref.Connection.Invoke("OnResultShoot", null, result, 
						countTouchedCaps, paseToCap != null ? paseToCap.Id : -1, FramesSimulating, 
						ReasonTurnChanged, capListStr);
				
				// Marcamos que hemos terminado la simulación del disparo y con ello además vacíamos la lista de impactos
				SimulatingShoot = false;
				
				// Volvemos al estado de juego
				ChangeState( GameState.Playing );
			}
			else
			{
				// TODO: Esto podría pasar si nos han cambiado el estado por un cambio de tiempo. Deberíamos controlarlo en el server! 
				throw new Error(IDString + "Hemos recibido una confirmación de que todos los jugadores han simulado el disparo cuando no estábamos esperándola" );
			}
		}
				

		//
		// Recibimos una "ORDEN" del servidor : "PlaceBall" 
		// Signature: int targetID, float dirX, float dirY, float force
		//	
		public function OnPlaceBall( playerId:int, capID:int, dirX:Number, dirY:Number ) : void
		{
			if( this.SimulatingShoot == true )
				throw new Error(IDString + "Ha llegado un orden PlaceBall mientras estamos en el cliente realizando una simulación de disparo. Player: "+playerId + " Cap: "  +capID + " RTC: " + ReasonTurnChanged );				
			
			// Obtenemos la chapa en la que vamos a colocar la pelota
			var cap:Cap = GetCap( playerId, capID );
			if( playerId != this.CurTeam.IdxTeam )
				throw new Error(IDString + "Ha llegado un orden PlaceBall de un jugador que no es el actual. Player: "+playerId + " Cap: "  +capID + " RTC: " + ReasonTurnChanged );
			
			// Posicionamos la pelota
			var dir:Point = new Point( dirX, dirY );  
			dir.normalize( Cap.Radius + BallEntity.Radius + AppParams.DistToPutBallHandling );
			var newPos:Point = cap.GetPos().add( dir );
			SetPosBall( newPos );
			
			// Consumimos un turno de lanzamiento, esto además habilita el interface
			ConsumeTurn();
		}
		
		//
		// Asigna la posición del balón y su última posición en la que estuvo parado
		// Siempre que se cambia "forzadamente" la posición del balón, utilizar esta función
		//
		public function SetPosBall( pos:Point ) : void
		{
			Ball.SetPos( pos );
			LastPosBallStopped = Ball.GetPos();
			Ball.StopMovement();
		}	
		
		// 
		// Un jugador ha utilizado una skill
		//
		public function OnUseSkill( idPlayer:int, idSkill:int ) : void
		{
			var team:Team = Teams[ idPlayer ];

			// Activamos la skill en el equipo
			trace( "Game: OnUseSkill: Player " + team.Name + " Utilizando habilidad " + idSkill.toString() );
			
			if( idPlayer != this.CurTeam.IdxTeam && idSkill != Enums.Catenaccio )
			{
				throw new Error(IDString + "Ha llegado una habilidad especial que no es Catenaccio de un jugador que no es el actual! Player="+team.Name+" Skill="+idSkill.toString());
			}
			
			team.UseSkill( idSkill );
			
			// Mostramos un mensaje animado de uso del skill (cuando el el otro jugador quien ha utilizado el skill)
			if( idPlayer != Server.Ref.IdLocalUser )
				Interface.ShowAniUseSkill( idSkill, null );
			
			// Algunos de los skills se aplican aquí ( son inmediatas ) otras no
			// Las habilidades inmediatas que llegan tienen que ser del jugador activo
			
			var bInmediate:Boolean = false;
			if( idSkill == Enums.Tiempoextraturno )		// Obtenemos tiempo extra de turno
			{				
				// NOTE: Ademas modificamos lo que representa el quesito del interface, para que se adapte al tiempo que tenemos ahora,
				// que puede ser superior al tiempo de turno del partido! Este valor se restaura al resetear el timeout
				Timeout += AppParams.ExtraTimeTurno;
				Interface.TurnTime = Timeout;
				bInmediate = true;
			}
			else if( idSkill == Enums.Turnoextra )		// Obtenemos un turno extra
			{
				RemainingHits ++;
				bInmediate = true;
			}
			
			if( bInmediate && idPlayer != this.CurTeam.IdxTeam )
			{	
				throw new Error(IDString + "Ha llegado una habilidad especial INMEDIATA de un jugador que no es el actual! Player="+team.Name+" Skill="+idSkill.toString());
			}
		}
		
		// 
		// Un jugador ha declarado tiro a puerta
		//
		public function OnTiroPuerta( idPlayer:int ) : void
		{
			// Mostramos el interface de colocación de portero al jugador contrario
			
			var team:Team = Teams[ idPlayer ] ;
			var enemy:Team = this.AgainstTeam( team );

			trace( "Game: OnTiroPuerta: Un jugador ha declarado tiro a puerta!" + team.Name );

			// Si el portero del enemigo está dentro del area,
			// cambiamos el turno al enemigo para que coloque el portero
			// Puede moverlo múltiples veces HASTA que se consuma su turno 
			
			
			// Una vez que se termine su TURNO por TimeOut se llamará a OnGoalKeeperSet  
			if( _Field.IsCapInsideArea( enemy.GoalKeeper ) )
			{
				this.SetTurn( enemy.IdxTeam, false, Enums.TurnByTiroAPuerta );
			}
			else
			{
				// El portero no está en el area, saltamos directamente a portero colocado 
				OnGoalKeeperSet( enemy.IdxTeam );	
			}
		}
		
		//
		// El servidor ordena posicionar una chapa
		// - Se utiliza para colocar el portero cuando alguien declara un disparo a puerta 
		//
		public function OnPosCap( idPlayer:int, capId:int, posX:Number, posY:Number ) : void
		{
			// Si la chapa posicionada es el portero ejecutamos el OnGoalKeeperSet
			// NOTE: Solo se puede posicionar el portero!
			if( capId == 0 )
			{
				// Asignamos la posición de la chapa
				var cap:Cap = this.GetCap( idPlayer, capId );
				cap.SetPos( new Point( posX, posY ) );
			}
			else
				throw new Error(IDString + "Alguien ha posicionado una chapa que no es el portero! Alguien está haciendo trampas? " );
		}
		
		
		// 
		// Un jugador ha terminado la colocación de su portero
		// NOTE: Volvemos al turno del otro jugador para que efectúe su lanzamiento
		//
		public function OnGoalKeeperSet( idPlayer:int ) : void
		{
			// Mostramos el interface de colocación de portero al jugador contrario
			
			var team:Team = Teams[ idPlayer ] ;
			var enemy:Team = this.AgainstTeam( team );
			
			trace( "Game: OnGoalKeeperSet: El jugador ha colocado su guardameta ! " + team.Name );
									
			// Cambiamos el turno al enemigo (quien declaró que iba a tirar a puerta) para que realice el disparo
			
			this.SetTurn( enemy.IdxTeam, true, Enums.TurnByGoalKeeperSet );
		}
		
		
		// 
		// Un jugador ha marcado gol!!! Reproducimos una cut-scene y cuando termine pasamos al estado "GoalScored"
		//
		public function OnGoalScored( idPlayer:int, validity:int) : void
		{
			// Verificamos coherencia de estado
			if( this.State != GameState.WaitingGoal )
				throw new Error( "CLIENT: Hemos recibido un gol cuando no estamos esperándolo. El estado debería ser 'GameState.WaitingGoal'. Curent State=" + this.State.toString() );
						
			//valid = false;
			trace( "Game: OnGoalScored: Confirmación del servidor de que han marcado GOL! Marcó el player: " + idPlayer );

			Playing = false;					// Pausamos el partido
			if( validity == Enums.GoalValid )
			{
				Teams[ idPlayer ].Goals ++;		// Contabilizamos el gol
			}
						
			// Lanzamos una cutscene y al terminar pasamos a  'FinishGoalCutScene'
			Interface.OnGoalScored( validity, Callback.Create( FinishGoalCutScene, idPlayer, validity ) );
		}
		
		//
		// Invocado cuando termina la cutscene de celebración de gol (tanto válido como inválido)
		//
		protected function FinishGoalCutScene( idPlayer:int, validity:int ) : void
		{
			trace( "Game: Finalizada Cut-Scene de gol!" );
			
			var turnTeam:Team = AgainstTeam( Teams[ idPlayer ] );
			
			if( validity == Enums.GoalValid)
			{
				// Asignamos el turno al equipo contrario al que ha marcado gol, pero no le habilitamos el interface todavía
				SetTurn( turnTeam.IdxTeam, false );
				
				// Espera a los jugadores y comienza del centro 
				StartCenter();
			}
			// GOL INVÁLIDO:
			else
			{
				// Tenemos que esperar a que todo el mundo esté listo antes de pasar al saque de puerta.
				// Enviamos nuestro 'estamos listos' y pasamos a esperar por los demás
				this.SendPlayerReady( Callback.Create( OnInvalidGoalAndPlayersReady, idPlayer ) );
					
				// Cambiamos a un estado que no hace nada (estamos esperando a que todos los jugadores estén listos)
				ChangeState( GameState.WaitGeneric );
			}
		}
		
		// Ocurrió un gol inválido, además todos los usuarios han indicado que están listos para continuar.
		// Pasamos al saque de puerta!
		protected function OnInvalidGoalAndPlayersReady( idPlayer:int ) : void
		{
			var turnTeam:Team = AgainstTeam( Teams[ idPlayer ] );
			
			// Ponemos en estado de saque de puerta (indicando que no se debe a una falta) (alineación, balón, turno, ... )
			SaquePuerta( turnTeam, false );
			
			// Reseteamos variables ...				
			SimulatingShoot = false;		// Se indica que no estamos simulando ningún disparo
			DetectedGoal = false;			// Reseteamos el detector de gol.
			Playing = true;					// Indica si estamos jugando o no. El tiempo de partido solo cambia mientras que estamos jugando
			PlayersReady = false;			// Realmente no es necesario, pero lo hacemos
			
			// Cambiamos al estado a jugar de nuevo
			this.ChangeState( GameState.Playing );
		}
		
		//
		// Saque de puerta para un equipo. 
		// Ponemos en estado de saque de puerta (alineación, balón, turno, ... )
		//
		public function SaquePuerta( team:Team, dueToFault:Boolean ) : void
		{
			// Colocamos los jugadores en la alineación correspondiente
			_Teams[ Enums.Team1 ].ResetToCurrentFormation();
			_Teams[ Enums.Team2 ].ResetToCurrentFormation();
			
			// Colocamos el balón delante del portero que va a sacar de puerta
			// Delante quiere decir mirando al centro del campo
			Ball.SetPosInFrontOf( team.GoalKeeper );
			LastPosBallStopped = Ball.GetPos();		// Actualizamos la última posición del balón
			Ball.StopMovement();
			
			// Asignamos el turno al equipo que debe sacar de puerta
			if( dueToFault == true )
				SetTurn( team.IdxTeam, true, Enums.TurnBySaquePuertaByFalta );
			else
				SetTurn( team.IdxTeam, true, Enums.TurnBySaquePuerta );
		}
		
		// 
		// Se ha terminado el tiempo del jugador
		// Debemos cambiar el turno al siguiente jugador
		//
		public function OnTimeout( idPlayer:int ) : void
		{
			trace( "Game: OnTimeout del player " + Teams[ idPlayer ].Name );
			
			if( idPlayer == CurTeam.IdxTeam )
			{
				// Si se acaba el tiempo, cuando cambiamos de turno por tiro a puerta : para colocar el portero
				// Entonces damos por finalizada la colocación    
				if( ReasonTurnChanged == Enums.TurnByTiroAPuerta )
				{
					OnGoalKeeperSet( idPlayer );
				}
				// El caso normal cuando se acaba el tiempo simplemente pasamos el turno al jugador siguiente
				else
					NextTurn( true );	
			}
			else
				throw new Error(IDString + "No puede llegar Timeout del jugador no actual" );
		}
		
		//
		// Resetea el tiempo del timeout
		//
		public function ResetTimeout(  ) : void
		{
			Timeout = Config.TurnTime;
			Interface.TurnTime = Timeout;		// Asignamos el tiempo de turno que entiende el interface, ya que este valor se modifica cuando se obtiene extratime
			TimeOutSent = false;				// Para controlar que no se mande múltiples veces el timeout
			TimeOutPaused = false;				// Se elimina la pausa en el timeout
		}
		
		//
		// Obtiene una chapa de un equipo determinado a partir de su identificador de equipo y chapa
		//
		public function GetCap( teamId:int, capId:int ) : Cap
		{
			if( teamId != Enums.Team1 && teamId != Enums.Team2 )
			{
				throw new Error( "Identificador invalido" );
				return null;
			}
				
			return( Teams[ teamId ].CapsList[ capId ] ); 
		}
		
		//-----------------------------------------------------------------------------------------
		//							CONTROL DE TURNOS
		//-----------------------------------------------------------------------------------------
		
		//
		// Consumimos un turno del jugador actual
		// Si alcanza 0 pasamos de turno
		// 
		public function ConsumeTurn( ) : void
		{
			RemainingHits--;
			ResetTimeout();		// Reseteamos el tiempo disponible para el subturno (time-out)
			
			// Si es el jugador local el activo mostramos los tiros que nos quedan en el interface
			if( this.CurTeam.IsLocalUser  )
				Interface.OnQuedanTurnos( RemainingHits );
			
			// Si has declarado tiro a puerta, el jugador contrario ha colocado el portero, nuestro indicador
			// de que el turno ha sido cambiado por colocación de portero solo dura un sub-turno (Los restauramos a turno x turno).
			// Tendrás que volver a declarar tiro a puerta para volver a disparar a porteria
			// NOTE: Esto se hace para que un mismo turno puedas declarar varias veces tiros a puerta
			if( ReasonTurnChanged == Enums.TurnByGoalKeeperSet )
				ReasonTurnChanged = Enums.TurnByTurn;
			
			// Comprobamos si hemos consumido todos los disparos
			// Si es así cambiamos el turno al jugador siguiente y restauramos el nº de disparos disponibles
			if( RemainingHits == 0 )
			{
				NextTurn();
			}
			// Al consumir un turno volvemos a habilitar la entrada del usuario para que pueda
			// producir un nuevo disparo
			EnableUserInput( true );
						
			// Al consumir un turno deactivamos las skillls que estén siendo usadas
			Teams[ Enums.Team1 ].DesactiveSkills();			
			Teams[ Enums.Team2 ].DesactiveSkills();
		}
		
		//
		// Pasamos el turno al siguiente jugador
		// (Reseteamos el nº de "hits" permitidos en el turno
		// NOTE: Si se indicaca además se activará el interface de entrada de usuario 
		// si es el turno del jugador local
		//
		public function NextTurn( enableUserInput:Boolean = true, reason:int = Enums.TurnByTurn  ) : void
		{
			if( IdxCurTeam == Enums.Team1 )
				SetTurn( Enums.Team2, enableUserInput, reason );
			else if( IdxCurTeam == Enums.Team2 )
				SetTurn( Enums.Team1, enableUserInput, reason );
		}
		//
		// Asigna el turno de juego de un equipo
		// (Reseteamos el nº de "hits" permitidos en el turno)
		// NOTE: Si se indica además se activará el interface de entrada de usuario 
		// si es el turno del jugador local
		//
		public function SetTurn( idTeam:int, enableUserInput:Boolean = true, reason:int = Enums.TurnByTurn ) : void
		{
			// DEBUG: En modo offline nos convertimos en el otro jugador, para poder testear!
			if( AppParams.OfflineMode == true )
				Server.Ref.IdLocalUser = idTeam;
				//this.LocalUserTeam = this.Teams[ idTeam ];
			
			// Guardamos la razón por la que hemos cambiado de turno
			// IMPORTANT: Hacemos esto al principio, porque cuando se activa/desactiva el interface de usuario
			// se utiliza esta variable para determinar que se activa y que no! 
			ReasonTurnChanged = reason;
			
			// Verificamos si es una asignación redundante
			//if( IdxCurTeam != idTeam )
			{
				// Reseteamos el nº de subtiros
				// TODO: Salva cuando se cambia el turno para declaración de tiro a puerta, o porque se ha colocado el portero.
				// En estos casos se mantiene el nº de tiros 
				RemainingHits = AppParams.MaxHitsPerTurn;
				RemainingPasesAlPie = AppParams.MaxNumPasesAlPie;
				IdxCurTeam = idTeam;
				
				// Mostramos un mensaje animado de cambio de turno
				Interface.OnTurn( idTeam, reason, null );
			}
			
			ResetTimeout();		// Reseteamos el tiempo disponible para el subturno (time-out)
			
			// Para colocar el portero solo se posee la mitad de tiempo!!
			if( reason == Enums.TurnByTiroAPuerta )
				this.Timeout = this.Config.TimeToPlaceGoalkeeper;
			
			// Para tirar a puerta solo se posee un tiro y se pierden todos los pases al pie
			if( reason == Enums.TurnByGoalKeeperSet )
			{
				RemainingHits = 1;
				RemainingPasesAlPie = 0
			}
			
			// Si cambiamos el turno por robo, perdida o falta le damos un turno extra para la colocación del balón.
			// De esta forma luego tendrá los mismos que un turno normal
			if( reason == Enums.TurnByStolen || reason == Enums.TurnByFault || reason == Enums.TurnByLost)
				RemainingHits ++;
			
			// Habilitar la entrada del interface si es el usuario local!!
			if( enableUserInput == true )
			{
				if( IdxCurTeam == Server.Ref.IdLocalUser )
					Interface.UserInputEnabled = true;
				else
					Interface.UserInputEnabled = false;
				
				// En modo offline permitimos controlar los 2 jugadores!
				/*
				if( AppParams.OfflineMode )
				Interface.UserInputEnabled = true;
				*/
			}
			
			// Al cambiar el turno, también desactivamos las skills que se estuvieran utilizando
			// Salvo cuando cambiamos el turno por declaración de tiro a puerta, o por que ha colocado el portero 
			if( reason != Enums.TurnByTiroAPuerta && reason != Enums.TurnByGoalKeeperSet )
			{
				Teams[ Enums.Team1 ].DesactiveSkills();
				Teams[ Enums.Team2 ].DesactiveSkills();
			}
		}
		
		//
		// Activa / Desactiva la entrada del usuario.
		// NOTE: Si el jugador local no es el actual se ignorará un intento de activación de interface
		//
		public function EnableUserInput( bEnable:Boolean = true ) : void
		{
			if( bEnable == false )
				Interface.UserInputEnabled = false;
			else
			{
				if( IdxCurTeam == Server.Ref.IdLocalUser )
					Interface.UserInputEnabled = true;
			}
		}
				
		//
		// El enemigo más capaz de robarme el balon. De momento consideramos que es el más cercano.
		//
		private function GetPotencialStealer(enemyTeam : Team) : Cap
		{
			var enemy : Cap = null;
			
			var capList:Array = enemyTeam.InsideCircle( _Ball.GetPos(), Cap.Radius + BallEntity.Radius + enemyTeam.RadiusSteal );
			if( capList.length >= 1 )
				enemy = _Ball.NearestEntity( capList ) as Cap;
			
			return enemy;
		}		
		
		//
		// Comprobamos si alguien del equipo contrario le puede robar el balon al jugador indicado
		// Retorna el enemigo que podría robar la pelota o NULL si no hay conflicto posible
		// NOTE: Ademas si se devuelve un potencial ladrón, se rellena el objeto conflicto
		//
		private function CheckConflictoSteal( cap:Cap, conflicto:Object ) : Cap
		{
			// Cogemos el equipo contrario al de la chapa que evaluaremos
			var enemyTeam:Team = AgainstTeam( cap.OwnerTeam );
			
			// Comprobamos las chapas enemigas en el radio de robo
			var stealer:Cap = GetPotencialStealer(enemyTeam);
			
			if (stealer == null)
				return null;
								
			// Calculamos el valor de control de la chapa que tiene el turno
			var miControl:int = 10 + cap.Control;
			if( cap.OwnerTeam.IsUsingSkill( Enums.Furiaroja ) )
				miControl *= AppParams.ControlMultiplier;
						
			// Calculamos el valor de defensa de la chapa contraria, la que intenta robar el balón, teniendo en cuenta las habilidades especiales
			var suDefensa:int = 10 + stealer.Defense;
			if( stealer.OwnerTeam.IsUsingSkill( Enums.Catenaccio ) )
				suDefensa *= AppParams.DefenseMultiplier;

			// Comprobamos si se produce el robo entre las dos chapas teniendo en cuenta sus parámetros de Defensa y Control
			var probabilidadRobo:Number = 50;
			
			if (miControl != 0 || suDefensa != 0)
				probabilidadRobo = AppParams.CoeficienteRobo * (suDefensa * 100 / (miControl + suDefensa));
				
			// Rellenamos el objeto de conflicto
			conflicto.defense = cap.Control;
			conflicto.attack = stealer.Defense;
			conflicto.probabilidadRobo = probabilidadRobo;
			conflicto.defenserCapName = cap.Name;
			conflicto.attackerCapName = stealer.Name;
												
			return stealer;		// Retornamos el enemigo que puede robar la pelota
		}
		
		//
		// Comprueba el resultado de un conflicto
		//
		private function ResolveConflicto( conflicto:Object ) : Boolean
		{
			var bSteal:Boolean = Random.Global.Probability( conflicto.probabilidadRobo )
			return( bSteal );
		}
		
		//
		// Obtiene el equipo adversario al especificado
		//
		public function AgainstTeam( team:Team ) : Team
		{
			if( team == _Teams[ Enums.Team1 ] )
				return _Teams[ Enums.Team2 ];
			if( team == _Teams[ Enums.Team2 ] )
				return _Teams[ Enums.Team1 ];
			
			return null;
		}
		
		// 
		// Obtiene el equipo que está en un lado del campo
		//
		public function TeamInSide( side:int) : Team
		{
			if( side == _Teams[ Enums.Team1 ].Side )
				return _Teams[ Enums.Team1 ];
			if( side == _Teams[ Enums.Team2 ].Side )
				return _Teams[ Enums.Team2 ];
			
			return null;
		}
		
		// 
		// Mejor chapa a la que se podria producir pase al pie. No chequea conflictos con chapas enemigas.
		//
		public function GetPaseAlPie() : Cap
		{
			// Si la chapa que hemos lanzado no ha tocado la pelota no puede haber pase al pie
			if( !HasTouchedBall( CapShooting ) )
				return null;
			
			// Si no nos queda ya ninguno más...
			if (RemainingPasesAlPie == 0)
				return null;
			
			// La más cercana de todas las potenciales
			return _Ball.NearestEntity(GetPotentialPaseAlPie()) as Cap;
		}
		
		public function GetPotentialPaseAlPie() : Array
		{
			// Iteramos por todas las chapas amigas y nos quedamos con las que están en el radio de pase al pie
			var potential : Array = new Array();
			var capList:Array = CurTeam.CapsList;
			
			for each( var cap:Cap in capList )
			{
				if( cap != null && cap.InsideCircle( _Ball.GetPos(), Cap.Radius + BallEntity.Radius + CurTeam.RadiusPase ) )
				{
					if (AppParams.AutoPasePermitido || cap != CapShooting)
						potential.push(cap);
				}
			}
			
			// Si hay más de una chapa candidata evitamos hacer autopase, el jugador querrá pasar al resto de chapas
			if (potential.length > 1 && potential.indexOf(CapShooting) != -1)
				potential.splice(potential.indexOf(CapShooting), 1);
			
			return potential;
		}
		
		//
		// Comprueba si un jugador ha tocado la pelota, tanto por que ha disparado o porque le han empujado
		// NOTE: si llamas a esta función cuando ha terminado la simulación de disparo siempre retorna false
		//
		public function HasTouchedBall( cap:Cap ) : Boolean
		{
			if( this._SimulatingShoot == false )
				trace( "No se puede llamar a HasTouchedBall cuando no se está simulando un disparo" );
			
			if( TouchedCaps.indexOf( cap ) != (-1) )
				return true;
			return false;
		}
		
		// Ha tocado la pelota cualquiera de las chapas del equipo?
		public function HasTouchedBallAny(team : Team) : Boolean
		{
			for each(var cap : Cap in team.CapsList)
				if (HasTouchedBall(cap))
					return true;
			return false;
		}
		
		private function ShowAllInfluences( ) : void
		{
			// Mostramos todas las influencias de pase al pie
			var friendCaps:Array = CurTeam.CapsList;
			for each( var friend:Cap in friendCaps )
			{
				friend.SetInfluenceAspect( Enums.FriendColor, Cap.Radius + BallEntity.Radius + CurTeam.RadiusPase );
				friend.ShowInfluence = true;
			}				
			
			// Mostramos todas las influencias de robo
			var enemyTeam:Team = AgainstTeam( CurTeam );
			var enemyCaps:Array = enemyTeam.CapsList;
			
			for each( var enemy:Cap in enemyCaps )
			{
				enemy.SetInfluenceAspect( Enums.EnemyColor, Cap.Radius + BallEntity.Radius + enemyTeam.RadiusSteal );
				enemy.ShowInfluence = true;
			}
		}
		
		
		//
		// Muestra los areas de influencia de las chapas que están en el radio de la pelota
		//
		public function ShowInfluences( ) : void
		{
			// Determinamos si debemos mostrar "TODAS" las influencias (si el jugador local tiene la habilidad de mostrar radios)			
			var bShowAllInfluences:Boolean = false;
			if( this.CurTeam.IsUsingSkill( Enums.Verareas ) && CurTeam.IsLocalUser )
				bShowAllInfluences = true;
			
			// Solo mostramos influencias cuando estamos simulando un disparo y el jugador que lanzó ha tocado la pelota,
			// o mostrando todas las influencias (por uso de la habilidad especial)
			if( bShowAllInfluences )
			{
				ShowAllInfluences();
			}
			else if( this._SimulatingShoot )
			{
				// Si los turnos o los pases al pie estan agotados, no mostramos ninguna influencia amiga.
				// Además, el pase al pie sólo empieza a ser posible cuando la chapa que lanza ha tocado la pelota.
				if (RemainingHits != 0 && RemainingPasesAlPie != 0 && this.HasTouchedBall( this.CapShooting ))
				{
					var potential:Array = GetPotentialPaseAlPie();
					
					for each( var friend:Cap in potential )
					{
						friend.SetInfluenceAspect( Enums.FriendColor, Cap.Radius + BallEntity.Radius + CurTeam.RadiusPase );
						friend.ShowInfluence = true;
					}
					
					// Apagamos inmediatamente las q ya no son potenciales
					for each(friend in CurTeam.CapsList)
					{
						if (friend.ShowInfluence && potential.indexOf(friend) == -1)
							friend.ShowInfluence = false;
					}
				}
				
				// Mostramos las chapas enemigas que podrían robar la pelota o sobre las que podríamos perder la pelota
				// Si ninguna de nuestras chapas ha tocado la pelota, no se produce la perdida, asi que tampoco pintamos el area
				if (HasTouchedBallAny(CurTeam))
				{
					var enemyTeam:Team = AgainstTeam( CurTeam );
					var enemyCaps:Array = enemyTeam.InsideCircle( _Ball.GetPos(), Cap.Radius + BallEntity.Radius + enemyTeam.RadiusSteal );
					
					for each( var enemy:Cap in enemyCaps )
					{
						enemy.SetInfluenceAspect( Enums.EnemyColor, Cap.Radius + BallEntity.Radius + enemyTeam.RadiusSteal );
						enemy.ShowInfluence = true;
					}
					
					for each(enemy in enemyTeam.CapsList )
					{
						if (enemy.ShowInfluence && enemyCaps.indexOf(enemy) == -1)
							enemy.ShowInfluence = false;
					}
				}
			}
		}
		
		//
		// Comprueba si la posición del equipo actual es válida para marcar gol. Debe estar
		//    - La pelota en el campo enemigo o tener la habilidad especial de permitir gol de más de medio campo? 
		// 	  - 
		//
		public function IsTeamPosValidToScore(  ) : Boolean
		{
			var player:Team = this.CurTeam;
			if( player == null )
				return false;
			
			var bValid:Boolean = true;
			
			if( !player.IsUsingSkill( Enums.Tiroagoldesdetupropiocampo ) )
			{
				if( player.Side == Enums.Right_Side && LastPosBallStopped.x >= Field.CenterX)
					bValid = false;
				else if( player.Side == Enums.Left_Side && LastPosBallStopped.x <= Field.CenterX)
					bValid = false;
			}
			
			return( bValid );
		}
		
		//
		// Comprueba si se ha declarado tiro a puerta o si se posee la habilidad especial mano de dios
		//  
		public function TiroPuertaDeclarado( ) : Boolean
		{
			var team:Team = this.CurTeam;
			if( team == null )
				return false;
			
			var bDeclared:Boolean = true;
			
			if( !team.IsUsingSkill( Enums.Manodedios ) )
			{
				if( ReasonTurnChanged != Enums.TurnByGoalKeeperSet && ReasonTurnChanged != Enums.TurnByTiroAPuerta  )
					bDeclared = false;
			}
			
			return( bDeclared );
		}
		
		// 
		// Entrada de un evento desde el servidor de finalización de una de las mitades del partido
		// Pasamos por esta función tanto para una parte como para otra!
		// En la segunda parte nos envían ademas el resultado, en la primera es null
		//
		public function FinishPart( part:int, result:Object ) : void
		{
			trace( "Finish: Finalización de mitad del partido: " + part.toString() );
			
			// Actualizamos la mitad del partido y pasamos al estado correspondiente 
			_Part = part;
			Playing = false;	// Pausamos el partido
			
			// Lanzamos la cutscene de fin de tiempo, cuando termine pasamos realmente de parte
			// o finalizamos el partido
			if( part == 1 )
				Interface.OnFinishPart( _Part, Callback.Create( ChangeState, GameState.EndPart ) );
			else if( part == 2 )
				Interface.OnFinishPart( _Part, Callback.Create( Finish, result ) );
		}
		
		//
		// Nuestro enemigo se ha desconectado en medio del partido
		// Hacemos una salida limpia, cerrando el servidor y notificando al manager
		//
		public function PushedOpponentDisconnected ( result:Object ) : void
		{
			Finish(result);
		}
				
		// 
		// Finaliza INMEDIATAMENTE el partido. Para ello:
		//   - Detiene interface de entrada/juego
		//	 - Cierra el servidor y notifica hacia afuera de la finalización 
		// 
		//	NOTE: En los casos de cierre por finalización normal de partido o porque abortan se pasa por aquí 
		//
		public function Finish( result:Object ) : void
		{
			trace( "Finish: Finalizando el partido" );
			
			// Nos quedamos en el estado "EndGame" que no hace nada
			ChangeState( GameState.EndGame );
			
			// Pausamos el juego y no permitimos entrada de interface
			Playing = false;
			EnableUserInput( false );
			
			Shutdown(result);
		}
		
		// Unico punto de salida del Match
		private function Shutdown(result : Object) : void
		{
			// Cerramos la conexión con el servidor
			Server.Ref.Close();
			
			// Destruimos timers, ENTER_FRAMES, etc
			Match.Ref.Shutdown();
			
			// ... y notificamos hacia afuera (al RealtimeModel)
			Match.Ref.dispatchEvent(new utils.GenericEvent("OnMatchEnded", result));
		}
		
		//
		// Comienza desde el centro del campo, sincronizando que los 2 jugadores estén listos
		//
		public function StartCenter( ) : void
		{
			// Enviamos al servidor nuestro estamos listos! cuando todos estén listos nos llamarán a StartCenterAllReady
			SendPlayerReady( StartCenterAllReady );
			
			// Pasamos al estado de espera hasta que nos llegue la confirmación "OnAllPlayersReady" desde el servidor
			ChangeState( GameState.WaittingPlayers );
		}
		
		
		//
		// Los 2 jugadores han comunicado que están listos para comenzar el saque de centro
		//
		public function StartCenterAllReady( ) : void
		{
			PlayersReady = false;
			
			// Reseteamos el número de disparos disponibles para el jugador que tiene el turno
			RemainingHits = AppParams.MaxHitsPerTurn;
			RemainingPasesAlPie = AppParams.MaxNumPasesAlPie;
			
			// Colocamos el balón en el centro y los jugadores en la alineación correspondiente, detenemos cualquier simulación física
			StopSimulation();
			_Teams[ Enums.Team1 ].ResetToCurrentFormation();
			_Teams[ Enums.Team2 ].ResetToCurrentFormation();
			_Ball.Reset();
			LastPosBallStopped = Ball.GetPos();
			
			// Sincronizamos el interface visual para asegurar que se actualicen los cambios
			Interface.Sync();
			
			// Reasignamos el turno del jugador actual (para que se le habilite el interface). A veces
			// pasamos por StartCenter sin que necesariamente haya sido un cambio de parte
			SetTurn( CurTeam.IdxTeam, true );
			
			// Se indica que no estamos simulando ningún disparo
			SimulatingShoot = false;
			// Reseteamos el detector de gol y falta
			DetectedGoal = false;
			DetectedFault = null;				// Bandera que indica Falta detectada (objeto que describe la falta)
			
			// A jugar!
			Playing = true;		// Indica si estamos jugando o no. El tiempo de partido solo cambia mientras que estamos jugando
			ChangeState( GameState.Playing );
		}
		
		
		//
		// GENERICO: Envía nuestro indicador de que estamos listos
		// Marca que no todos los jugadores NO están listos, ya que si nosotros no lo estábamos, seguro que al menos faltaba uno
		// Cuando todos los jugadores estén listos, el servidor nos mandará un 'OnAllPlayersReady' que simplemente subirá la bandera
		// 'PlayersReady'. Debemos esperar a la bandera para continuar!
		//
		public function SendPlayerReady( callbackOnAllPlayersReady:Function = null ) : void
		{
			trace( "Enviado nuestro 'Player Ready'" );
			
			// Bajamos la bandera:
			// Si nosotros todavía no hemos mandado nuestra notificación de que estamos listos, indicamos que no todos pueden estarlo 
			PlayersReady = false;
			
			// Función a llamar cuando todos los players estén listos
			CallbackOnAllPlayersReady = callbackOnAllPlayersReady;
			
			// Mandamos nuestro estamos listos
			// En modo offline simulamos la confirmación del servidor 
			if( !AppParams.OfflineMode )
				Server.Ref.Connection.Invoke( "OnPlayerReady", null );
			else
				OnAllPlayersReady(); 
		}
		
		// 
		// GENERICO: Todos los jugadores están listos, simplemente ponemos el semáforo en verde 'PlayersReady' 
		// e invocamos la función de usuario que hubiese configurado
		//
		public function OnAllPlayersReady( ) : void
		{
			trace( "Recibida señal del servidor 'OnAllPlayersReady'" );
			
			// Indicamos que ya podemos continuar la espera que estuvieramos haciendo
			PlayersReady = true;
			
			// Además llamamos al callback de usuario para desencadenar la reacción del usuario y lo asignamos a null
			if( CallbackOnAllPlayersReady != null )
			{
				// Invocación segura (asignando 'null' antes de llamar = permitir retro-alimentación del sistema)
				var callback:Function = CallbackOnAllPlayersReady;
				CallbackOnAllPlayersReady = null;
				callback();
			}
		}
		
		//
		// Sincronizamos el tiempo que queda de la mitad actual del partido con el servidor
		//
		public function SyncTime( remainingSecs:Number ) : void
		{
			this.TimeSecs = remainingSecs;
		}

		//
		// OnChatMsg: Recibimos un nuevo mensaje de chat desde el servidor
		//
		public function OnChatMsg(msg : String) : void
		{
			// Simplemente dejamos que lo gestione el componente de chat
			ChatLayer.AddLine(msg);
		}
		
		private function get IDString() : String { return "MatchID: " + Config.MatchId + " LocalID: " + Server.Ref.IdLocalUser + " "; } 
	}
	
}
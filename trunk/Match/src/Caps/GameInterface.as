package Caps
{
	import Embedded.Assets;
	
	import Framework.*;
	
	import Net.Server;
	
	import com.greensock.*;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.SharedObject;
	
	import utils.TimeUtils;

	//
	// Interface de juego
	// Controla "TODAS" las entradas del usuario local y reacciona o la propaga de la forma correspondiente
	// Al tratarse de un juego en red lo reenvía al interface de red que lo mandará al servidor como una petición
	//
	public class GameInterface
	{
		private var Shoot:ControlShoot = null;			// Control de disparo : Se encarga de pintar/gestionar la flecha de disparo
		private var BallControl:BallController = null;			// Control para posicionar la pelota
		private var ControllerCanvas:Sprite = null;				// El contenedor donde se pinta las flecha de direccion
		private var PosControl:PosController = null;			// Control para posicionar chapas (lo usamos solo para el portero)
		
		private var QuedanTiros2:DisplayObject = null;			// Cartel para mostrar el nº de tiros que tienes
		private var QuedanTiros1:DisplayObject = null;			// Cartel para mostrar el nº de tiros que tienes
		private var MensajePasealPie:DisplayObject = null;		// Cartel para mostrar el panel de pase al pie
		private var MensajeRobo:DisplayObject = null;			// Cartel para mostrar el mensaje de robo de balón
		
		public var TurnTime:Number = 0;							// Tiempo que representa la tartita contadora de timeout del interface
		
		// Parámetros visuales de la flecha que se pinta para disparar
		private const MAX_LONG_SHOOT:Number = 80; //55;
		private const COLOR_SHOOT:uint = 0xE97026;
		private const COLOR_HANDLEBALL:uint = 0x2670E9;
		private const THICKNESS_SHOOT:uint = 7;
		
		private var _UserInputEnabled:Boolean = false;			// Indica si se acepta la entrada del usuario
		
		public var CutSceneTurnRunning:MovieClip = null;		// la cut-scene de turno que está ejecutandose hasta que termine
		
		//
		// Inicialización
		//
		public function Init() : void
		{
			// Canvas de pintado compartido entre todos los controllers
			// NOTE: Lo añadimos al principio del interface, para que se pinte encima del juego pero debajo del interface 
			ControllerCanvas = new Sprite();
			Match.Ref.Game.GUILayer.addChild( ControllerCanvas );
						
			// Inicializamos los controladores (disparo, balón, posición )
			Shoot = new ExternalControlShoot( ControllerCanvas, MAX_LONG_SHOOT, COLOR_SHOOT, THICKNESS_SHOOT );
			
			var longLine:Number = Cap.Radius + BallEntity.Radius + AppParams.DistToPutBallHandling;
			BallControl = new BallController( ControllerCanvas, longLine, COLOR_HANDLEBALL, THICKNESS_SHOOT );
			
			PosControl = new PosController( ControllerCanvas, longLine, COLOR_HANDLEBALL, THICKNESS_SHOOT );
			
			// Sincroniza los valores de la lógica dentro del interface visual
			Sync();
			
			// Nos registramos a los eventos de pulsación del interface
			RegisterEvents();			
			
			// Creamos un evento para cuando pulsen el botón de tirar a puerta
			var Gui:* = Match.Ref.Game.GetField().Visual;
			Gui.BotonTiroPuerta.addEventListener( MouseEvent.CLICK, OnTiroPuerta );
			Gui.SoundButton.addEventListener( MouseEvent.CLICK, OnMute );
			
			// Nos registramos al botón de abandonar el partido
			/*  Gui.BotonAbandonar.addEventListener( MouseEvent.CLICK, OnAbandonar ); */
						
			// Creamos unos carteles que muestren el nº de tiros pendientes del jugador y pase al pie y robo
			var x:Number = Field.CenterX;
			var y:Number = Field.CenterY;
			
			QuedanTiros2 = CreateGraphic( Embedded.Assets.QuedanTiros2, x, y );
			QuedanTiros2.visible = false;

			QuedanTiros1 = CreateGraphic( Embedded.Assets.QuedanTiros1, x, y );
			QuedanTiros1.visible = false;
			
			MensajePasealPie = CreateGraphic( Embedded.Assets.MensajePasealPie, x, y );
			MensajePasealPie.visible = false;
			
			MensajeRobo = CreateGraphic( Embedded.Assets.MensajeRobo, x, y );
			MensajeRobo.visible = false;
			
			UpdateMuteButton();
		}
		
		private function OnMute(e:MouseEvent) : void
		{
			var so:SharedObject = SharedObject.getLocal("Match");
			
			var bMuted : Boolean = false;
			if (so.data.hasOwnProperty("Muted"))
				bMuted = so.data.Muted;
			
			so.data.Muted = !bMuted;
			so.flush();
			
			UpdateMuteButton();
		}
		
		private function UpdateMuteButton() : void
		{
			var so:SharedObject = SharedObject.getLocal("Match");			
			
			var bMuted : Boolean = false;
			if (so.data.hasOwnProperty("Muted"))
				bMuted = so.data.Muted;
			
			var Gui:* = Match.Ref.Game.GetField().Visual;
			if (bMuted)
			{
				SoundMixer.soundTransform = new SoundTransform(0);
				Gui.SoundButton.BotonOn.visible = false;
				Gui.SoundButton.BotonOff.visible = true;
			}
			else
			{
				SoundMixer.soundTransform = new SoundTransform(1);
				Gui.SoundButton.BotonOn.visible = true;
				Gui.SoundButton.BotonOff.visible = false;
			}
		}
		
		//
		// Iniciaizamos el Interface Gráfico de Usuario
		//
		public function Sync(  ) : void
		{
			var teams:Array = Match.Ref.Game.Teams;
			var Gui:* = Match.Ref.Game.GetField().Visual;
			
			CutSceneTurnRunning = null;		// Si tenemos una cutscene de turno corriendo, nos olvidamos de ella  
			
			// Asigna el aspecto visual según que equipo sea. Tenemos que posicionarla en el frame que se llama como el quipo
			Gui.BadgeHome.gotoAndStop( teams[ Enums.Team1 ].Name );
			Gui.BadgeAway.gotoAndStop( teams[ Enums.Team2 ].Name );
			
			Gui.TeamHome.text = teams[ Enums.Team1 ].Name;
			Gui.TeamAway.text = teams[ Enums.Team2 ].Name;
			
			// Rellenamos los goles
			var scoreText:String = teams[ Enums.Team1 ].Goals.toString() + " - " + teams[ Enums.Team2 ].Goals.toString();  
			Gui.Score.text = scoreText; 
			
			// Actualizamos la parte de juego en la que estamos "gui.Period"
			
			Gui.Period.text = Match.Ref.Game.Part.toString() + "T";
			
			// Marcamos que nadie tiene la posesion
			SelectCap( null );
			
			// Actualizamos los elementos que se actualizan a cada tick
			Update();
		}
		
		//
		// Nos registramos a los eventos del interface gráfico
		//
		public function RegisterEvents() : void
		{
			
		}
		

		//
		// Actualizamos los elementos visuales del Gui que están cambiando todo el tiempo
		//   - Tiempo del partido
		public function Update(  ) : void
		{
			var Gui:* = Match.Ref.Game.GetField().Visual;
			
			// Actualizamos el tiempo del partido
			var totalSeconds:Number = Match.Ref.Game.Time; 
			var text:String = utils.TimeUtils.ConvertSecondsToString( totalSeconds );
			Gui.Time.text = text;
			
			// Actualizamos el tiempo del sub-turno
			// NOTE: Utilizamos el tiempo de turno que indica el interface, ya que se modifica cuando se utiliza la habilidad especial
			// extra-time. Luego cada vez que se resetea el tiempo se coloca a la duración real del turno
			var timeout:Number = Match.Ref.Game.Timeout / TurnTime; 
			
			// Clampeamos a 1.0, ya que si tenemos tiempo extra de turno podemos desbordarnos
			if( timeout > 1.0 )
				timeout = 1.0;
			var frame:int = (1.0 - timeout) * Gui.ContadorTiempoTurno.totalFrames;
			Gui.ContadorTiempoTurno.gotoAndStop( frame );
			
			// Activamos los botones de habilidades especiales en función si el equipo del jugador local las posee o no
			var team:Team = Match.Ref.Game.LocalUserTeam;
			for ( var i:int = Enums.SkillFirst; i <= Enums.SkillLast; i++ )
			{
				SetSpecialSkill( i, team.HasSkill( i ), team.ChargedSkill( i ) );
			}
			
			// Actualizamos el estado (enable/disable) del botón de tiro a puerta
			UpdateButtonTiroPuerta();
		}
		
		
		//
		// Comprobamos si la habilidad está disponible en el turno actual
		// NOTE: Las habilidades están solo disponibles en tu turno, salvo "Catenaccio" que está siempre permitida
		//
		private function IsSkillAllowedInTurn( index:int ) : Boolean 
		{
			if( Match.Ref.Game.CurTeam == null )
				return( false );
			
			var game:Game = Match.Ref.Game;

			// Si estamos en el turno de colocación de portero, ninguna habilidad está disponible para nadie!
			if( game.ReasonTurnChanged == Enums.TurnByTiroAPuerta )
				return false;
			
			// Si estamos Simulando un disparo, ninguna habilidad está disponible para nadie! ni siquiera Catenaccion
			if( game.SimulatingShoot )
				return false;
			
			// Si algún controlador está activo las habilidades no están permitidas
			if( BallControl.IsStarted || this.PosControl.IsStarted || this.Shoot.IsStarted )
				return false;
									
			
			// Si es nuestro turno y tenemos el input activo la habilidad está disponible
			var allowedInTurn:Boolean = false;
			if( Match.Ref.Game.CurTeam.IsLocalUser )
			{
				allowedInTurn = this.UserInputEnabled;
			}
			// Si NO es nuestro turno no está disponible a no ser que la habilidad sea Catenaccion (que se puede usar fuera de tu turno)
			else
			{
				if( index == Enums.Catenaccio )
					allowedInTurn = true;
			}
			
			return ( allowedInTurn );
		}
		
		//
		// Sincroniza el valor de una Special-Skill
		// Habilitando/deshabilitando el botón en el interface
		//
		private function SetSpecialSkill( index:int, available:Boolean, percentCharged:int ) : void
		{
			var Gui:* = Match.Ref.Game.GetField().Visual;
						
			var objectName:String = "SpecialSkill"+index.toString(); 
			var item:MovieClip = Gui.getChildByName( objectName ) as MovieClip;
			if( item != null )
			{
				// No tenemos esa habilidad o no está permitida en el turno actual
				if( !available || (!IsSkillAllowedInTurn( index )) )
				{
					item.Icono.alpha = 0.25;	
					item.IconoBase.alpha = 0.25;
					item.Icono.gotoAndStop( objectName );
					item.IconoBase.gotoAndStop( objectName );
					item.Tiempo.gotoAndStop( 1 );
					item.Tiempo.visible = false;

					item.gotoAndStop( "NotAvailable" );	
				}
				// Tenemos la habilidad pero no está cargada al 100% (no se puede utilizar) 
				else if( available && percentCharged < 100 )
				{
					item.gotoAndStop( "Available" );
					
					item.Icono.alpha = 0.25;	
					item.IconoBase.alpha = 0.25;
					item.Icono.gotoAndStop( objectName );
					item.IconoBase.gotoAndStop( objectName );
					item.Tiempo.gotoAndStop( percentCharged );
					item.Tiempo.visible = true;
				}
				// Tenemos la habilidad y lista para ser usada
				else if( available && percentCharged >= 100 )
				{
					item.gotoAndStop( "Available" );
					
					item.Icono.alpha = 1.0;	
					item.IconoBase.alpha = 1.0;
					item.Icono.gotoAndStop( objectName );
					item.IconoBase.gotoAndStop( objectName );
					item.Tiempo.gotoAndStop( 1 );
					item.Tiempo.visible = false;
				}
				

				// Registramos el evento de utilizar skill añadiéndole un parámetro que indica
				// el índice de la skill a utilizar
				// NOTE: Dejamos siempre registrado el evento a pesar de que luego no se pueda utilizar la skill
				// el método determinará si está disponible
				
				//var usable:Boolean = ( available && percentCharged == 100 ); 
				var usable:Boolean = ( available  );

				if( item.hasEventListener( MouseEvent.CLICK ) )
				{
					if( !usable )
					{
						/*
						// NOTE: No se pueden elimar listener de esta manera si los hemos agregado con Callback.Create
						//
						item.removeEventListener( MouseEvent.CLICK, OnUseSkill );
						if( item.hasEventListener( MouseEvent.CLICK ) )
						{
							throw new Error( "No se elimina el listener!" );
						}
						*/
					}
				}
				else
				{
					if( usable )
						item.addEventListener( MouseEvent.CLICK, Callback.Create( OnUseSkill, index ) ); 
				}
				item.mouseEnabled = usable;
			}
		}
			
		//
		// Selecciona una chapa 
		// Al seleccionarse se visualiza información sobre la misma en la parte inferior derecha de la pantalla
		// NOTE: <null> implica ningunca chapa seleccionada
		//
		public function SelectCap( cap:Cap ) : void
		{
			var gui:* = Match.Ref.Game.GetField().Visual;
			
			if( cap != null )
			{
				gui.SelectedCap.gotoAndStop( cap.OwnerTeam.Name );
				//gui.SelectedName.text = cap.Name;
				gui.SelectedWeight.text = cap.Defense.toString();
				gui.SelectedSliding.text = cap.Control.toString();
				gui.SelectedPower.text = cap.Power.toString();
				gui.SelectedTarjetaAmarilla.visible = cap.YellowCards ? true : false; 
			}
			else
			{
				gui.SelectedCap.gotoAndStop( 1 );
				//gui.SelectedName.text = "";
				gui.SelectedWeight.text = "";
				gui.SelectedSliding.text = "";
				gui.SelectedPower.text = "";
				gui.SelectedTarjetaAmarilla.visible = false; 
			}
		}
		
		//
		// Han cliqueado sobre una chapa
		// Modo de disparo:
		//    Pinta la flecha de disparo tomando como destino la chapa y como origen la posición del cursor 
		//
		public function OnClickCap( cap:Cap ) : void
		{
			var game:Game = Match.Ref.Game;
			
			// Si estamos en modo de colocación de portero :
			//---------------------------------------
			if( game.ReasonTurnChanged == Enums.TurnByTiroAPuerta )
			{
				if( game.CurTeam == cap.OwnerTeam && cap.OwnerTeam.IsLocalUser && cap.Id == 0 )
				{
					trace( "Interface: OnClickCap: Moviendo portero " + cap.Name + " del equipo " + cap.OwnerTeam.Name );
					
					// Comenzamos el controlador de movimiento del portero
					ShowPosController( cap );
				}
			}
			// Si estamos en modo de saque de puerta:
			//---------------------------------------
			else if( game.ReasonTurnChanged == Enums.TurnBySaquePuerta || game.ReasonTurnChanged == Enums.TurnBySaquePuertaByFalta   )
			{
				if( UserInputEnabled == true && game.CurTeam == cap.OwnerTeam && cap.OwnerTeam.IsLocalUser && cap.Id == 0  )
				{
					trace( "Interface: OnClickCap: Saque de puerta " + cap.Name + " del equipo " + cap.OwnerTeam.Name );
					
					// Hasta que el tiro se efectúe y termine la simulación física se "inhabilita"
					// la entrada del usuario.
					// NOTE: Hacemos esto antes de iniciar el controlador de disparo, ya que si no
					// el detenar la entrada del usuario, automaticamente se cancelará el controlador 
					// de disparo
					UserInputEnabled = false;				
					
					// Comenzamos el controlador visual de disparo
					Shoot.Start( cap );
				}
			}
			// Si estamos en modo de disparo:
			//---------------------------------------
			else 
			{
				// Comprobamos : 
				// 	- Si la chapa es del equipo actual,
				// 	- Si está permitida la entrada por el usuario	
				// si no ignoramos la acción
				if( UserInputEnabled == true && game.CurTeam == cap.OwnerTeam )
				{
					trace( "Interface: OnClickCap: Mostrando controlador de disparo para " + cap.Name + " del equipo " + cap.OwnerTeam.Name );
					
					// Hasta que el tiro se efectúe y termine la simulación física se "inhabilita"
					// la entrada del usuario.
					// NOTE: Hacemos esto antes de iniciar el controlador de disparo, ya que si no
					// el detenar la entrada del usuario, automaticamente se cancelará el controlador 
					// de disparo
					UserInputEnabled = false;				
					
					// Comenzamos el controlador visual de disparo
					Shoot.Start( cap );
				}
				else
				{
					trace( "Interface: OnClickCap: No posible interactuar con chapa. Input User = " + UserInputEnabled + " Current Team: " + Match.Ref.Game.CurTeam.Name );
					trace( "Interface: la chapa que cliko es " + cap.Name + " del equipo " + cap.OwnerTeam.Name );
				}
			}
			
			// Marcamos que esta chapa tiene la posesión
			SelectCap( cap );
		}
		//
		// Activa el control de posicionamiento de pelota de la chapa indicada
		//
		public function ShowHandleBall( cap:Cap ) : void
		{
			trace( "GameInterface: ShowHandleBall: " + cap.OwnerTeam.Name );
			// Comprobamos : 
			// 	- Si la chapa es del equipo actual,
			//  NOTE: No se comprueba si la entrada de usuario está permitida, ya que
			//  no es una accioón decidida por el usuario, sino una consecuencia del pase al pie
			// si no ignoramos la acción
			if( Match.Ref.Game.CurTeam == cap.OwnerTeam /* && UserInputEnabled == true */ )
			{
				BallControl.Start( cap );
								
				// Marcamos que esta chapa tiene la posesión
				SelectCap( cap );
			}
		}
		
		//
		// Activa el control de posicionamiento de chapa
		//
		public function ShowPosController( cap:Cap /* , callback:Function = null */ ) : void
		{
			trace( "GameInterface: ShowPosController: " + cap.OwnerTeam.Name );
			// Comprobamos : 
			// 	- Si la chapa es del equipo actual,
			//  NOTE: No se comprueba si la entrada de usuario está permitida, ya que
			//  no es una accioón decidida por el usuario, sino una consecuencia del pase al pie
			// si no ignoramos la acción
			if( Match.Ref.Game.CurTeam == cap.OwnerTeam /* && UserInputEnabled == true */ )
			{
				PosControl.OnStop.removeAll();
				//PosControl.OnStop.add( Framework.Callback.Create( FinishPosController, callback ) );
				PosControl.OnStop.add( FinishPosController );
				
				PosControl.Start( cap );
				
				// Marcamos que esta chapa tiene la posesión
				SelectCap( cap );
			}
		}
		//
		// Se ha terminado el controlador de posicionamiento de chapa (portero)
		//
		public function FinishPosController( result:int, callback:Function = null ) : void
		{
			// Envíamos la información al servidor de colocar al portero en la coordenada indicada
			// Si no es válida la posición ignoramos simplemente			
			if( result == Controller.Success && PosControl.IsValid() )
			{
				Server.Ref.Connection.Invoke( "OnPosCap", null, PosControl.Target.Id, PosControl.EndPos.x, PosControl.EndPos.y );
			}
		}
		
		//
		// Se produce cuando el usuario termina de utilizar el control de disparo.
		// En ese momento se envíamos la acción de ejecutar disparo según el valor actual del controlador direccional de tiro
		//
		public function OnShoot( ) : void
		{
			// Envíamos la acción al servidor para que la verifique y la devuelva a todos los clientes
			// NOTE: [Debug] En modo Offline ejecuta directamente la acción en el cliente 
			
			// Si el disparo es válido (radio mayor que la chapa) notificamos al server que realice el disparo.
			// En caso contrario habilitamos el interface
			//
			if( Shoot.IsValid() )
			{
				if( !AppParams.OfflineMode )
				{
					Server.Ref.Connection.Invoke( "OnServerShoot", null, Shoot.Target.Id, Shoot.Direction.x, Shoot.Direction.y, Shoot.Force );
					WaitResponse();
				}
				else
					Match.Ref.Game.OnShoot( Shoot.Target.OwnerTeam.IdxTeam, Shoot.Target.Id, Shoot.Direction.x, Shoot.Direction.y, Shoot.Force );
			}
			else
				UserInputEnabled = true;
		}
		
		//
		// Se produce cuando el usuario termina de utilizar el control "HandleBall"
		// En ese momento se envíamos la acción de ejecutar disparo según el valor actual del controlador direccional de tiro
		//
		public function OnPlaceBall( ) : void
		{
			trace( "GameInterface: Mandamos al server el posicionar la pelota en un jugador " );

			// Envíamos la acción al servidor para que la verifique y la devuelva a todos los clientes
			// NOTE: [Debug] En modo Offline ejecuta directamente la acción en el cliente 
			
			if( !AppParams.OfflineMode )
			{
				Server.Ref.Connection.Invoke( "OnPlaceBall", null, BallControl.Target.Id, BallControl.Direction.x, BallControl.Direction.y );
				WaitResponse();
			}
			else
				Match.Ref.Game.OnPlaceBall( BallControl.Target.OwnerTeam.IdxTeam, BallControl.Target.Id, BallControl.Direction.x, BallControl.Direction.y );
		}
		
		
		// Indica si se acepta la entrada del usuario
		public function get UserInputEnabled( ) : Boolean
		{
			return _UserInputEnabled;
		}
		
		// Indica si se acepta la entrada del usuario. Si se cancela la entrada
		// mientras se estaba utilizando el control direccional de flecha, este
		// es tambien cancelado
		// IMPORTANT: Dentro de esta función se utiliza el valor de Game.ReasonTurnChanged asegurar que
		// está asignada!!!		
		public function set UserInputEnabled( value:Boolean ) : void
		{
			// Ignoramos asignaciones redundantes
			if( _UserInputEnabled != value )
			{
				_UserInputEnabled = value;
			}
			
			// Actualiza el estado(enable/disable) del botón de tiro a puerta
			//UpdateButtonTiroPuerta();
			
			// Si se prohibe la entrada de usuario cancelamos cualquier controlador
			// de entrada que estuviera funcionando. 
			// NOTE: Esto se reliza siempre aunque sea una asignación redundante! 
			// 
			if( value == false )
				Cancel();
		}
		
		// Activamos desactivamos el botón de tiro a puerta en función de si:
		//   - El interface está activo o no
		//   - Asegurando que durante un tiro a puerta no esté activo
		//   - y que estés en posición válida: más del medio campo o habilidad especial "Tiroagoldesdetupropiocampo" 
		
		public function UpdateButtonTiroPuerta(  ) : void
		{
			var Gui:* = Match.Ref.Game.GetField().Visual;
			var bActiveTiroPuerta:Boolean = _UserInputEnabled;
			
			// Si ya se ha declarado tiro a puerta no permitimos pulsar el botón 
			bActiveTiroPuerta = bActiveTiroPuerta && (!Match.Ref.Game.TiroPuertaDeclarado( ));
			
			// Posición válida para tirar a puerta o Tenemos la habilidad especial de permitir gol de más de medio campo? 
			bActiveTiroPuerta = bActiveTiroPuerta && Match.Ref.Game.IsTeamPosValidToScore( );						
			
			Gui.BotonTiroPuerta.visible = bActiveTiroPuerta;
		}		
		
		
		//
		// Cancela cualquier operación de entrada que estuviera ocurriendo 
		//  - Uso del controlador de tiro, posicionamiento de pelota, ... 
		//
		private function Cancel( ) : void
		{
			// Comprobamos si el usuario estaba utilizando el control de tiro,
			// caso en el cual debemos cancelarlo
			if( Shoot.IsStarted == true )
			{
				Shoot.Stop( Controller.Canceled );
			}
			// Comprobamos si el usuario estaba utilizando el control de posicionamiento de pelota,
			// caso en el cual debemos cancelarlo
			if( BallControl.IsStarted == true )
			{
				BallControl.Stop( Controller.Canceled );
			}
			// Comprobamos si el usuario estaba posicionando el portero,
			// caso en el cual debemos cancelarlo
			if( PosControl.IsStarted == true )
			{
				PosControl.Stop( Controller.Canceled );
			}
		}
		
		
		//
		// Obtiene un MovieClip del Gui a partir de un nombre y un índice. 
		// El índice lo concatena al final del nombre base, para forma el nombre final a buscar
		// Si el índice es (-1) lo ignora
		// Si root es null utiliza el Gui
		//
		public function GetMovieClipByName ( baseName:String, idx:int = (-1), root:DisplayObjectContainer = null ) : MovieClip
		{
			var mc:MovieClip = null;
			
			if( root == null )
				root = Match.Ref;
			
			if( root != null )
			{
				// Obtenemos el nombre final concatenando el indice que nos han dado.
				// Si el indice es (-1) lo ignoramos
				var finalName:String = baseName;
				if( idx != (-1) )
					finalName += idx.toString();
				
				mc = root.getChildByName( finalName ) as MovieClip;
			}
			
			return( mc );
		}
		
		//
		// Creamos un botón, a partir de 3 estados 
		// Los estados son clases que se instanciarán (embebidas)
		// Si se especifica un 'parent' añadimos el botón al mismo
		// NOTE: Para el estado de 'hit' o colisión que no se especifica se utiliza el upState
		//
		public function CreateButton( upState:Class, overState:Class = null, downState:Class = null, parent:DisplayObjectContainer = null  ) : SimpleButton
		{
			// Creamos instancias de cada estado
			var upInstance:DisplayObject = null; 
			var overInstance:DisplayObject = null;
			var downInstance:DisplayObject = null;
			
			if( upState != null )
				upInstance = new upState;
			if( overState != null )
				overInstance = new overState;
			if( downState != null )
				downInstance = new downState;
			
			// Creamos el botón con los elementos gráficos indicados
			// NOTE: Para que pueda tener interacción debe rellenarse hitTestState (el último parámetro)
			var item:SimpleButton = new SimpleButton( upInstance, overInstance, downInstance, upInstance );
			
			// Si nos dicen un padre, añadimos el botón
			if( parent != null )
				parent.addChild( item );
			
			// No es necesario, por defacto está activo
			//item.enabled = true;
			
			return( item );
		}
		
		// 
		// Han pulsado un botón de "Utilizar Skill x"
		//
		public function OnUseSkill( event:MouseEvent, idSkill:int ) : void
		{
			trace( "Interface: OnUseSkill: Utilizando habilidad " + idSkill.toString() );
	
			// Comprobamos si está cargado y se puede utilizar en este turno
			// NOTE: Las habilidades están solo disponibles en tu turno, salvo "Catenaccio" que está siempre permitida
			
			var team:Team = Match.Ref.Game.LocalUserTeam;
			if( team.ChargedSkill( idSkill ) == 100 && IsSkillAllowedInTurn( idSkill) )
			{
				// Notificamos al servidor para que lo propague en los usuarios
				if( !AppParams.OfflineMode )
					Server.Ref.Connection.Invoke( "OnUseSkill", null, idSkill );
				else
					Match.Ref.Game.OnUseSkill( Server.Ref.IdLocalUser, idSkill );
			}
		}
		
		// 
		// Han pulsado en el botón de "Tiro a puerta"
		//
		public function OnTiroPuerta( event:Object ) : void
		{
			// Propagamos al servidor
			Server.Ref.Connection.Invoke( "OnTiroPuerta", null );
			WaitResponse();
		}

		// 
		// Ha terminado una mitad
		// <part> Indica la parte que ha terminado
		//
		public function OnFinishPart( part:int, callback:Function = null ) : void
		{
			// No permitimos entrada del usuario y además cancelamos cualquier operación que estuviera ocurriendo
			UserInputEnabled = false;
			var cutScene:MovieClip = null;
			
			// Reproducimos una cutscene u otra en función de si ha acabado la primera parte o el partido 
			if( part == 1 )
			{
				// Creamos el mensaje de fin de partido				
				cutScene = CreateMovieClip( Embedded.Assets.MensajeFinTiempo1, 0, 210 );
				LaunchCutScene( cutScene, true, callback ); 
			}
			else if ( part == 2 )
			{
				cutScene = CreateMovieClip( Embedded.Assets.MensajeFinPartido, 0, 210 );
				LaunchCutScene( cutScene, true, callback ); 
			}
		}
		
		// 
		// Reproduce una animación dependiendo de si el gol es válido o no
		//
		public function OnGoalScored( validity:int, callback:Function = null  ) : void
		{
			// No permitimos entrada del usuario y además cancelamos cualquier operación que estuviera ocurriendo
			UserInputEnabled = false;
			var cutScene:MovieClip = null;
			
			if( validity == Enums.GoalValid )
			{
				cutScene = CreateMovieClip( Embedded.Assets.MensajeGol, 0, 210 );
				LaunchCutScene( cutScene, true, callback ); 
			}
			else
			if( validity == Enums.GoalInvalidNoDeclarado )
			{
				cutScene = CreateMovieClip( Embedded.Assets.MensajeGolInvalido, 0, 210 );
				LaunchCutScene( cutScene, true, callback ); 
			}
			else
			if( validity == Enums.GoalInvalidPropioCampo )
			{
				cutScene = CreateMovieClip( Embedded.Assets.MensajeGolinvalidoPropioCampo, 0, 210 );
				LaunchCutScene( cutScene, true, callback ); 
			}
			else
				throw new Error("Validez del gol desconocida");
		}
		
		// 
		// Reproduce una animación mostrando el turno del jugador
		// dueToRob: Indica que el turno ha sido asignado por un robo de balón
		//
		public function OnTurn( idTeam:int, reason:int, callback:Function = null  ) : void
		{
			// No permitimos entrada del usuario y además cancelamos cualquier operación que estuviera ocurriendo
			UserInputEnabled = false;
			var cutScene:MovieClip = null;
			
			// Creamos la cutscene adecuada en función de si el turno del jugador local o el contrario y de la razón
			// por la que hemos cambiado de turno			
			if( idTeam == Server.Ref.IdLocalUser )	// Es el turno propio ( jugador local )
			{
				if( reason == Enums.TurnByStolen  )
				{
					cutScene = CreateMovieClip( Embedded.Assets.MensajeTurnoPropioRobo, 0, 210 );
					FillConflicto( cutScene.ModuloConflicto, Match.Ref.Game.LastConflicto );
				}
				else if (reason == Enums.TurnByLost)
				{
					cutScene = CreateMovieClip( Embedded.Assets.MensajeTurnoPropioRoboSinConflicto, 0, 210 );
				}
				else if( reason == Enums.TurnByFault || reason == Enums.TurnBySaquePuertaByFalta )
				{					
					// Los nombres están al revés porque aquí representa a quien le han hecho la falta
					cutScene = CreateMovieClip( Embedded.Assets.MensajeFaltaContraria, 0, 210 );
					FillConflictoFault( cutScene, Match.Ref.Game.DetectedFault );
				}
				else if( reason == Enums.TurnBySaquePuerta  )		// El saque de puerta no tiene un mensaje específico para el oponente
					cutScene = CreateMovieClip( Embedded.Assets.MensajeTurnoPropioSaquePuerta, 0, 210 );
				else if( reason == Enums.TurnByTiroAPuerta  )
					cutScene = CreateMovieClip( Embedded.Assets.MensajeColocarPorteroPropio, 0, 210 );
				else if( reason == Enums.TurnByGoalKeeperSet)
					cutScene = CreateMovieClip( Embedded.Assets.MensajeTiroPuertaPropio, 0, 210 );
				else
					cutScene = CreateMovieClip( Embedded.Assets.MensajeTurnoPropio, 0, 210 );
			}
			else 	// Es el turno del oponente
			{
				if( reason == Enums.TurnByStolen  )	
				{
					cutScene = CreateMovieClip( Embedded.Assets.MensajeTurnoContrarioRobo, 0, 210 );
					FillConflicto( cutScene.ModuloConflicto, Match.Ref.Game.LastConflicto );
				}
				else if (reason == Enums.TurnByLost)
				{
					cutScene = CreateMovieClip( Embedded.Assets.MensajeTurnoContrarioRoboSinConflicto, 0, 210 );
				}
				else if( reason == Enums.TurnByFault || reason == Enums.TurnBySaquePuertaByFalta )
				{
					cutScene = CreateMovieClip( Embedded.Assets.MensajeFaltaPropia, 0, 210 );
					FillConflictoFault( cutScene, Match.Ref.Game.DetectedFault );
				}
				else if( reason == Enums.TurnByTiroAPuerta  )
					cutScene = CreateMovieClip( Embedded.Assets.MensajeColocarPorteroContrario, 0, 210 );
				else if( reason == Enums.TurnByGoalKeeperSet)
					cutScene = CreateMovieClip( Embedded.Assets.MensajeTiroPuertaContrario, 0, 210 );
				else
					cutScene = CreateMovieClip( Embedded.Assets.MensajeTurnoContrario, 0, 210 );
			}
			
			// Lanzamos la cutscene
			if( cutScene != null )
			{
				LaunchCutScene( cutScene, true, callback );
				CutSceneTurnRunning = cutScene;					// Almacenamos la cut-scene de turno que está ejecutandose hasta que termine
			}
		}
		
		// 
		// Reproduce una animación mostrando el uso de una skill
		//
		public function ShowAniUseSkill( idSkill:int, callback:Function = null  ) : void
		{
			// Cancelamos cualquier operación de entrada que estuviera ocurriendo
			// Cancel();
			var cutScene:MovieClip = null;
			
			// Reproducimos una cutscene u otra en función de si el turno del jugador local o el contrario 
			//if( idTeam == Server.Ref.IdLocalUser )	// Es el jugador local?
			{
				// Creamos/lanzamos la cutscene
				if( idSkill == 1 )
					cutScene = CreateMovieClip( Embedded.Assets.MensajeSkill01, 0, 210 );
				else if( idSkill == 2 )
					cutScene = CreateMovieClip( Embedded.Assets.MensajeSkill02, 0, 210 );
				else if( idSkill == 3 )
					cutScene = CreateMovieClip( Embedded.Assets.MensajeSkill03, 0, 210 );
				else if( idSkill == 4 )
					cutScene = CreateMovieClip( Embedded.Assets.MensajeSkill04, 0, 210 );
				else if( idSkill == 5 )
					cutScene = CreateMovieClip( Embedded.Assets.MensajeSkill05, 0, 210 );
				else if( idSkill == 6 )
					cutScene = CreateMovieClip( Embedded.Assets.MensajeSkill06, 0, 210 );
				else if( idSkill == 7 )
					cutScene = CreateMovieClip( Embedded.Assets.MensajeSkill07, 0, 210 );
				else if( idSkill == 8 )
					cutScene = CreateMovieClip( Embedded.Assets.MensajeSkill08, 0, 210 );
				else if( idSkill == 9 )
					cutScene = CreateMovieClip( Embedded.Assets.MensajeSkill09, 0, 210 );
				else
					throw new Error( "Identificador de skill invalido" );
				
				LaunchCutScene( cutScene, true, callback ); 
			}
		}
		
		
		//
		// Lanza una cutscene a partir de un asset embebido que se crea y dispara
		//   - 
		//
		public function CreateGraphic( cutScene:Class, x:Number = 0, y:Number = 0, parent:DisplayObjectContainer = null ) : DisplayObject
		{
			// Creamos el objeto gráfico
			var item:DisplayObject = new cutScene() as DisplayObject;
			
			if( item != null)
			{
				// Posicionamos la cutscene
				item.x = x;
				item.y = y;
				
				// Linkamos la cutscene al arbol de pintado
				if( parent == null )
					parent = Match.Ref.Game.GUILayer;
				parent.addChild( item );
				
				// Aseguramos que no se reproduce la animación
				//item.gotoAndStop( 1 );
			}
			else
				trace( "Error creando asset" );
			
			return( item );
		}
		public function CreateMovieClip( cutScene:Class, x:Number = 0, y:Number = 0, parent:DisplayObjectContainer = null ) : MovieClip
		{
			return( CreateGraphic( cutScene, x, y, parent ) as MovieClip );
		}
		
		
		//
		// Lanza una cutscene a partir de la animación de un movie-clip
		//
		public function LaunchCutScene( mc:MovieClip, removeToEnd:Boolean = false, callback:Function = null ) : void
		{
			if( mc )
			{
				// Aseguramos que es visible		
				mc.visible = true;
				// Lanzamos!
				mc.gotoAndPlay( 1 );
				
				var labelEnd:String = "EndAnim";
				
				if( Framework.Graphics.HasLabel( labelEnd, mc ) ) 
					utils.MovieClipListener.AddFrameScript( mc, labelEnd, Framework.Callback.Create( OnEndCutScene, mc, removeToEnd, callback ) );
				else
					trace( "El MovieClip " + mc.name + " no tiene la etiqueta " + labelEnd );
			}
		}
		
		//
		// Ha terminado una cut-scene
		//
		public function OnEndCutScene( mc:MovieClip, removeToEnd:Boolean, callback:Function ) : void
		{
			// Si ha terminado una cutscene de turno, limpiamos la variable que indica que está ejecutándose
			if( CutSceneTurnRunning == mc )
				CutSceneTurnRunning = null;

			// Detenemos animación (para que no sea cíclica)
			mc.gotoAndStop( 1 );
			mc.visible = false;
			// Si nos lo han indicado eliminamos el movieclip
			if( removeToEnd == true && mc.parent )
			{
				mc.parent.removeChild( mc );
			}
						
			// Llamamos al usuario
			if( callback != null )
				callback();
		}
		
		// 
		// Lanza el diálogo del número de turnos que quedan
		// NOTE: Solo se muestra cuando quedan 2, o 1 turno
		public function OnQuedanTurnos( turnos:int ) : void
		{
			var item:DisplayObject = null;
			
			// Creamos unos carteles para el nº de turnos del jugador
			
			// Elegimos un cartelito u otro
			if( turnos == 2 )
				item = QuedanTiros2;
			else if( turnos == 1 )
				item = QuedanTiros1;
			
			// Hacemos aparecer el cartelillo inmediatamente y lo fundimos
			if( item != null )
			{
				item.visible = true;
				item.alpha = 1.0;
				
				// Cuando termina el fundido del dialogo de QuedanTurnos lo ocultamos, ya que si no 
				// al estar por delante no podemos pulsar sobre las chapas
				TweenMax.to( item, 2, {alpha:0, onComplete: OnFinishTween } );
			}
		}

		// 
		// Lanza el diálogo de pase al pie con conflicto o sin conflicto
		// 
		public function OnMsgPasePie( bConConflicto:Boolean, conflicto:Object ) : void
		{
			if( bConConflicto )
			{
				// Creamos animación de pase al pie efectuado con conflicto de intento de robo!				
				var mc:MovieClip = CreateMovieClip( Assets.MensajePasealPieConConflicto, 200, 200 );
				FillConflicto( mc.ModuloConflicto, conflicto );
				LaunchCutScene( mc, true );
			}
			else
			{
				var item:DisplayObject = MensajePasealPie;
				
				// Hacemos aparecer el cartelillo inmediatamente y lo fundimos
				if( item != null )
				{
					item.visible = true;
					item.alpha = 1.0;
					
					// Cuando termina el fundido del dialogo de QuedanTurnos lo ocultamos, ya que si no 
					// al estar por delante no podemos pulsar sobre las chapas
					TweenMax.to( item, 2, {alpha:0, onComplete: OnFinishTween } );
				}
			}
		}
		
		//
		// Informa a los players de que este a sido el último pase al pie posible dentro del turno
		//
		public function OnLastPaseAlPie() : void
		{
			if (Match.Ref.Game.CurTeam.IsLocalUser)
				Match.Ref.Game.ChatLayer.AddLine("Este ha sido tu último pase al pie");
			else
				Match.Ref.Game.ChatLayer.AddLine("Este ha sido el último pase al pie de tu oponente");
		}
		
		// 
		// Lanza el diálogo de robo
		// NOTE: Deprecated. El robo se anuncia como un mensaje de turno especializado
		// 
		/*
		public function OnMsgRobo(  ) : void
		{
			var item:DisplayObject = MensajeRobo;
			
			// Hacemos aparecer el cartelillo inmediatamente y lo fundimos
			if( item != null )
			{
				item.visible = true;
				item.alpha = 1.0;
				
				// Cuando termina el fundido del dialogo de QuedanTurnos lo ocultamos, ya que si no 
				// al estar por delante no podemos pulsar sobre las chapas
				TweenMax.to( item, 2, {alpha:0, onComplete: OnFinishTween } );
			}
		}
		*/

		// 
		// Cuando termina el fundido del dialogo de QuedanTurnos lo ocultamos, ya que si no 
		// al estar por delante no podemos pulsar sobre las chapas
		// 
		public function OnFinishTween(  ) : void
		{
			QuedanTiros1.visible = false;
			QuedanTiros2.visible = false;
			MensajePasealPie.visible = false;
			MensajeRobo.visible = false;
		}
		
		// 
		// Mensaje de conflicto :
		// - A la izquierda el equipo defensor y a la derecha el atacante (o el que intenta robar)
		// 
		/*
		public function OnMsgConflicto( x:Number, y:Number, defense:int, attack:int, probabilidad:int ) : void
		{
			var item:MovieClip = this.CreateMovieClip( Embedded.Assets.MensajeConflicto, x, y );
			this.LaunchCutScene( item, true );
			
			var game:Game = Match.Ref.Game;
				
			var defender:Team = game.CurTeam;
				
			item.JugadorPropio.text = defender.Name;
			item.JugadorContrario.text = game.AgainstTeam( defender ).Name;
			
			item.ValorPropio.text = defense.toString();
			item.ValorContrario.text = attack.toString();
			item.Probabilidad.text = probabilidad.toString();
		}
		*/

		//
		// Rellena los datos de un panel de conflicto utilizando un Objeto "conflicto"
		//
		public function FillConflicto( item:MovieClip, conflicto:Object ) : void
		{
			var game:Game = Match.Ref.Game;
			var defender:Team = game.CurTeam;
			
			// Ponemos nombres de los equipos
			//item.JugadorPropio.text = defender.Name;
			//item.JugadorContrario.text = game.AgainstTeam( defender ).Name;
			
			// Ponemos nombres de las chapas concretas en el conflicto
			item.JugadorPropio.text = "Jugador Propio"; //conflicto.defenserCapName;
			item.JugadorContrario.text = "Jugador Contrario"; //conflicto.attackerCapName;
			item.ValorPropio.text = conflicto.defense.toString();
			item.ValorContrario.text = conflicto.attack.toString();
			item.Probabilidad.text = Math.round(conflicto.probabilidadRobo).toString() + "%";
		}
		
		//
		// Rellena los datos de un panel de conflicto utilizando un Objeto "conflicto" cuando se ha producido una falta
		//
		public function FillConflictoFault( item:MovieClip, conflicto:Object ) : void
		{
			var game:Game = Match.Ref.Game;
			
			if( conflicto.YellowCard == true && conflicto.RedCard == true)		// 2 amarillas
				item.Tarjeta.gotoAndStop( "dobleamarilla" );
			else if( conflicto.RedCard == true )
				item.Tarjeta.gotoAndStop( "roja" );
			else if( conflicto.YellowCard == true )
				item.Tarjeta.gotoAndStop( "amarilla" );
			else
				item.Tarjeta.gotoAndStop( 0 );
			
		
			var defender:Team = game.CurTeam;
			
			// Ponemos nombres de los equipos
			//item.JugadorPropio.text = defender.Name;
			//item.JugadorContrario.text = game.AgainstTeam( defender ).Name;
			
			// Ponemos nombres de las chapas concretas en el conflicto
			/*
			item.JugadorPropio.text = "Jugador Propio"; //conflicto.defenserCapName;
			item.JugadorContrario.text = "Jugador Contrario"; //conflicto.attackerCapName;
			item.ValorPropio.text = conflicto.defense.toString();
			item.ValorContrario.text = conflicto.attack.toString();
			item.Probabilidad.text = int(conflicto.probabilidadRobo).toString() + "%";
			*/
		}
		
		
		// 
		// Lanza el diálogo de final de partido
		// Deprecated
		/*
		public function OnFinalDialog( bDueToAbandon:Boolean = false, callback:Function = null ) : void
		{
			var dialog:MovieClip = null;
			
			if( bDueToAbandon == false )
				dialog = CreateGraphic( Embedded.Assets.FinalDialog, 100, 100 ) as MovieClip;
			else
				dialog = CreateGraphic( Embedded.Assets.FinalDialogLeave, 100, 100 ) as MovieClip;
			
			//LaunchCutScene( cutScene, true, callback );
			
			// Rellenamos los datos del diálogo
			
			var teams:Array = Match.Ref.Game.Teams;
			
			if( bDueToAbandon == false )
			{
				// Asigna el aspecto visual según que equipo sea. Tenemos que posicionarla en el frame que se llama como el quipo
				dialog.BadgeHome.gotoAndStop( teams[ Enums.Team1 ].Name );
				dialog.BadgeAway.gotoAndStop( teams[ Enums.Team2 ].Name );
				
				
				dialog.TeamHome.text = teams[ Enums.Team1 ].Name;
				dialog.TeamAway.text = teams[ Enums.Team2 ].Name;
				
				dialog.NameHome.text = teams[ Enums.Team1 ].UserName;
				dialog.NameAway.text = teams[ Enums.Team2 ].UserName;
			}
			
			// Estos campos los tienen todos los diálogos:
			
			//dialog.ValueXP.text = ;
			//dialog.ValuePuntosMahou.text = ;
			//dialog.ValueTrueSkill.text = ;
			
			// Cuando pulsen aceptar destruimos el control y llamamos al callback de usuario
			dialog.BotonAceptar.addEventListener( MouseEvent.CLICK, Framework.Callback.Create( OnEndCutScene, dialog, true, callback ) );
		}
		*/
		
		
		// 
		// Han pulsado en el botón de "Cerrar Aplicación"
		//
		public function OnAbandonar( event:Object ) : void
		{
			trace( "OnAbandonar: Cerrando cliente ...." );
			
			// Notificamos al servidor para que lo propague en los usuarios
			if( Server.Ref.Connection )
				Server.Ref.Connection.Invoke( "OnAbort", null );
			else
				trace( "OnAbandonar: [warning] La conexión es nula. Ya se ha cerrado el cliente" );
		}
		
		
		// 
		// Nos pone en modo de espera de respuesta del servidor
		// NOTE: (IMPORTANT): waitResponse es útil para eventos que se lanzan al servidor pero tenemos que esperar a que lleguen, ya que mientras
		// que llegan podrian producirse TimeOut o similares
		//
		public function WaitResponse(  ) : void
		{
			Match.Ref.Game.ResetTimeout();
			// Deshabilitamos la entrada de interface y pausamos el timeout
			UserInputEnabled = false;
			// NOTE: Hacer depués del reset, ya que dentro se asigna a true
			Match.Ref.Game.TimeOutPaused = true;
		}
		
	}
}
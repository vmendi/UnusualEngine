package Caps
{
	import Embedded.Assets;
	
	import Framework.*;
	
	import Net.Server;
	
	import com.greensock.*;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	public class Team
	{
		static public var Groups:Array =
			[
				// Grupo 1 
				[
					"Racing",
					"R. Madrid",
					"Sevilla",
					"Valencia",
					"Zaragoza",
				],
				// Grupo 2 
				[
					"Getafe",
					"Hércules",
					"Málaga",
					"Deportivo",
					"Espanyol",
					"R. Sociedad",
				],
				// Grupo 3 
				[
					"Atlético",
					"Athletic",
					"Almería",
					"Sporting",
				],
				// Grupo 4 
				[
					"Barcelona",
					"Levante",
					"Mallorca",
					"Osasuna",
				],
				// Grupo 5
				[
					"Villarreal",
				]
			]
		
		
		public const CAPS_BY_TEAM:int = 8;						// Número de chapas que tiene cada equipo
		
		protected var _CapsList:Array = new Array();			// Lista de chapas
		protected var _Name:String = null;						// El nombre del equipo
		public var UserName:String = null;						// El nombre del equipo (puesto por el usuario)
		
		public var IdxTeam:int = 0;								// Identificador de equipo
		public var Side:int = 0;								// Lado del campo en el que está el equipo
		protected var FormationName:String = "3-3-2";			// Alineación que está utilizando el equipo
		
		protected var _Goals:int = 0;							// Número de goles metidos
		
		protected var Skill:Array = null;						// Lista de habilidades. Una entrada para cada habilidad, si no la tiene es null
		
		public var Ghost:ImageEntity = null;					// Ghost utilizado para decidir donde colocarás el portero
		
		public var UseSecondaryEquipment:Boolean = false;		// Indica si utiliza la equipacion secundaria
		
		
		//
		// Inicializa el equipo
		//
		/*
		//
		// El Object "descTeam" es un objeto con la siguiente topología:
		//
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
		
		// Todos los futbolista, osrdenados según la posición/formacion. Primero siempre el portero.
		public List<SoccerPlayerData> SoccerPlayers;	
		}
		*/
		public function Init( descTeam:Object, teamId:int, useSecondaryEquipment:Boolean = false ) : void
		{
			Name = descTeam.PredefinedTeamName;
			UserName = descTeam.Name;
			IdxTeam = teamId;
			FormationName = descTeam.Formation;
			UseSecondaryEquipment = useSecondaryEquipment;
			
			// Obtenemos el array de jugadores ( viene desde red como un mx.collections::ArrayCollection )
			var soccers:Array = Collections.ToArray( descTeam.SoccerPlayers );
			
			// Copiamos la lista de habilidades especiales, convirtiéndola a un array
			LoadSkills( Collections.ToArray( descTeam.SpecialSkillsIDs ) );
			
			var descCap:Object = { 
				Number: 13,
				Name: "Cap Name",
				Power: 0,
				Control: 0,
				Defense: 0
			} 
			
			// Inicializamos cada una de las chapas 
			for( var i:int = 0; i < CAPS_BY_TEAM; i++ )
			{
				// Creamos una chapa y la agregamos a la lista
				var cap:Cap = new Cap();
				CapsList.push( cap );
				
				// Inicializamos la chapa
				var capName:String = "Cap " + i.toString();
				if( soccers )
					descCap = soccers[i];
				
				cap.InitFromTeam( this, i, descCap );
				
				// Añadimos la entidad al gestor de entidades 
				EntityManager.Ref.AddTagged( cap, "Team"+(teamId+1).toString() + "_" + i.toString() );
			}
			
			// El equipo 1 empieza en el lado izquierdo y el 2 en el derecho
			if( IdxTeam == Enums.Team1 )
				Side = Enums.Left_Side;
			else if( IdxTeam == Enums.Team2 )
				Side = Enums.Right_Side;
			
			// Asignamos la posición inicial de cada chapa según la alineación y lado del campo en el que se encuentran
			ResetToCurrentFormation();
			
			// Añadimos la entidad al gestor de entidades 
			//EntityManager.Ref.AddTagged( cap, "Team"+(teamId+1).toString() + "_" + i.toString() );
			
			// Creamos una imagen de chapa Ghost (la utilizaremos para indicar donde mover el portero)
			Ghost = new ImageEntity();
			Ghost.Init( Embedded.Assets.Goalkeeper, Match.Ref.Game.GameLayer ); 
			Ghost.Visual.gotoAndStop( Name );
			Ghost.Visual.alpha = 0.4;
			Ghost.Visual.visible = false;
		}
		
		//
		// Ponemos al equipo en el lado invertido (es la 2ª parte)
		//
		public function InvertedSide(  ) : void
		{
			// El equipo 1 empieza en el lado izquierdo y el 2 en el derecho
			if( IdxTeam == Enums.Team1 )
				Side = Enums.Right_Side;
			else if( IdxTeam == Enums.Team2 )
				Side = Enums.Left_Side;
		}
		
		
		public function get Name():String {
			return _Name;
		}
		public function set Name( value:String ):void 
		{
			_Name = value;
		}
		public function get CapsList( ) : Array
		{
			return _CapsList; 
		}
		public function get Goals( ) : int
		{
			return _Goals; 
		}
		public function set Goals( value:int ) : void
		{
			_Goals = value; 
		}
		// Retornamos el portero del equipo
		public function get GoalKeeper( ) : Cap
		{
			return this.CapsList[ 0 ]; 
		}
		
		//
		// Posicionamos todas las chapas del equipo según la alineación y el lado del campo en el que están
		//
		public function ResetToCurrentFormation(  ) : void
		{
			// Asignamos la posición inicial de cada chapa según la alineación y lado del campo en el que se encuentran
			SetFormationPos( FormationName, Side );
		}
		
		//
		// Devuelve al portero a su posición de formación original. Se usa después de un SaquePuerta, al acabar de simular el tiro
		//
		public function ResetToCurrentFormationOnlyGoalKeeper() : void
		{
			// Por si acaso el portero hace su segunda tarjeta amarilla en el saque de puerta...		
			if (GoalKeeper != null && GoalKeeper.YellowCards != 2)
			{
				var currentFormation : Array = GetFormation(FormationName);
				
				// Si hay algún obstaculo en esa posicion, no podemos resetear al portero, ignoramos la orden
				var desiredPos : Point = ConvertFormationPosToFieldPos(currentFormation[0], Side);
				
				if (Match.Ref.Game.GetField().ValidatePosCap(desiredPos, true, GoalKeeper))
					SetFormationPosForCap(GoalKeeper, currentFormation[0], Side);
			}
		}

		//
		// Posicionamos todas las chapas del equipo según la alineación y el lado del campo en el que están
		// La formación se especifica en forma de cadena. 
		// El hash de formaciones de match debe tener un array para esa entrada de cadena
		//
		protected function SetFormationPos( formationName:String, side:int  ) : void
		{
			var currentFormation : Array = GetFormation(formationName);
							
			for ( var i:int = 0; i < CapsList.length; i++ )
			{
				// Si la chapa no está expulsada la colocamos en posición de alineación
				if( CapsList[i] != null && CapsList[i].YellowCards != 2 )
				{
					SetFormationPosForCap(CapsList[i], currentFormation[i], side);
				}
			}
		}
		
		private function GetFormation(formationName : String) : Array
		{
			var formation:Array = null;
			
			if( AppParams.OfflineMode )
				formation = OfflineFormations.Position[0];
			else
				formation = Match.Ref.Formations[ formationName ];
			
			if( formation == null )
				throw new Error( "No existe la formación solicitada " + formationName );

			return formation;
		}
		
		private function SetFormationPosForCap(cap : Cap, formationPos:Object, side:int) : void
		{
			// Las posiciones de formacion vienen sin aplicar offset & mirror
			var pos : Point = ConvertFormationPosToFieldPos(formationPos, side);	
			
			// Asignamos la posición y detenemos cualquier movimiento que estuviera realizando la chapa
			cap.SetPos ( pos );
			cap.StopMovement();
		}
		
		static private function ConvertFormationPosToFieldPos(formationPos:Object, side:int) : Point
		{
			// Obtenemos la posición del jugador en el lado "izquierdo" del campo para la alineación dada
			var pos : Point = new Point(formationPos.x + Field.OffsetX, formationPos.y + Field.OffsetY);
			
			// Reflejamos la posicion horizontalmente sobre el centro del campo si estamos en el lado derecho
			if( side == Enums.Right_Side )
				pos.x = Field.CenterX - pos.x + Field.CenterX;
			
			return pos;
		}
		
		
		//
		// Calcula la lista de chapas que están dentro del circulo indicado
		//
		public function InsideCircle( center:Point, radius:Number  ) : Array
		{
			var inside:Array = new Array();
			
			// Calculamos las chapas que están en un radio determinado
			
			// Iteramos por todas las chapas
			for each( var cap:Cap in CapsList )
			{
				if( cap != null && cap.InsideCircle( center, radius ) == true )
					inside.push( cap );
				
			}
			
			return( inside );
		}
		
		//
		// Comprueba si el equipo es el del "Usuario Local" de la máquina  
		//
		public function get IsLocalUser(  ) : Boolean
		{
			return( this.IdxTeam == Server.Ref.IdLocalUser ? true : false );
		}
		
		
		//
		// Genera el array completo de skills a partir de un array de identificadores de habilidades disponibles 
		//
		private function LoadSkills( availableSkillsIDs:Array ) : void
		{
			Skill = new Array( Enums.SkillLast+1 );
			
			// En modo debug: Nos damos todos los items
			if( AppParams.Debug == true )
				availableSkillsIDs = new Array( 1, 2, 4, 5, 6, 7, 8, 9 );
			
			if( availableSkillsIDs != null )
			{
				// Recorremos la lista de habilidades disponibles generando la entrada para cada habilidad
				for each( var item:int in availableSkillsIDs )
				{
					// Skill disponible y al 100% de carga
					var descSkill:Object = new Object();
					descSkill.Available = true;
					descSkill.PercentCharged = 100;
					descSkill.Activated = false;
					
					Skill[item] = descSkill;  
				}
			}
			else
				trace( "La lista de habilidades es null!" );
		}
		
		//
		// Comprueba si tiene una habilidad determinada
		//
		public function HasSkill( idSkill:int ) : Boolean
		{
			return( Skill[ idSkill ] && Skill[ idSkill ].Available );
		}
		
		//
		// Bucle principal del equipo 
		// Se invoca a frecuencia constante APP_LOGIC_FPS / Sec
		// elapsed: Tiempo que ha pasado en segundos
		//		
		public function Run( elapsed:Number ) : void
		{
			// Cargamos las habilidades que hayan sido utilizadas
			for( var i:int = Enums.SkillFirst; i <= Enums.SkillLast; i++ )
			{
				var item:Object = this.Skill[ i ];
				
				// Skill disponible y al 100% de carga
				if( item != null && item.Available == true && item.PercentCharged < 100 )
				{
					item.PercentCharged += AppParams.PercentSkilLRestoredPerSec[ i ] * elapsed;
					if( item.PercentCharged > 100 )
						item.PercentCharged = 100;
				}
			}
		}
		
		//
		// Obtiene el porcentaje de carga de una habilidad
		// Si se pide una habilidad que no se tiene se devuelve 0
		//
		public function ChargedSkill( idSkill:int ) : int
		{
			return( HasSkill( idSkill ) ? Skill[ idSkill ].PercentCharged : 0 );
		}
		
		//
		// Utiliza una skill!
		// Lo activa y lo pone a 0 de carga!
		//
		public function UseSkill( idSkill:int ) : void
		{
			//if( HasSkill( idSkill ) == false || ChargedSkill( idSkill) < 100 )
			if( HasSkill( idSkill ) == false )
			{
				throw new Error( "Skill no disponible según los datos del cliente! Skill="+idSkill.toString()+" HasSkill="+HasSkill( idSkill ).toString()+" Charge="+ChargedSkill( idSkill).toString() );
			}
			else
			{
				// NOTE: Los datos de carga de la skill de cada cliente no tienen porque ser iguales, realmente solo importan los del cliente que lanza
				// la habilidad, con lo cual no determina si lanzar o no la skill. Simplemente lanzamos una traza para poder analizar posibles intentos
				// de hack, ya que en situaciones sin lag deberían tener valores casi idénticos
				if( ChargedSkill( idSkill) < 100 )
					trace( "Skill no cargada según los datos del cliente! Skill="+idSkill.toString()+" HasSkill="+HasSkill( idSkill ).toString()+" Charge="+ChargedSkill( idSkill).toString() );
					
				Skill[ idSkill ].PercentCharged = 0;
				Skill[ idSkill ].Activated = true;
			}
		}
		
		//
		// Comprueba si una habilidad está siendo utilizada
		//
		public function IsUsingSkill( idSkill:int ) : Boolean
		{
			return( ( HasSkill( idSkill ) && Skill[ idSkill ].Activated ) );
		}
		
		//
		// Desactiva los skills en uso
		//
		public function DesactiveSkills(  ) : void
		{
			if( HasSkill( Enums.Superpotencia ) )
				Skill[ Enums.Superpotencia ].Activated = false;
			if( HasSkill( Enums.Furiaroja  ) )
				Skill[ Enums.Furiaroja ].Activated = false;
			if( HasSkill( Enums.Catenaccio ) )
				Skill[ Enums.Catenaccio ].Activated = false;
			if( HasSkill( Enums.Tiroagoldesdetupropiocampo) )
				Skill[ Enums.Tiroagoldesdetupropiocampo ].Activated = false;
			if( HasSkill( Enums.Tiempoextraturno ) )
				Skill[ Enums.Tiempoextraturno ].Activated = false;
			if( HasSkill( Enums.Turnoextra ) )
				Skill[ Enums.Turnoextra ].Activated = false;
			if( HasSkill( Enums.Verareas ) )
				Skill[ Enums.Verareas ].Activated = false;
			if( HasSkill( Enums.CincoEstrellas ) )
				Skill[ Enums.CincoEstrellas ].Activated = false;
			if( HasSkill( Enums.Manodedios ) )
				Skill[ Enums.Manodedios ].Activated = false;
		}
		
		// 
		// Obtenemos el radio de pase al pie del equipo, teniendo en cuenta  las habilidades especiales.
		//
		public function get RadiusPase ( ) : int
		{
			var radius:int = AppParams.RadiusPaseAlPie;
			// La habilidad 5 estrellas multiplica el radio
			if( IsUsingSkill( Enums.CincoEstrellas ) ) 
				radius *= AppParams.InfluencesMultiplier;
			return( radius );
		}
		// 
		// Obtenemos el radio de robo del equipo, teniendo en cuenta  las habilidades especiales.
		//
		public function get RadiusSteal( ) : int
		{
			var radius:int = AppParams.RadiusSteal;
			// La habilidad 5 estrellas multiplica el radio
			if( IsUsingSkill( Enums.CincoEstrellas ) ) 
				radius *= AppParams.InfluencesMultiplier;
			return( radius );
		}
		
		// 
		// Obtenemos el grupo al que pertenece el equipo 
		// NOTE: Todos los equipos pertenecen a un grupo en función de los colores de su equipación
		//
		static public function GroupTeam( teamName:String ) : int
		{
			var groupIdx:int = 0;
			for each ( var group:Array in Team.Groups )
			{
				groupIdx ++;
				for each ( var name:String in group )
				{
					if( name == teamName )
						return( groupIdx );
				}
			}
			
			throw new Error( "El equipo " + teamName + " no está en ninguna de las listas de equipacion. Estan mal escritos los nombres? " );
			
			return( 0 );
		}
		
		// 
		// Expulsamos una chapa, para ello simplemente la movemos fuera de la zona de juego 
		//
		public function FireCap( cap:Cap ) : void
		{
			// Contabilizamos el numero de expulsiones
			Match.Ref.Game.FireCount ++;
			
			// Cuando se expulsa un jugador lo registramos como 2 tarjetas amarillas, porque no tenemos un flag único para ello
			cap.YellowCards = 2;
			
			// Si es el portero, hay que substituirlo
			if (cap == GoalKeeper)
			{
				// Buscamos una chapa que no este expulsada
				var other : Cap = GetRandomNotFiredCap();
				
				if (other != null)
				{
					// Truco sucio: Hacemos que el portero coja las propiedades de la otra chapa. Es "como si" el recien expulsado 
					// portero hubiera sido substituido por la otra chapa
					cap.ImpersonateOther(other);
					
					// Expulsamos realmente a la otra. Nuestro portero tendrá las faltas amarillas q tuviera el jugador substituto.
					other.YellowCards = 2;
					
					// Movemos al nuevo portero
					ResetToCurrentFormationOnlyGoalKeeper();
					
					// Y es a la otra a la que movemos fuera
					cap = other;
				}
			}
			
			// Hacemos un clon visual que es el que realmente desvanecemos
			var visual : DisplayObject = (cap.Visual as DisplayObject); 
			var cloned : MovieClip = new (getDefinitionByName(getQualifiedClassName(cap.Visual)) as Class)();
			visual.parent.addChild(cloned);
			cloned.gotoAndStop(this.Name);
			cloned.x = visual.x; cloned.y = visual.y;
			cloned.rotationZ = cap.PhyBody.angle * 180.0 / 3.1416;
			
			// Colocamos la chapa fuera del area de visión. Las llevamos a puntos distintos para que no colisionen
			var pos:Point = new Point( -100, -100 );
			pos.x -= Match.Ref.Game.FireCount * ((Cap.Radius * 2) * 5);
			cap.SetPos( pos );
								
			// Hacemos desvanecer el clon
			TweenMax.to( cloned, 2, {alpha:0, onComplete: Callback.Create( OnFinishTween, cloned ) } );
		}
		
		private function GetRandomNotFiredCap() : Cap
		{
			for each (var cap : Cap in CapsList)
			{
				if (cap.YellowCards < 2)
					return cap;
			}
			return null;
		}
		
		public function OnFinishTween( cap:DisplayObject  ) : void
		{
			cap.parent.removeChild(cap);
		}
	}
}


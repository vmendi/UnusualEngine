package Caps
{
	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.b2Body;
	
	import Embedded.Assets;
	
	import Framework.Entity;
	import Framework.ImageEntity;
	import Framework.PhyEntity;
	
	import com.actionsnippet.qbox.QuickObject;
	import com.greensock.*;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	//
	// La chapa de un equipo
	// Características:
	//   
	// TODO: Derivar de Entity!!!! e implementar física / visual / update!!
	//
	public class Cap extends PhyEntity
	{
		static public const Radius:Number = 15;
		
		// Información cosmética del jugador
		protected var _Name:String = null;						// Nombre del jugador
		protected var _Dorsal:int = 0;							// Nº de dorsal del jugador
				
		// Características
		
		protected var _Defense:int = 50;						// Valor de defensa de 0 - 100 --> (Afecta a la capacidad de evitar el robo de balón.... )
		protected var _Power:int = 50;							// Valor de ataque (Potencia) de 0 - 100 --> (Afecta a la potencia de tiro)
		protected var _Control:int = 50;						// Control de 0 - 100 --> (Afecta a la capacidad de robar el balón.... ) 
				
		protected var _OwnerTeam:Team = null;					// Equipo dueño de la chapa
		
		private var Influence:Sprite = null;					// Objeto visual para pintar la influencia de la chapa
		private var TimeShowingInfluence:Number = 0;			// Tiempo que se lleva mostrando el area de influencias desde la última vez que se mando pintar
		private var _ShowInfluence:Boolean=false;				// Indica si se está pintando
		
		private var CapId:int = (-1);							// Identificador de la chapa
		
		private var ColorInfluence:int = Enums.FriendColor; 		// Color del radio de influencia visual
		private var SizeInfluence:int = AppParams.RadiusPaseAlPie;	// tamaño del radio de influencia visual
				
		public var YellowCards:int = 0; 						// Número de tarjetas amariallas (2 = roja = expulsión)
		
				
		//
		// Inicializa una chapa
		//
		/*
		// El Object "descCap" es un objeto con la siguiente topología:
		//
		public class SoccerPlayerData
		{
			public int	  Number;		// Dorsal
			public String Name;			
			public int    Power;
			public int    Control;
			public int    Defense;
		}
		*/
		
		public function InitFromTeam( team:Team, id:int, descCap:Object ) : void
		{
			// Elegimos el asset de jugador o portero (y con la equipación primaria o secundaria)
			var asset:Class = Embedded.Assets.Cap;
			
			if( team.UseSecondaryEquipment )
				asset = Embedded.Assets.Cap2;
			
			if( id == 0 )
			{
				asset = Embedded.Assets.Goalkeeper;
				if( team.UseSecondaryEquipment )
					asset = Embedded.Assets.Goalkeeper2;
			}
			
			super.InitWithPhysic( asset, Match.Ref.Game.GameLayer, PhyEntity.Circle, {  					
				radius: AppParams.Screen2Physic( Radius ),
				isBullet: true, 			// UseCCD: Detección de colisión continua (Ninguna chapa se debe atravesar)
				mass: 1.7,
				isSleeping: true, 
				allowSleep: true, 
				friction: .3, 
				restitution:/*.3*/.6,			// Fuerza que recupera en un choque 
				linearDamping: /*2*/5, 
				angularDamping: 5 } );
			
			// Reasignamos la escala de la chapa, ya que la física la escala para que encaje con el radio físico asignado
			this.Visual.scaleX = 1.0;
			this.Visual.scaleY = 1.0;
			
			if( AppParams.Debug == true )
			{
				// En modo debug cambiamos la equipación del Sporting porque es identia a la del atleti 
				if( team.Name == "Sporting" )
					team.Name = "Deportivo";
			}
				
			// Asigna el aspecto visual según que equipo sea. Tenemos que posicionarla en el frame que se llama como el quipo
			_Visual.gotoAndStop( team.Name );
			
			_Name = descCap.Name;
			_Dorsal = descCap.Number;
			_Power = descCap.Power;
			_Control = descCap.Control;
			_Defense = descCap.Defense;
			_OwnerTeam = team;
					
			// Nos registramos a los eventos de entrada del ratón! (menos para las chapas Ghost id=(-1)
			if( id != (-1) )
				_Visual.addEventListener( MouseEvent.MOUSE_DOWN, OnMouseDown );
			
			// Creamos un Sprite linkado a la chapa, donde pintaremos los radios de influencia de la chapa
			// Estos sprites los introducimos como hijos del campo, para asegurar que se vean debajo de las chapas 
			Influence = new Sprite();
			Match.Ref.Game.GetField().Visual.addChild( Influence );
			DrawInfluence();
			Influence.alpha = 0.0;
			
			CapId = id;
		}
		
		//
		// Han presionado el botón del ratón sobre la chapa
		// Notificamos al interface de juego para que actúe en consecuencia 
		//
		private function OnMouseDown( e: MouseEvent ) : void
		{			
			Match.Ref.Game.Interface.OnClickCap( this );
		}
		
		//
		// Dispara con una fuerza sobre una chapa
		// La fueza debe especificarse entre 0 - 1
		//
		public function Shoot( dir:Point, force:Number ): void
		{
			// Calculamos el vector final
			var vecForce:Point = new Point();
			dir.normalize( force * AppParams.MaxCapImpulse );
			
			// El vector de fuerza lo aplicamos en el sentido contrario, ya que funciona como una goma elástica
			vecForce.x = -dir.x; 
			vecForce.y = -dir.y;
			
			// Aplicamos el impulso al cuerpo físico
			PhyObject.body.ApplyImpulse( new b2Vec2( vecForce.x, vecForce.y ), PhyObject.body.GetWorldCenter() );
		}
		
		public function get OwnerTeam( ) : Team
		{
			return _OwnerTeam;
		}
		public function get Name( ) : String
		{
			return _Name;
		}
		public function get Id( ) : int
		{
			return CapId;
		}
		public function get Defense( ) : int
		{
			return _Defense;
		}
		public function get Power( ) : int
		{
			return _Power;
		}
		public function get Control( ) : int
		{
			return _Control;
		}
		
		//
		// Copia las propiedades de otra chapa en esta chapa. Util por ejemplo para en la expulsion del portero, substituirlo.
		//
		public function ImpersonateOther(other : Cap) : void
		{
			if (this._OwnerTeam != other._OwnerTeam)
				throw new Error("El equipo debe ser el mismo");
			
			this._Control = other._Control;
			this._Defense = other._Defense;
			this._Dorsal = other._Dorsal;
			this._Name = other._Name;
			this.YellowCards = other.YellowCards;
		}
		
		//
		// Obtiene el Ghost de la chapa (solo hay uno por equipo)
		//
		public function get Ghost( ) : ImageEntity
		{
			return this.OwnerTeam.Ghost;
		}
		
		//
		// Obtiene el vector de dirección desde la chapa que apunta hacia la portería contraria
		//
		public function get DirToGoal( ) : Point
		{
			// Obtenemos el punto donde está la portería contraria
			
			var target:Point = Field.GetCenterGoal( Enums.AgainstSide( OwnerTeam.Side ) );
			// Retornamos el vector de direccion
			return( target.subtract( GetPos() ) );
		}
		
		//
		// Devuelve si está atacando o no.
		// Se considera que una chapa está atacando cuando está en la mitad del campo oponente
		//
		public function get IsAttacking( ) : Boolean
		{
			var x:Number = GetPos().x;
			var centerX:Number = Field.CenterX;
			
			if( OwnerTeam.Side == Enums.Left_Side )
			{
				if( x < centerX )
					return false;
				return true;
			}
			else /* if( OwnerTeam.Side == Enums.Right_Side ) */
			{
				if( x > centerX )
					return false;
				return true;
			}
		}
		
		//
		// Cambia el color del radio de influencia
		// NOTE: Esto no quiere decir que se pinte!
		//
		public function SetInfluenceAspect( color:int, size:Number ) : void
		{
			// Si algo cambia, reasignamos
			if( color != ColorInfluence || size != SizeInfluence )
			{
				ColorInfluence = color;
				SizeInfluence = size;
				
				DrawInfluence( );
			}
		}
		
		//
		// Pinta las influencias
		//
		protected function DrawInfluence( ) : void
		{
			Influence.graphics.clear( );
			Influence.graphics.lineStyle( 1, ColorInfluence, 0.4 );
			
			Influence.graphics.beginFill( ColorInfluence, 0.3 );
			Influence.graphics.drawCircle( 0, 0, SizeInfluence );
			Influence.graphics.endFill();
		}
		
		//
		// Mostramos/ocultamos el radio de influencia de la chapa
		// y reseteamos el tiempo mostrando influencia
		public function set ShowInfluence( value:Boolean ) : void
		{
			if (value != _ShowInfluence)
			{	
				_ShowInfluence = value;
				TimeShowingInfluence = 0;
				
				if( _ShowInfluence )			
					TweenMax.to( this.Influence, 1, {alpha:1} );
				else
					TweenMax.to( this.Influence, 1, {alpha:0} );
			}
		}
		
		public function get ShowInfluence() : Boolean
		{
			return _ShowInfluence;
		}		
		
		//
		// Se ejecuta a velocidad de pintado
		// - Se encarga de copiar el objeto físico al objeto visual
		//
		public override function Draw( elapsed:Number ) : void
		{
			super.Draw( elapsed );
			
			if( this.Visual )
			{
				// Reasignamos la posicion del objeto de radio de influencia, para que siga a la chapa
				Influence.x = GetPos().x;			
				Influence.y = GetPos().y;
			}
				
			// Apagamos al cabo de 2 segundos
			if( ShowInfluence )
			{
				TimeShowingInfluence += elapsed;
				
				if( TimeShowingInfluence > 2.0 )
					ShowInfluence = false;
			}
		}
	}
}
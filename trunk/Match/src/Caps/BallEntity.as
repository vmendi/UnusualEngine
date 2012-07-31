package Caps
{
	import Box2D.Collision.Shapes.b2MassData;
	import Box2D.Common.Math.b2Vec2;
	
	import Embedded.Assets;
	
	import Framework.PhyEntity;
	
	import flash.geom.Point;

	public class BallEntity extends PhyEntity
	{
		static public const Radius:Number = 9;
		//
		// Inicializa el balón de juego
		//
		public function Initialize(  ) : void
		{
			// Inicializamos la entidad
			// NOTE: Inicializamos el objeto físico en el grupo (-1) para poder hacer que los obstáculos de las porterías no le afecten)
			super.InitWithPhysic( Embedded.Assets.Ball, Match.Ref.Game.GameLayer, PhyEntity.Circle, {
				mass: 0.04,
				fixedRotation: true,		// If set to true the rigid body will not rotate.
				isBullet: true, 			// UseCCD: Detección de colisión continua
				groupIndex:-1, 
				radius:AppParams.Screen2Physic( Radius ), 
				isSleeping: true, 
				allowSleep: true, 
				linearDamping: 4 /*1*/, 
				angularDamping: /*2*/4, 
				friction:.2, 
				restitution: .4 } );	// Fuerza que recupera en un choque
			
			// Reasignamos la escala del balón, ya que la física lo escala para que encaje con el radio físico asignado
			this.Visual.scaleX = 1.0;
			this.Visual.scaleY = 1.0;
			
			// Asignamos el estado inicial
			Reset();
		}
		
		// 
		// Resetea al estado inicial el balón
		// (en el centro, parado, ...)
		//
		public function Reset( ) : void
		{
			SetPos( new Point( Field.CenterX, Field.CenterY ) );
			StopMovement();
			super._Visual.stop();	// Detenemos animación
		}
		
		//
		// Se ejecuta a velocidad de pintado
		// - Se encarga de copiar el objeto físico al objeto visual
		//
		public override function Draw( elapsed:Number ) : void
		{
			// Obtenemos la velocidad del balón  
			var vel:Number = PhyObject.body.GetLinearVelocity().LengthSquared();
			
			// TODO: Adaptamos la velocidad de reproducción la animación a la velocidad física del balón
			// De momento solo hacemos un modelo de parado o en movimiento
			if( IsMoving == false )
				_Visual.stop();
			else
				_Visual.play();
		}
		
		
		// 
		// Asigna la posición de la pelota en frente de la chapa
		// En frente quiere decir mirando a la dirección de la mitad del campo del oponente
		// NOTE: No se valida la posición!
		//
		public function SetPosInFrontOf( cap:Cap ) : void
		{
			var pos:Point = cap.GetPos();
			
			var len:Number = Cap.Radius + BallEntity.Radius;
			var dir:Point = new Point( len, 0 );
			if ( cap.OwnerTeam.Side == Enums.Right_Side )
				dir = new Point( -len, 0 );
			
			var newPos:Point =  pos.add( dir );
			SetPos( newPos );
			
			// Detenemos el movimiento que pudiera tener la pelota
			this.StopMovement();
		}
		
		
	
	}
}
package Framework
{
	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.b2Body;
	
	import Caps.AppParams;
	
	import com.actionsnippet.qbox.QuickObject;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	//
	// Entidad con aspecto visual y físico 
	//
	public class PhyEntity extends ImageEntity
	{
		// Tipos de primitivas físicas
		static public const Circle:int = 1;
		static public const Box:int = 2;
				
		protected var PhyObject:QuickObject = null				// Objeto físico
			
		//
		// Inicializa una entidad con aspecto visual. 
		//   - Se le pasa la clase que debe instanciar
		// Asignamos al userData de la shape a la entidad
		// NOTE: Si no se especifica un parent, la entidad no será visible
		//
		public function InitWithPhysic( assetClass:Class, parent:DisplayObjectContainer, primitiveType:Number, params:Object  ) : Boolean
		{
			//super.Init( assetClass, parent );
			
			// Asignamos valores por defecto si no los ha asignado el usuario
			params.skin = assetClass;
			if( params.isSleeping == null )
				params.isSleeping = true;
			if( params.allowSleep == null )
				params.allowSleep = true;
				
			// Creamos la primitiva física indicada
			if( primitiveType == Circle )
			{
				PhyObject = Match.Ref.Game.Physic.addCircle( params );
			}
			else if( primitiveType == Box )
			{
				PhyObject = Match.Ref.Game.Physic.addBox( params );
			}
			
			// Cogemos el objeto visual desde el objeto físico
			// NOTE: No tenemos control de cuando se está actualizando
			_Visual = PhyObject.userData;
			
			// Si nos han indicado un padre al que linkar lo linkamos
			if( _Visual != null && parent != null )
				parent.addChild( _Visual );
			
			// Asignamos al userData del "shape" del objeto físico a una referencia a la entidad
			if ( PhyObject != null )
				PhyObject.shape.m_userData = this;
			
			return true;
		}
		
		//
		// Destruye el elemento físico y visual asociado
		//
		public override function Destroy(   ) : void
		{
			super.Destroy();
			if( PhyObject != null )
				PhyObject.destroy();
			PhyObject = null;			
		}
		
		//
		// Se ejecuta a velocidad de pintado
		// - Se encarga de copiar el objeto físico al objeto visual
		//
		public override function Draw( elapsed:Number ) : void
		{
			/*
			// TODO: Eliminar referencia externa a Screen2Physic
			Visual.x = Caps.AppParams.Physic2Screen( PhyObject.x );
			Visual.y = Caps.AppParams.Physic2Screen( PhyObject.y );
			*/
		}
		
		//
		// Es visible?
		//
		public override function set Visible( value:Boolean ) : void
		{
			super.Visible = value;
		}
		
		//
		// Posicionamiento del objeto lógico
		// TODO: Definir como funciona el pipeline físico / visual!!!
		//
		public override function SetPos( pos:Point ) : void
		{
			super.SetPos( pos ); 
	
			// TODO: Eliminar referencia externa a Screen2Physic
			PhyObject.setLoc( Caps.AppParams.Screen2Physic( pos.x ), Caps.AppParams.Screen2Physic( pos.y ) ); 
		}
		
		public override function GetPos( ) : Point
		{
			return super.GetPos();
		}

		// Obtenemos el cuerpo físico
		public function get PhyBody( ) : QuickObject
		{
			return PhyObject;
		}
		
		//
		// Detiene cualquier tipo de movimiento físico que esté realizando la entidad
		//
		public function StopMovement( ) : void
		{
			PhyObject.body.SetLinearVelocity( new b2Vec2( 0, 0 ) );
			PhyObject.body.SetAngularVelocity( 0 );
			// Dormimos el objeto inmediatamente, para que deje de simular!
			PhyObject.body.PutToSleep();
		}
		// 
		// Devuelve si la entidad está o no en movimiento
		//
		public function get IsMoving( ) : Boolean
		{
			var vel:Number = PhyObject.body.GetLinearVelocity().LengthSquared();
			// TODO: Usar un threshold!
			//if( vel <= 0.01 )
			if( PhyObject.body.IsSleeping() )
				return false;
			return true;
		}
		
		
	}

}
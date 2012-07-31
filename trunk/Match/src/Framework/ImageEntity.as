package Framework
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	//
	// Entidad básica con aspecto visual
	//
	public class ImageEntity extends Entity
	{
		protected var _Visual:* = null;					// Objeto visual
		
		//
		// Inicializa una entidad con aspecto visual. 
		//   - Se le pasa la clase que debe instanciar
		// NOTE: Si no se especifica un parent, la entidad no será visible
		//
		public function Init( assetClass:Class, parent:DisplayObjectContainer  ) : Boolean
		{
			if(  assetClass == null )
				return false;
			
			// Creamos el objeto visual de la chapa
			// TODO: Hacer hijas de un objeto visual que nos permita englobarlas!
			_Visual = new assetClass;
			if( parent != null )
				parent.addChild( _Visual );
			
			return true;
		}
		
		//
		// Destruye el elemento visual asociado
		//
		public function Destroy(   ) : void
		{
			if( _Visual != null )
			{
				var parent:DisplayObjectContainer = _Visual.parent as DisplayObjectContainer; 
				if( parent != null )
					parent.removeChild( _Visual );
				_Visual = null;
			}
		}

		//
		// Posicionamiento del objeto lógico
		// TODO: Definir como funciona el pipeline físico / visual!!!
		//
		public function SetPos( pos:Point ) : void
		{
			_Visual.x = pos.x;
			_Visual.y = pos.y;
		}
		
		public function GetPos( ) : Point
		{
			return new Point( _Visual.x, _Visual.y );
		}
		
		// Obtenemos el objeto visual
		public function get Visual( ) : *
		{
			return _Visual;
		}
		
		//
		// Es visible?
		//
		public function get Visible( ) : Boolean
		{
			return _Visual.visible;
		}
		public function set Visible( value:Boolean ) : void
		{
			_Visual.visible = value;
		}
		
		//
		// Calcula si la posición de la entidad está dentro del circulo indicado
		// NOTE: Esta función no tienen en cuenta el tamaño de la propia entidad (solo utiliza la posición)
		//
		public function InsideCircle( center:Point, radius:Number  ) : Boolean
		{
			// Calculamos la distancia del centro del círculo a la entidad, si este
			// es menor que el radio de la circunferencia está dentro
			
			var vDist:Point = center.subtract( GetPos() );
			var length:Number = vDist.length;
			if( length > radius )
				return false;
			
			return true;
		}
		
		//
		// Devuelve la entidad que está más cerca de nosotros
		// NOTE: Funciona con ImageEntity!!!
		// TODO: El interface de posición debería existir desde la entidad base o posicionable!! Una entidad que no sea una imagen 2D podría tener posición
		// TODO: Este método no tiene en cuenta las transformaciones de mundo, opera todo en local!
		//
		public function NearestEntity( entities:Array  ) : ImageEntity
		{
			var nearestEntity:ImageEntity = null;
			var nearestDistance:Number = Number.MAX_VALUE;
			
			// Iteramos por todas las entidades
			for each( var ent:ImageEntity in entities )
			{
				// Calculamos la distancia entre las 2 entidades, 
				// y si es menor que la más pequeña encontrada hasta ahora la guardamos
				
				var vDist:Point =  ent.GetPos().subtract( this.GetPos() );
				var length:Number = vDist.length;
				if( length < nearestDistance )
				{
					nearestDistance = length;
					nearestEntity = ent;
				}
			}
			
			
			return ( nearestEntity );
		}
			
	}
}
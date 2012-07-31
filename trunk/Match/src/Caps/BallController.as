package Caps
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	//
	// Se encarga del controlador para posicionar la pelota alrededor de la chapa
	//
	public class BallController extends Controller
	{
		private var canvas        : Sprite;
		private var maxLongLine   : uint;
		private var colorLine	  : uint;
		private var thickness	  : uint;
		
		private const BLACK    	  : uint = 0x000000;
		
		
		public function BallController( canvas:Sprite, maxLongLine: uint, colorLine: uint = 0, thickness: uint = 1 )		
		{
			this.maxLongLine = maxLongLine;
			this.canvas 	 = canvas;
			this.thickness   = thickness;
			
			( colorLine == 0 ) ? this.colorLine = BLACK : this.colorLine = colorLine;
		}
		
		//
		// Detiene el sistema de control direccional con el ratón, lo que
		// implica dejar de visualizarlo
		//
		public override function Stop( result:int ):void
		{
			super.Stop( result );
			
			// Eliminamos la parte visual
			canvas.graphics.clear( );
			// @rubo:
			//canvas.arrow.visible = false;
		}
		
		//
		// Validamos la posición del balón teniendo en cuenta que esté  dentro del campo
		// y que no colisione con ninguna chapa ya existente (exceptuandola a ella)
		// TODO: Estamos utilizando la funcion de chapa en vez de la de balón. Los radios son diferentes!
		//
		public override function IsValid( ) : Boolean
		{
			// NOTE: Inidcamos que no tenga en cuenta el balón, ya que es el mismo el que estamos colocando
			return( Match.Ref.Game.GetField().ValidatePosCap( EndPos, false, this.Target ) );
		}
			
		//
		//
		//
		public override function MouseUp( e: MouseEvent ) : void
		{
			// Validamos si es una posición valida (tiene que estar dentro del campo), y si no es así ignoramos la operación
			if( IsValid() )
			{
				super.MouseUp( e );
	
				// Le decimos al interface de usuario que recoloque la pelota
				// TODO: Probando!!! La llamada no puede estar aquí!!
				Match.Ref.Game.Interface.OnPlaceBall();
			}
		}
		
		//
		// Reorientamos la pelota
		//
		public override function MouseMove( e: MouseEvent ) :void
		{
			super.MouseMove( e );
			
			// Obtenemos punto inicial y final de la linea de dirección
			var source:Point = new Point( xInit, yInit);
			var target:Point = EndPos;
			
			// Seleccionamos un color para la linea diferente en función de si la posición final
			// es válida o no
			
			var color:uint = colorLine;
			if( !IsValid() )
				color = 0xff0000;
			
			canvas.graphics.clear( );
			canvas.graphics.lineStyle( thickness, color, 0.7 );
			canvas.graphics.moveTo( source.x, source.y );
			canvas.graphics.lineTo( target.x, target.y );
			
			// Recolocamos la pelota
			//Match.Ref.Game.Ball.SetPos( EndPos );
		}
		
		//
		// Obtenemos el vector de dirección de control de pelota
		// NOTE: El vector estará normalizado a la longitud de maxLongLine 
		// 
		public override function get Direction(  ) : Point
		{
			var dir:Point = super.Direction;
			dir.normalize( maxLongLine );
			
			return( dir );
		}
		
		//
		// Obtenemos el punto final
		// 
		public function get EndPos(  ) : Point
		{
			// Obtenemos la dirección y la normalizamos a la distancia correcta 
			var dir:Point = Direction;
			dir.normalize( Cap.Radius + BallEntity.Radius + AppParams.DistToPutBallHandling );
			var newPos:Point = Target.GetPos().add( dir );
			
			return( newPos );
		}
		
		
		
	}
}
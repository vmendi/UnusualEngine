package Caps
{
	import Framework.Graphics;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	//
	// Se encarga del controlador para posicionar una chapa (el portero)
	//
	public class PosController extends Controller
	{
		private var canvas        : Sprite;
		private var maxLongLine   : uint;
		private var colorLine	  : uint;
		private var thickness	  : uint;
		
		private const BLACK    	  : uint = 0x000000;
		
		
		public function PosController( canvas:Sprite, maxLongLine: uint, colorLine: uint = 0, thickness: uint = 1 )		
		{
			this.maxLongLine = maxLongLine;
			this.canvas 	 = canvas;
			this.thickness   = thickness;
			
			( colorLine == 0 ) ? this.colorLine = BLACK : this.colorLine = colorLine;
		}
		
		//
		// Arranca el sistema de control direccional con el ratón
		// .... y hace visible el ghost
		public override function Start( _cap: Cap ):void
		{
			super.Start( _cap );
			
			// Activamos la parte visual
			if( Target != null && Target.Ghost != null )
			{
				// Recolocamos el Ghost y lo hacemos visible
				Target.Ghost.SetPos( EndPos );
				Target.Ghost.Visual.visible = true;
			}
		}
		
		//
		// Validamos la posición de la chapa teniendo en cuenta que:
		//		- esté  dentro del campo
		//		- esté dentro del area del area de la porteria (esto lo hacemos pq es para el portero)
		//		- que no colisione con ninguna chapa ya existente (exceptuandola a ella)
		//		- que no colisiones con el balón
		//
		public override function IsValid( ) : Boolean
		{
			return( Match.Ref.Game.GetField().ValidatePosCap( EndPos, true, this.Target ) &&
				Match.Ref.Game.GetField().IsCircleInsideArea( EndPos, 0, this.Target.OwnerTeam.Side)
			);
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
			if( Target != null && Target.Ghost != null )
				Target.Ghost.Visual.visible = false;
		}
		
		//
		//
		//
		public override function MouseUp( e: MouseEvent ) : void
		{
			super.MouseUp( e );
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
			if( !this.IsValid () )
				Framework.Graphics.ChangeColorMultiplier( Target.Ghost.Visual, 1.0, 0.4, 0.4 );
			else
				Framework.Graphics.ChangeColorMultiplier( Target.Ghost.Visual, 1.0, 1.0, 1.0 );
			
			// Recolocamos el Ghost
			Target.Ghost.SetPos( EndPos ); 
		}
		
		/*
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
		*/
		
		//
		// Obtenemos el punto final
		// 
		public function get EndPos(  ) : Point
		{
			// Obtenemos la dirección y la normalizamos a la distancia correcta 
			var dir:Point = Direction;
			var newPos:Point = Target.GetPos().add( dir );
			
			return( newPos );
		}
		
		
		
	}
}
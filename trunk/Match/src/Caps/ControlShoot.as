package Caps
{
	import Framework.*;
	
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;

	
	public class ControlShoot extends Controller
	{		
		protected var canvas        : Sprite;
		protected var angle	      : Number; 
		protected var maxLongLine   : uint;
		protected var colorLine	  : uint;
		protected var thickness	  : uint;
		protected var potenciaTiro : TextField;
		
		
		static protected const BLACK    	  : uint = 0x000000;
		static protected const MIN_FORCE : Number = 0.1; // Fuerza mínima que debe tener un disparo.
		
		// Constructor para poder heredar
		public function ControlShoot(  )
		{
		}
		/*	
		public function ControlShoot( canvas:Sprite, maxLongLine: uint, colorLine: uint = 0, thickness: uint = 1 )		
		{
			this.maxLongLine = maxLongLine;
			this.canvas 	 = canvas;
			this.thickness   = thickness;
			
			( colorLine == 0 ) ? this.colorLine = BLACK : this.colorLine = colorLine;
		}
		*/
		
		//
		// Detiene el sistema de control direccional con el ratón, lo que
		// implica dejar de visualizarlo
		//
		public override function Start( _cap:Cap ):void
		{
			super.Start(_cap);
			
			// Hacemos visible el campo de texto de potencia
			potenciaTiro.text = "";
			potenciaTiro.visible = true;
		}
		
		
		public override function Stop( result:int ):void
		{
			super.Stop( result );
				
			// Eliminamos la parte visual
			canvas.graphics.clear( );
			// @rubo:
			//canvas.arrow.visible = false;
			
			// Hacemos visible el campo de texto de potencia
			potenciaTiro.visible = false;
		}
		
		//
		// Hemos soltado el botón del ratón = Efectuamos el disparo!
		//
		public override function MouseUp( e: MouseEvent ) : void
		{
			super.MouseUp( e );
						
			// Le decimos al interface de usuario que dispare
			// TODO: El disparo no se puede aplicar aquí!! Deberíamos generar un evento
			Match.Ref.Game.Interface.OnShoot();
		}
		
		//
		// Comprueba si tiene un valor válido
		// NOTE: La flecha tiene que salir de la chapa para ser válida!
		//
		public override function IsValid( ) : Boolean
		{
			// Obtenemos la dirección truncada a la máxima longitud
			var dir:Point = Direction;
			if( dir.length < Cap.Radius )
				return( false );
			
			return( true );
		}
			
		public override function MouseMove( e: MouseEvent ) :void
		{
			super.MouseMove( e );
			
			angle = Math.atan2(  - ( canvas.mouseY - yInit ), - ( canvas.mouseX - xInit ) );
			
			//trace( "Mouse move recieved in : " + canvas.mouseX.toString() + "," + canvas.mouseY.toString() );   

			/*
			// @rubo:
			canvas.arrow.x = xInit + Math.cos( angle ) * RADIO_ARROW;
			canvas.arrow.y = yInit + Math.sin( angle ) * RADIO_ARROW;
			canvas.arrow.rotation =  angle * 180 / Math.PI;
			canvas.arrow.visible = true;
			*/
			
			
			// Obtenemos la dirección truncada a la máxima longitud
			var dir:Point = Direction;
			var source:Point = new Point( xInit, yInit);
			var target:Point = source.add( dir );
			
			// Mientras que no sacas la flecha de la chapa no es un tiro válido
			canvas.graphics.clear( );
			var color:uint = this.colorLine;
			if( !this.IsValid() )
			{
				color = 0xff0000;
				
				// Campo de texto de la potencia
				potenciaTiro.text = ""
			}
			else
			{
				var maxCapImpulse:Number = AppParams.MinCapImpulse + (AppParams.MaxCapImpulse - AppParams.MinCapImpulse ) * ( _Target.Power / 100 );
				var impulse:Number = Force * maxCapImpulse;
				var dist:Number = Math.pow( impulse/1.5, 2 ) / 10;
				var target2:Point = dir.clone();
				target2.normalize(dist)
				var target3:Point = source.subtract( target2 );
				var gradientBoxMatrix:Matrix = new Matrix();
				gradientBoxMatrix.createGradientBox(760, 760, 0, source.x-(766/2), source.y-(760/2));
				//gradientBoxMatrix.rotate(0.5*Math.PI);
				canvas.graphics.lineStyle( Cap.Radius*2, 0xFFFFFF, 0.2 );
				canvas.graphics.lineGradientStyle(GradientType.RADIAL, [0xFFFFFF, 0xFFFFFF], [0.3, 0.0], [0, 100], gradientBoxMatrix);
				canvas.graphics.moveTo( source.x, source.y );
				canvas.graphics.lineTo( target3.x, target3.y );
				
				// Campo de texto de la potencia
				potenciaTiro.text = "PO: " + Math.round(Force*100);
				potenciaTiro.x = target.x;
				potenciaTiro.y = target.y - 30;
			}
			
			canvas.graphics.lineStyle( thickness, color, 0.7 );
			canvas.graphics.moveTo( source.x, source.y );
			canvas.graphics.lineTo( target.x, target.y );
			//e.updateAfterEvent( );
		}
		
		//
		// Obtenemos el vector de dirección del disparo
		// NOTE: El vector estará truncado a una longitud máxima de maxLongLine 
		// 
		public override function get Direction(  ) : Point
		{
			var dir:Point = super.Direction;
			var distance:Number = dir.length;
			
			var myScale : Number = maxLongLine / AppParams.MaxCapImpulse;
			var myMaxLongLine : Number = ( AppParams.MinCapImpulse + ( (AppParams.MaxCapImpulse - AppParams.MinCapImpulse ) * ( _Target.Power / 100 ) ) ) * myScale;
			
			if ( distance > myMaxLongLine )
			{
				dir.normalize( myMaxLongLine );
				distance = myMaxLongLine;
			}
			
			return( dir );
		}
		//
		// Obtiene la fuerza de disparo como un valor de ( 0 - 1.0)
		// 
		public function get Force(  ) : Number
		{
			var len:Number = Direction.length - Cap.Radius;
			
			if( len < MIN_FORCE)
				len = MIN_FORCE;

			return( len / (maxLongLine-Cap.Radius) );
		}

	}
}
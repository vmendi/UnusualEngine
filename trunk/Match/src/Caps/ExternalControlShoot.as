package Caps
{
	import Framework.*;
	
	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	

	public class ExternalControlShoot extends ControlShoot 
	{
		protected var LastTarget:Point = new Point( 0, 0 );
		
		public function ExternalControlShoot( canvas:Sprite, maxLongLine: uint, colorLine: uint = 0, thickness: uint = 1 )
		{
			// Campo de texto en el que indicaremos la potencia
			var myFormat:TextFormat = new TextFormat();
			myFormat.size = 14;
			myFormat.bold = true;
			myFormat.font = "HelveticaNeue LT 77 BdCn"; 
			var campoPotenciaTiro : TextField = new TextField(); 
			campoPotenciaTiro.selectable = false;
			campoPotenciaTiro.mouseEnabled = false;
			campoPotenciaTiro.embedFonts = true;
			campoPotenciaTiro.antiAliasType = flash.text.AntiAliasType.ADVANCED;
			campoPotenciaTiro.defaultTextFormat = myFormat;
			campoPotenciaTiro.textColor = 0xFFFFFF;
			campoPotenciaTiro.width = 800;
			
			//canvas.addChild(campoPotenciaTiro);
			
			this.maxLongLine = maxLongLine;
			this.canvas 	 = canvas;
			this.thickness   = thickness;
			this.potenciaTiro = campoPotenciaTiro;
			
			( colorLine == 0 ) ? this.colorLine = ControlShoot.BLACK : this.colorLine = colorLine;
			
			// Registramos una función de ActionScript para que puede ser invocada desde fuera (desde JavaScript)
			ExternalInterface.addCallback("OnMouseMoveFromJS", OnMouseMoveFromJS );
			ExternalInterface.addCallback("OnMouseUpFromJS", OnMouseUpFromJS );
		}
		
		//
		// Arranca el sistema de control direccional con el ratón
		//
		public override function Start( _cap: Cap ): void					
		{	
			// NOTE: Importante llamar primero para que se asigne xInit, yInit 
			super.Start( _cap );
			
			// Asignamos el LastTarget a la posición donde está el inicio para prevenirnos de pintar con la anterior posición
			this.LastTarget = new Point( xInit, yInit );
		}
		
		//
		// Nos registramos a los eventos de ratón del objeto indicado "stage" 
		// NOTE: Además nos registramos a los eventos externos de JavaScript
		//
		protected override function AddHandlers( object:DisplayObject ):void
		{
			super.AddHandlers( object );
			
			// llamamos a javascript para registrarnos a los eventos
			ExternalInterface.call("RegisterMouseEvents" );
		}
		
		protected override function RemoveHandlers( object:DisplayObject  ):void
		{
			super.RemoveHandlers( object );
			
			// llamamos a javascript para desregistrarnos a los eventos
			ExternalInterface.call("UnregisterMouseEvents" );
		}
		
		//
		// Para que puedan coexistir los dos sistemas.
		// El externo (JavaScript) y el interno (ActionScript)
		//
		public override function MouseMove( e: MouseEvent ) :void
		{
			super.MouseMove( e );
			
			// Cuardamos la ultima posicion del raton en coordenadas relativas al padre de la chapa (el campo)
			var relativeTo:DisplayObject = _Target.Visual.parent;
			this.LastTarget.x = relativeTo.mouseX;
			this.LastTarget.y = relativeTo.mouseY;
		}
		
		//
		// OnMouseMoveFromJS
		//
		public function OnMouseMoveFromJS( x:int, y:int ) : void
		{
			// La llamada al UnregisterMouseEvents de JS parece no es inmediata, puesto que hemos observado que se pinta 1 frame de más después del Stop
			if (!IsStarted)
				return;
			
			// Pasamos las coordenadas que vendrán relativas al origen del "html" a espacio relativo al padre de la chapa
			// Para ello primero calculamos la posición absoluta del padre dentro del stage y luego dentro del documento html
			var relativeTo:DisplayObject = _Target.Visual.parent;
			//var origin:Point = relativeTo.localToGlobal( new Point( relativeTo.x, relativeTo.y ) );
			var origin:Point = relativeTo.localToGlobal( new Point( 0, 0 ) );
			
			origin.x += relativeTo.stage.x;
			origin.y += relativeTo.stage.y;
			
			trace( "Mouse move from Java: " + x.toString() + "," + y.toString() + "origin: " + origin.toString() + " Cap: " + this.Target.GetPos().toString() + "Stage " + relativeTo.stage.x.toString()+","+relativeTo.stage.y.toString() );
			
			x = x - origin.x;
			y = y - origin.y;
						
			// Guardamos el último punto detectado
			// NOTE: Importante hacer esto antes de obtener la direction, ya que la Direction se calcula en base a este valor!
			LastTarget.x = x;
			LastTarget.y = y;
						
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
		// OnMouseUpFromJS
		//
		public function OnMouseUpFromJS( ) : void
		{
			// Transformamos el evento JavaScript en un evento normal del controlador (ActionAscript ) 
			super.MouseUp( null );
		}
		
		//
		// Obtenemos el vector de dirección del disparo
		// NOTE: El vector estará truncado a una longitud máxima de maxLongLine 
		// 
		public override function get Direction(  ) : Point
		{
			var dir:Point = new Point( (this.LastTarget.x - xInit), (this.LastTarget.y - yInit) );
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
		
	}
}
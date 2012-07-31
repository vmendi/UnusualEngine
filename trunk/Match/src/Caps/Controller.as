package Caps
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import org.osflash.signals.Signal;

	public class Controller extends EventDispatcher
	{
		public static const Success:int = 0;				// Finalizó terminando la operación (Habitualmente cuando se ha producido Mouse Up )
		public static const Canceled:int = 1;				// Finalizó por cancelación (Llamada externa al stop)
		
		protected var _Target:Cap = null; 
		protected var xInit:Number; 						// X origen donde han pulsado en coordenadas del stage
		protected var yInit:Number; 						// Y origen donde han pulsado en coordenadas del stage
		protected var _IsStarted:Boolean = false;
		
		// Eventos		
		public var OnStart:Signal = new Signal();					// Evento lanzado cuanto el controlador se arranca
		public var OnStop:Signal = new Signal( int );		// Evento lanzado cuanto el controlador se detiene por cualquier razón
		
		//
		// Arranca el sistema de control direccional con el ratón
		//
		public function Start( _cap: Cap ): void					
		{	
			this._Target = _cap;
			
			xInit = _Target.GetPos().x;
			yInit = _Target.GetPos().y;					
			
			// Nos registramos a los eventos de entrada de todo el flash
			AddHandlers( _Target.Visual.stage );
			
			_IsStarted = true;
			
			// lanzamos evento
			OnStart.dispatch( );
		}
		
		//
		// Detiene el sistema de control direccional con el ratón, lo que
		// implica dejar de visualizarlo
		//
		public function Stop( result:int ):void
		{
			// Nos desregistramos de los eventos de entrada 
			RemoveHandlers( _Target.Visual.stage );
			
			// Indicamos que estamos detenidos
			_IsStarted = false;
			
			// lanzamos evento
			OnStop.dispatch( result );
		}
		
		//
		// Nos registramos a los eventos de ratón del objeto indicado "stage" 
		//
		protected function AddHandlers( object:DisplayObject ):void
		{
			if( object != null )
			{
				object.stage.addEventListener( MouseEvent.MOUSE_DOWN, MouseDown );
				object.stage.addEventListener( MouseEvent.MOUSE_UP, MouseUp );	
				object.stage.addEventListener( MouseEvent.MOUSE_MOVE, MouseMove );
			}
			
		}
		protected function RemoveHandlers( object:DisplayObject  ):void
		{
			if( object != null )
			{
				object.stage.removeEventListener( MouseEvent.MOUSE_DOWN, MouseDown );
				object.stage.removeEventListener( MouseEvent.MOUSE_UP, MouseUp );	
				object.stage.removeEventListener( MouseEvent.MOUSE_MOVE, MouseMove );
			}
		}

		//
		// Verifica si el controlador tiene unos valores válidos
		//
		public function IsValid( ) : Boolean
		{
			return true;
		}
		
		//
		// Botón del ratón presionado
		//
		public function MouseDown( e: MouseEvent ) :void
		{			
		}
		
		//
		// El botón del ratón se ha levantado
		// 
		public function MouseUp( e: MouseEvent ) :void
		{
			Stop( Success );	// Paramos el sistema de control direccional
		}
		
		public function MouseMove( e: MouseEvent ) :void
		{
			e.updateAfterEvent( );
		}
		
		// Indica si está funcionando el sistema de control direccional
		public function get IsStarted( ) : Boolean
		{
			return _IsStarted;
		}
		// Indica si está funcionando el sistema de control direccional
		public function get Target( ) : Cap
		{
			return _Target;
		}
		
		//
		// Obtenemos el vector de dirección del disparo
		// NOTE: El vector estará truncado a una longitud máxima de maxLongLine 
		// 
		public function get Direction(  ) : Point
		{
			//trace( "Chapa (parent): " + _Target.Visual.parent.name + " XY Chapa: " +  _Target.Visual.x + ", " + _Target.Visual.y + "MouseXY " +  _Target.Visual.mouseX + ", " + _Target.Visual.mouseY );
			
			// 
			// MouseX, MouseY es relativo a espacio de transformación del DisplayObject sobre el cual lo pedimos
			// NOTE: Relativo a su espacio implica que tambien tiene en cuenta la ROTACIÓN, escala y posición
			// Con lo cual para hacerlo independiente cogemos el padre de la chapa
			//
			var relativeTo:DisplayObject = _Target.Visual.parent;
			var dir:Point = new Point( (relativeTo.mouseX - xInit), (relativeTo.mouseY - yInit) );
			
			//var dir:Point = new Point( (_Target.Visual.mouseX - xInit), (_Target.Visual.mouseY - yInit) );
			//var dir:Point = new Point( _Target.Visual.mouseX, _Target.Visual.mouseY );
			return( dir );
		}
		
	}		
}
package Framework
{
	//
	// Crea Callback a métodos con argumentos "ADICIONALES"  
	// Ejemplo:
	//
	// button.addEventListener( MouseEvent.MOUSE_UP, Callback.Create( OpenLink, 'http://www.pandorainteractive.com' ));
	//
	// public function OpenLink( event:MouseEvent, url:String ) : void
	// { ... }
	//
	// FUNCIONAMIENTO : La función 'Create" crea una nueva función que invoca al método concantenando los parámetros de invocación con los parámetros adicionales
	// pasados a la propia función de creación.
	// 
	// La llamada a Create con los mismos parámetros exactos devuelve siempre un objeto diferente, por ello:  
	// 		- Tener cuidado al eliminar el listener, ya que la siguiente llamada NO ES CORRECTA (ya que con 'Create' estamos creando una nueva 'Function')
	// 					button.removeEventListener( MouseEvent.MOUSE_UP, Callback.Create( OpenLink, 'http://www.pandorainteractive.com' ));
	//
	// La única forma correcta para eliminar el Listener es quedarse la dirección del objeto cuando se añade.
	//
	public class Callback
	{
		public static function Create( method:Function, ...args ) : Function
		{
			return function(...innerArgs) : void
			{
				method.apply( this, innerArgs.concat( args ) );
			}
			
		}
	}
}
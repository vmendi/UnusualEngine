package Framework
{
	//
	// Manager de elementos
	//
	public class Manager
	{
		protected var ItemList:Array = new Array();			// Lista de todos los elementos añadidos al manager
		
		//
		// Retorna la lista de items
		//
		public function get Items( ) : Array
		{
			return( ItemList );
		}
		
		//
		// Añade un elemento a la lista del manager 
		//
		public function Add( item:* ) : void
		{
			ItemList.push( item );
			
			// TODO: Verificar que un mismo item no se inserte dos veces!!!! 
		}
		
		//
		// Elimina un elemento 
		// NOTE: Al eliminarlo todos los elementos posteriores pasarán a un indice anterior
		// Retorno: Devuelve 'true' si lo elimina o 'false' si no lo encuentra
		//
		public function Remove( item:* ) : Boolean
		{
			var bRemoved:Boolean = false;
			
			// Buscamos el elemento
			var idx:int = ItemList.indexOf( item );
			// Destruimos el elemento [idx] --> Desde Idx, destruir 1 elemento 
			if( idx != (-1) )
			{
				var count:int = ItemList.length;
				
				var ret:* = ItemList.splice( idx, 1 );
				
				count = ItemList.length;
				
				
				bRemoved = true;
			}
			
			return bRemoved;
		}
	}
	
}
package Framework
{
	public class TagManager extends Manager
	{
		protected var TaggedEntities:Array = new Array();			// Lista de entidades etiquetadas
		
		//
		// Añade un elemento a la lista del manager y lo asocia con una etiqueta (identifier), de tal 
		// forma que posteriormente podamos manejarlo a través del mismo.
		// Si el identificador es nulo o está vacio se agregará el item sin etiqueta
		// El identificador debe ser único.
		//
		public function AddTagged( item:*, identifier:String = null ) : void
		{
			if( Find( identifier ) == null )
			{
				// Registramos la etiqueta asociada al identificador
				if( identifier != null && identifier != "" )
					TaggedEntities [ identifier ] = item;
				
				// Añadimos a la lista de entidades
				super.Add( item );
			}
			else
				trace( "Warning: TagManager.Add: Ya está registrado el elemento " + identifier );
		}
		
		//
		// Obtiene un elemento a partir de su identificador
		// NOTE: Si el elemento no existe devuelve NULL
		//
		public function Find( identifier:String ) : *
		{
			return( TaggedEntities [ identifier ] );
		}
		
	}

}
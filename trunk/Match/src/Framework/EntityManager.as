package Framework
{
	//
	// Manager de entidades. Tiene las siguientes características
	//
	// 	- Centralización --> Contenedor de todas las entidades del mundo; lo que permite poder realizar una acción a "todas" las entidades
	//	- Abstracto --> Soporta cualquier tipo de entidad  
	//  - Globalización --> Recuperar entidades desde cualquier punto de la aplicación
	//  - Identificación --> Permite identificar las entidadas por etiquetas, para poder recuperarlas
	//	  en cualquier momento sin la necesidad de guardar punteros 
	//
	public class EntityManager extends TagManager
	{
		static protected var Instance:EntityManager = new EntityManager();		// Instancia única del Single-On
		
		static public function get Ref( ) : EntityManager
		{
			return( Instance );
		}
		
		//
		// Se ejecuta a frecuencia constante, una vez cada tick lógico
		// - Ejecuta todas las entidades que controle el gestor
		//
		public function Run( elapsed:Number ) : void
		{
			// Ejecutamos todas las entidades
			for each ( var item:Entity in Items )
			{
				if( item != null )
				{
					item.Run( elapsed );
				}
			}
		
		}
		
		//
		// Se ejecuta a velocidad de pintado
		//
		public function Draw( elapsed:Number ) : void
		{
			// Ejecutamos todas las entidades
			for each ( var item:Entity in Items )
			{
				if( item != null )
				{
					item.Draw( elapsed );
				}
			}
			
		}
		
		//
		// Destruye las entidades 
		//
		static public function Shutdown(  ) : void
		{
			// Es un objeto estático, debe existir siempre.
			// Para que se destruya el contenido del objeto lo recreamos!
			Instance = new EntityManager();		
		}
		
		
	}
	
}
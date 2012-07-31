package Framework
{
	import mx.collections.IList;
	
	public class Collections
	{
		// Convierte a un array una colección de otro tipo. 
		// Si no soporta la colección o es <null> devuelve <null>.
		// Solo soporta: 
		// 		- mx.collections.ArrayCollection
		// 		- Array
		// TODO: Entender otros tipos de colecciones
		//
		static public function ToArray( anyCollection:* ) : Array 
		{
			if( anyCollection is mx.collections.IList )
				return anyCollection.toArray();
			else if( anyCollection is Array )
				return anyCollection;
			
			
			return null;
		}
		
	}
}
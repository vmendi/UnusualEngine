package Framework
{
	//
	// Clase base de la cual debe derivar cualquier entidad
	//
	public class Entity
	{
		//
		// Se ejecuta a frecuencia constante, una vez cada tick lógico
		//
		public function Run( elapsed:Number ) : void
		{
		}

		//
		// Se ejecuta a velocidad de pintado
		//
		public function Draw( elapsed:Number ) : void
		{
		}

	
	}
	
}
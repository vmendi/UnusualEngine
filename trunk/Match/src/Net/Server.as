package Net
{
	//
	// Implementa la conexión con el servidor de juego
	//
	public class Server
	{
		public var Connection:Object = null;					// Conexión con el servidor
								
		private var _IdLocalUser:int = (-1);					// Identificador del usuario local
		
		static private var Instance:Server = null;				// Instancia única de la clase
		
		public function Server(  )
		{
			Instance = this;
		}
		
		//
		// Construye nuestro objeto de comunicación con el servidor a través de una conexión existente
		//
		public function InitConnection(netConnection: Object) : void
		{
			Connection = netConnection;
			Connection.AddClient(this);
		}
		
		static public function get Ref( ) : Server
		{
			return( Instance );
		}
		
		//
		// Termina la conexión con el servidor
		//
		public function Close() : void
		{
			trace( "Server.Close: Cerrando la conexión con el servidor" );
			
			Connection.RemoveClient(this);
			Connection = null;
		}
		
		
		//
		// Función para probar entrada desde el servidor y conversión de tipos de VS a ActionScript
		//
		public function Test(  ) : void
		{
			var k:int = 17;	
		}
		
		// Acceso al identificador de usuario local
		// TODO: No deberíamos dar acceso de escritura. Debería ser parte de la inicialización
		//
		public function get IdLocalUser( ) : int
		{
			return( _IdLocalUser);
		}
		public function set IdLocalUser( userId:int ) : void
		{
			_IdLocalUser = userId;
		}
	}
}
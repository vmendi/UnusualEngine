package
{
	import GameModel.MainServiceSoccerV1;
	
	import GameView.ErrorDialog;
	
	import flash.events.AsyncErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import mx.controls.Alert;
	import mx.rpc.Responder;
	import mx.rpc.events.FaultEvent;
	
	import org.osflash.signals.Signal;

	public final class ErrorMessages
	{
		// Se lanza para indicar que se ha producido cualquier error, y que cualquiera que tenga por ejemplo un timer, debe desengancharse
		static public var OnCleaningShutdownSignal : Signal = new Signal();
		
		static public function FacebookConnectionError() : void
		{
			OnCleaningShutdownSignal.dispatch();
			ErrorDialog.Show("Error de conexión con facebook. Por favor recargue la página.", "Connection", "center");
		}
		
		static public function DuplicatedConnectionCloseHandler() : void
		{
			OnCleaningShutdownSignal.dispatch();
			ErrorDialog.Show("Ha iniciado una sesión del juego en otro navegador.\n\n No se puede jugar más de una sesión simultánea.", "Sesión duplicada", "center");
		}
		
		static public function ServerShutdown() : void
		{
			OnCleaningShutdownSignal.dispatch();
			ErrorDialog.Show("Breve parada de mantenimiento. Por favor recargue el juego.", "Reinicio del servidor", "center");
		}
				
		static public function ClosedConnection() : void
		{
			OnCleaningShutdownSignal.dispatch();
			ErrorDialog.Show("Se ha producido una desconexión con el servidor", "Desconexión", "center");			
		}
		
		static public function ServerClosedConnectionUnknownReason() : void
		{
			OnCleaningShutdownSignal.dispatch();		
			Alert.show("Se ha producido una desconexión con el servidor con motivo desconocido", 
					   "(BETA) Por favor notifique este error a vmendi@unusualwonder.com", Alert.OK);
		}		
		
		//
		// Falla una de las llamadas al MainService. 
		// 
		// Comentario antiguo:
		// Aquí quizá deberíamos recargar/reintentar. Vamos de momento a dejar de mandar la señal de CleaningShutdown
		// -----------------------------------------------------------------------------------------------------------
		//
		// Nuevo comentario:
		// Vamos a ignorar que hubo un Fault para que se vuelva a reintentar. Tenemos que restaurar los parametros de
		// la conexion, sin embargo
		//
		static public function Fault(info:Object):void
		{
			SoccerClientV1.GetFacebookFacade().SetWeborbSessionKey();
		}
		
		// Cuando quieres hacer una llamada al servicio y no escuchar a su Success, si falla hay que llamar a Fault anyway!
		static public var FaultResponder : Responder = new mx.rpc.Responder(DummyFunc, Fault);
		static public function DummyFunc(e:Event) : void {}
				

		static public function RealtimeLoginFailed() : void
		{
			OnCleaningShutdownSignal.dispatch();			
			
			Alert.show("No se pudo hacer login en el servidor de partidos.", 
					   "(BETA) Por favor notifique este error al desarrollador", Alert.OK);
			LogToServer("RealtimeLoginFailed");
		}
		
		static public function RealtimeConnectionFailed() : void
		{
			OnCleaningShutdownSignal.dispatch();
			ErrorDialog.Show("No se pudo conectar al servidor de partidos.\n\n" +
							 "Posiblemente esté detrás de un Firewall demasiado restrictivo.", "Error de conexion", "center");
			LogToServer("RealtimeConnectionFailed");
		}
		
		static public function UncaughtErrorHandler(e:Event):void
		{			
			OnCleaningShutdownSignal.dispatch();
			
			var innerError : Object = (e as Object).error;
			var message : String = "";
			var result : int = 0;
			
			if (innerError is Error)
			{
				var stackTrace : String = (innerError as Error).getStackTrace();
				if (stackTrace != null)
					message = stackTrace;
				else				
					message = Error(innerError).message;
			}
			else
			{
				if (innerError is ErrorEvent)
					message = ErrorEvent(innerError).text;
				else
					message = innerError.toString();
			}
						
			Alert.show("UncaughtError: " + message, "(BETA) Por favor notifique este error al desarrollador");
			LogToServer("UncaughtError: " + message);
		}
		
		static public function AsyncError(e:AsyncErrorEvent) : void
		{
			OnCleaningShutdownSignal.dispatch();
			Alert.show("AsyncError: " + e.error.message, "(BETA) Por favor notifique este error al desarrollador");
			LogToServer("AsyncError: " + e.error.message);
		}
		
		static public function IOError(e:IOErrorEvent) : void
		{
			OnCleaningShutdownSignal.dispatch();
			Alert.show("IOError: " + e.text, "(BETA) Por favor notifique este error al desarrollador");
			LogToServer("IOError: " + e.text);
		}
		
		static public function LogToServer(message : String) : void
		{
			var facebookID : String = "Unknown";
			
			if (SoccerClientV1.GetFacebookFacade() != null && SoccerClientV1.GetFacebookFacade().FacebookID != null)
				facebookID = SoccerClientV1.GetFacebookFacade().FacebookID;
			
			(new MainServiceSoccerV1()).OnError(facebookID + " - " + message);
		}			
	}
}
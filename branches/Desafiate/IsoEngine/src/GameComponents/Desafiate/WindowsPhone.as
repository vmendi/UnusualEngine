package GameComponents.Desafiate
{
	import GameComponents.GameComponent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import utils.Delegate;
	import utils.MovieClipListener;

	public class WindowsPhone extends GameComponent
	{
		override public function OnStart():void
		{
			TheVisualObject.gotoAndStop("empty");

			mInterface = TheGameModel.FindGameComponentByShortName("DesafiateInterface") as DesafiateInterface;
			mStatus = TheGameModel.FindGameComponentByShortName("GameStatus") as GameStatus;

			MovieClipListener.AddFrameScript(TheVisualObject, "showEnd", OnShowEnd);
			MovieClipListener.AddFrameScript(TheVisualObject, "hideEnd", OnHideEnd);

			InitMessages();
			InitStatus();
		}

		private function InitStatus() : void
		{
			if (mStatus.Bag.child("WindowsPhone").length() == 0)
			{
				mStatus.Bag.WindowsPhone.EnabledMessages = "";
			}
			else
			{
				for each(var theChild : XML in mStatus.Bag.WindowsPhone.EnabledMessages.children())
				{
					mMessages[theChild.name()].IsEnabled = true;
				}
			}
		}

		public function Show(callback : Function):void
		{
			mCallBack = callback;
			mInterface.ShowAll(false);
			TheVisualObject.gotoAndPlay("show");
			TheGameModel.PauseGame(true);
		}

		private function OnShowEnd():void
		{
			TheVisualObject.stop();
			TheVisualObject.btClose.addEventListener(MouseEvent.CLICK, OnCloseClick);

			FillMessages();
		}

		private function OnCloseClick(e:Event):void
		{
			TheVisualObject.gotoAndPlay("hide");
		}

		private function OnHideEnd():void
		{
			TheVisualObject.gotoAndStop("empty");
			TheGameModel.PauseGame(false);
			mInterface.ShowAll(true);
			if (mCallBack != null)
				mCallBack();
		}

		private function FillMessages():void
		{
			TheVisualObject.mcContent.mcMessage.visible = false;
			TheVisualObject.mcContent.mcEntrada0.visible = false;
			TheVisualObject.mcContent.mcEntrada1.visible = false;
			TheVisualObject.mcContent.mcEntrada2.visible = false;
			TheVisualObject.mcContent.mcEntrada3.visible = false;

			var i:int = 0;
			for each(var msg : Object in mMessages)
			{
				if (msg.IsEnabled)
				{
					if (i >= 4)
						throw "WTF";

					TheVisualObject.mcContent["mcEntrada"+i].ctNombre.text = msg.From;
					TheVisualObject.mcContent["mcEntrada"+i].ctClase.text = msg.Subject;
					TheVisualObject.mcContent["mcEntrada"+i].visible = true;

					TheVisualObject.mcContent["mcEntrada"+i].btRead.addEventListener(MouseEvent.CLICK, Delegate.create(ReadMessage, msg));
					i++;
				}
			}

			// Boton volver dentro mensaje
			TheVisualObject.mcContent.mcMessage.btBack.addEventListener(MouseEvent.CLICK, OnBackClick);
		}

		private function ReadMessage(e: MouseEvent, msg:Object):void
		{
			TheVisualObject.mcContent.mcMessage.visible = false;
			TheVisualObject.mcContent.mcEntrada0.visible = false;
			TheVisualObject.mcContent.mcEntrada1.visible = false;
			TheVisualObject.mcContent.mcEntrada2.visible = false;
			TheVisualObject.mcContent.mcEntrada3.visible = false;

			TheVisualObject.mcContent.mcMessage.ctFrom.text = msg.From;
			TheVisualObject.mcContent.mcMessage.ctSubject.text = msg.Subject;
			TheVisualObject.mcContent.mcMessage.ctMessage.text = msg.Message;
			TheVisualObject.mcContent.mcMessage.visible = true;
		}

		private function OnBackClick(e:MouseEvent):void
		{
			FillMessages();
		}

		public function EnableMessage(checkPointID : String, messageNumber : int, withBlink:Boolean) : void
		{
			if (mStatus.IsPastCheckpoint(checkPointID))
				throw "u sure?";

			var msgName : String = checkPointID+messageNumber.toString();
			mMessages[msgName].IsEnabled = true;
			mStatus.Bag.WindowsPhone.EnabledMessages[msgName] = "";

			if (withBlink)
				mInterface.BlinkPhone();
		}

		public function EnableAllMessagesFor(checkPointID:String, withBlink : Boolean):void
		{
			if (mStatus.IsPastCheckpoint(checkPointID))
				throw "u sure?";

			for (var msgName : String in mMessages)
			{
				var msg : Object = mMessages[msgName];
				if (msg.Checkpoint == checkPointID && msg.IsEnabled == false)
				{
					msg.IsEnabled = true;
					mStatus.Bag.WindowsPhone.EnabledMessages[msgName] = "";
				}
			}

			if (withBlink)
				mInterface.BlinkPhone();
		}

		private function InitMessages():void
		{
			mMessages = new Object();

			CreateMessage(Checkpoints.INTRO, 0, "Jefe IT", "Atento a tu Windows Phone", false, false,
						  "Hola. Tendrás que estar atento a tu Windows Phone. Aquí recibirás los avisos de problemas técnicos de la compañía. Resuélvelos lo más rápido que puedas.");

			CreateMessage(Checkpoints.INTRO, 1, "Jefe IT", "Nuevo Windows Phone 7", false, false,
						  "Como ves este es uno de los nuevos dispositivos Windows Phone 7. El diseño limpio del interface, la interactividad y todas las nuevas ideas suponen una verdadera revolución.");

			CreateMessage(Checkpoints.TM01_START, 0, "¡Urgente!", "Problemas en varios equipos", true, false,
						  "Volvemos a tener problemas en varios de los puestos. Necesitamos que vengas a solucionarlos lo antes posible. Habla con el Director Comercial, te está esperando. Gracias.");

			CreateMessage(Checkpoints.INTER01, 100, "RRHH", "Mobiliario renovado", false, false,
						  "Hola a todos. Os informamos de que los sofás de la recepción, planta de trabajo y sala de reuniones han sido renovados. Probadlos, son comodísimos.");
			CreateMessage(Checkpoints.INTER01, 101, "Adriana", "Password olvidado", false, false,
						  "Soy incapaz de recordar el password de mi equipo y necesito acceder urgentemente. ¿Puedes ayudarme? Te espero en la sala de trabajo.");
			CreateMessage(Checkpoints.INTER01, 102, "Rodri", "Problemas con PowerShell", false, false,
						  "Estoy aprendiendo PowerShell y me encanta. Sin embargo tengo algunas dudas, si tienes tiempo podrías echarme una mano. Estoy en la cafetería.");
						  
			CreateMessage(Checkpoints.TM02_START, 0, "¡Urgente!", "Problemas con los servidores.", true, false,
						  "Estamos sufriendo un pico en la demanda de nuestros servicios de datos y los servidores están teniendo problemas para dar servicio. Necesitamos que te ocupes de ello inmediatamente. El futuro de la compañía depende de ti.");

			CreateMessage(Checkpoints.INTER02, 100, "Gerard", "¡Socorro!", false, false,
						  "La maldita máquina de cafetería se ha vuelto a estropear. Necesito que alguien me ayude o...");
			CreateMessage(Checkpoints.INTER02, 101, "CEO", "Necesito su ayuda", false, false,
						  "Tengo problemas accediendo a mi ordenador y necesito entrar urgentemente. Espero que no me haga esperar.");
			CreateMessage(Checkpoints.INTER02, 102, "Recepción", "Ayúdame :-)", false, false,
						  "Hola simpático. Necesito que me eches una mano con mi ordenador ¿puedes venir?. Un beso.");
			
			CreateMessage(Checkpoints.TM03_START, 0, "Juan D.C.", "Acceso a información", true, false,
						  "Estamos terminando la propuesta para Argae Inc, pero no sómos capaces de encontrar unos datos imprescindibles para la elaboración de la propuesta. El tiempo se nos echa encima, necesitamos tu ayuda urgente. Gracias.");
						  
		}

		public function CreateMessage(checkpointID:String, innerNum:int, from:String, subject:String,
									  disposeOnNextCheckpoint:Boolean, isEnabled:Boolean, msgTxt:String) : void
		{
			mMessages[checkpointID+innerNum.toString()] = {Checkpoint:checkpointID,
														   From: from,
														   Subject: subject,
														   DisposeOnNextCheckpoint:disposeOnNextCheckpoint,
														   IsEnabled:isEnabled,
														   Read:false,
														   Message : msgTxt};
		}

		public function OnCheckpointChanged(currentCheckpoint : String) : void
		{
			// Desconectamos todos los antiguos
			for (var msgName : String in mMessages)
			{
				var msg : Object = mMessages[msgName];
			
				/*
				 * HACK : No hemos tenido en cuenta el "DisposeOnNextCheckpoint" y tenemos que solucionar el bug de MainSalaIT
				 *        que permite jugar infinitas veces al GeekQuiz por no cambiar de checkpoint
				 */
				 if (msg.Checkpoint == "INTRO")
				 {
				 	continue;
				 }
				 /* HACK END */
				 
				 if (msg.IsEnabled && mStatus.IsPastCheckpoint(msg.Checkpoint))
				 {
					msg.IsEnabled = false;
					delete mStatus.Bag.WindowsPhone.EnabledMessages[msgName];
				 }
			 }
		}
		
		public function DisableMessage(checkPointID:String, innerNum:int):void
		{
			var msgName : String = checkPointID + innerNum.toString();
			var msg : Object = mMessages[msgName];
			
			msg.IsEnabled = false;
			delete mStatus.Bag.WindowsPhone.EnabledMessages[msgName];
		}

		private var mInterface : DesafiateInterface;
		private var mCallBack : Function;
		private var mStatus : GameStatus;
		private var mMessages : Object;
	}
}
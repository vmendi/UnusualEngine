package GameComponents.Dove
{
	import GameComponents.GameComponent;
	import GameComponents.ScreenSystem.FadeTransition;
	
	import flash.display.InteractiveObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.navigateToURL;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	import mx.core.Application;
	
	import utils.Delegate;

	public class DoveFormulario extends GameComponent
	{
		override public function OnStart():void
		{
			var names : Array = [ "ctNombre", "ctApellidos", "ctEmail", "ctDia", "ctMes", "ctAno", "ctTelefono", "ctCiudad", "cbProv", "checkboxCondiciones" ];
			
			AddProvinciasToComboBox(TheVisualObject.cbProv);
			ConfigureTabs(names, null);
			ConfigureSexo();
			ConfigureFecha();
			ConfigureEnviar();
			
			var textFormat : TextFormat = new TextFormat("Arial", 12, 0x000000);
			TheVisualObject.cbProv.textField.setStyle("textFormat", textFormat);
			
			TheVisualObject.stage.focus = TheVisualObject["ctNombre"];
			
			TheVisualObject.mcButCondiciones.addEventListener(MouseEvent.CLICK, OnCondicionesClick);
			TheVisualObject.mcButPrivacidad.addEventListener(MouseEvent.CLICK, OnPrivacidadClick);
			
			TheVisualObject.mcContact.buttonMode = true;
			TheVisualObject.mcContact.useHandCursor = true;
			TheVisualObject.mcContact.addEventListener(MouseEvent.CLICK, OnContactClick);
			
			SendTag();
		}
		
		private function OnContactClick(e:Event):void
		{
			navigateToURL(new URLRequest("mailto:hablamos@embellecetupiel.com"), "_self");
		}
		
		private function SendTag() : void
		{
			var ebRand : Number = Math.random();
			ebRand = ebRand * 1000000;
						
			var activityParams : String = escape('ActivityID=55344&f=1');			
			var loader : Loader = new Loader();
			var theRequest : URLRequest = new URLRequest('HTTP://bs.serving-sys.com/BurstingPipe/activity.swf?ebAS=bs.serving-sys.com&activityParams=' + activityParams + '&rnd='+ ebRand);
			theRequest.method = URLRequestMethod.POST;
			loader.load(theRequest);
		}
		
		private function SendTagFormularioEnviado() : void
		{
			var ebRand : Number = Math.random();
			ebRand = ebRand * 1000000;
						
			var activityParams : String = escape('ActivityID=55346&f=1');			
			var loader : Loader = new Loader();
			var theRequest : URLRequest = new URLRequest('HTTP://bs.serving-sys.com/BurstingPipe/activity.swf?ebAS=bs.serving-sys.com&activityParams=' + activityParams + '&rnd='+ ebRand);
			theRequest.method = URLRequestMethod.POST;
			loader.load(theRequest);
		}
		
		private function OnCondicionesClick(e:Event):void
		{
			var doveMessage : DoveMessage = TheGameModel.CreateSceneObjectFromMovieClip("mcBases", "DoveMessage") as DoveMessage;
			doveMessage.FadeOutOnClose = false;			
		}
		
		private function OnPrivacidadClick(e:Event):void
		{
			var doveMessage : DoveMessage = TheGameModel.CreateSceneObjectFromMovieClip("mcPrivacidad", "DoveMessage") as DoveMessage;
			doveMessage.FadeOutOnClose = false;
		}
		
		private function ConfigureEnviar() : void
		{		
			TheVisualObject["mcButEnviar"].addEventListener(MouseEvent.CLICK, OnEnviarClick);
		}
		
		private function ConfigureFecha() : void
		{
		}
	
		private function ConfigureSexo() : void
		{
			TheVisualObject["mcHombre"].useHandCursor = true;
			TheVisualObject["mcHombre"].buttonMode = true;
			TheVisualObject["mcMujer"].useHandCursor = true;
			TheVisualObject["mcMujer"].buttonMode = true;
			TheVisualObject["mcHombre"].gotoAndStop("off");
			TheVisualObject["mcMujer"].gotoAndStop("on");
			TheVisualObject["mcMujer"].addEventListener(MouseEvent.CLICK, OnSexoClick);
			TheVisualObject["mcHombre"].addEventListener(MouseEvent.CLICK, OnSexoClick);
		}
		
		private function OnSexoClick(event:Event):void
		{
			if (event.target.name == "mcMujer")
			{
				TheVisualObject["mcMujer"].gotoAndStop("on");
				TheVisualObject["mcHombre"].gotoAndStop("off");
			}
			else
			{
				TheVisualObject["mcMujer"].gotoAndStop("off");
				TheVisualObject["mcHombre"].gotoAndStop("on");
			}
		}
		
		private function OnEnviarClick(e:Event):void
		{
			var sexo : String = "M";
			
			if (TheVisualObject["mcHombre"].currentLabel == "on")
				sexo = "H";
			
			var nombre : String = TheVisualObject["ctNombre"].text;
			var apell : String = TheVisualObject["ctApellidos"].text;
			var email : String = TheVisualObject["ctEmail"].text;
			var nacimDiaInt : int = parseInt(TheVisualObject["ctDia"].text);
			var nacimMesInt : int = parseInt(TheVisualObject["ctMes"].text);
			var nacimAnoInt : int = parseInt(TheVisualObject["ctAno"].text);
			var nacim : String = TheVisualObject["ctDia"].text + "/" + TheVisualObject["ctMes"].text + "/" + TheVisualObject["ctAno"].text; 
			var telf : String = TheVisualObject["ctTelefono"].text;
			var ciudad : String = TheVisualObject["ctCiudad"].text;
			var prov : String = TheVisualObject["cbProv"].selectedItem.label;
			
			var message : String = "";

			if (nombre == "")
				message += "El campo de Nombre es obligatorio\n";
			
			if (apell == "")
				message += "El campo de Apellidos es obligatorio\n";
			
			/* [A-Z0-9._%+-] */
			var emailRegExp:RegExp = /^[a-z][\w.-]+@\w[\w.-]+\.[\w.-]*[a-z][a-z]$/i;/*/^([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+)\.([a-zA-Z]{2,4})$/i;*/
			if (email == "" || (!emailRegExp.test(email)))
				message += "Campo de eMail invalido\n";
			
			if (nacimDiaInt <= 0 || nacimDiaInt > 31)
				message += "El día debe estar entre 1 y 31\n";
			
			if (nacimMesInt <= 0 || nacimMesInt > 12)
				message += "El mes debe estar entre 1 y 12\n";
			
			if (nacimAnoInt >= 1 && nacimAnoInt <= 99)
			{
				nacimAnoInt += 1900;
				nacim = TheVisualObject["ctDia"].text + "/" + TheVisualObject["ctMes"].text + "/" + nacimAnoInt.toString();
			}
			else		
			if (nacimAnoInt <= 1900 || nacimAnoInt >= 2011)
			{
				message += "Año de nacimiento debe estar entre 1901 y 2011\n";
			}
			
			if (ciudad == "")
				message += "El campo de Localidad es obligatorio\n";
				
			if (prov == "")
				message += "El campo de Provincia es obligatorio\n";
			
			var telfRegExp : RegExp = /^\d{9}$/;
			if (telf != "" && !telfRegExp.test(telf))
				message += "El teléfono sólo puede contener 9 dígitos\n";
			
			if (!TheVisualObject.checkboxCondiciones.selected)
				message += "Debe aceptar las condiciones de la promoción\n";

			trace(message);
			
			if (message == "")
			{	
				SendTagFormularioEnviado();
				TheGameModel.CreateSceneObjectFromMovieClip("mcInfinitePreloader", "InfinitePreloader");
				(Application.application as Object).SaveRegister(nombre, apell, email, nacim, sexo, telf, ciudad, prov, OnSendSuccess, OnSendError);
			}
			else
			{
				TheVisualObject.ErrorArea.text = message;
			}
		}
				
		private function OnSendError() : void
		{
			TheGameModel.DeleteSceneObject(TheGameModel.FindGameComponentByShortName("InfinitePreloader").TheSceneObject);
			var doveMessage : DoveMessage = TheGameModel.CreateSceneObjectFromMovieClip("mcMessage", "DoveMessage") as DoveMessage;
			doveMessage.TheVisualObject["mcText"].text = "Error de conexión con el servidor.";
			(doveMessage.TheVisualObject["mcText"] as TextField).textColor = 0xFF0000;
		}
		
		private function OnSendSuccess() : void
		{
			TheGameModel.DeleteSceneObject(TheGameModel.FindGameComponentByShortName("InfinitePreloader").TheSceneObject);
			var doveMessage : DoveMessage = TheGameModel.CreateSceneObjectFromMovieClip("mcMessage", "DoveMessage") as DoveMessage;
			doveMessage.TheVisualObject["mcText"].text = "Registro realizado con éxito.";
			doveMessage.TheVisualObject["mcButAceptar"].addEventListener(MouseEvent.CLICK, GotoMain);
		}
		
		private function GotoMain(event:Event) : void
		{
			TheGameModel.FindGameComponentByShortName("ScreenNavigator").GotoScreen("mcProducts", new FadeTransition(500).Transition);
			(TheGameModel.FindGameComponentByShortName("DoveMenuProducts") as DoveMenuProducts).ShowSubScreen(TheGameModel.GlobalGameState.LastTestResult);
		}
		
		private function ConfigureTabs(names : Array, enterFunction : Function) : void
		{
			for (var c:int = 0; c < names.length; c++)	
			{
				var name : String = names[c];
			
				if (TheVisualObject[name] != null)
				{
					TheVisualObject[name].addEventListener(KeyboardEvent.KEY_DOWN, Delegate.create(OnKeyDown, names, enterFunction));
				}
			}
			
			for (c = 0; c < TheVisualObject.numChildren; c++)
			{
				var interObj : InteractiveObject = TheVisualObject.getChildAt(c) as InteractiveObject;
				if (interObj != null)
					interObj.tabEnabled = false; 
			}
		}

		private function OnKeyDown(event:KeyboardEvent, names:Array, enterFunction:Function):void
		{
			if (event.keyCode != Keyboard.TAB && event.keyCode != Keyboard.ENTER)
				return;

			var curr : Object = event.target;

			for (var c:int = 0; c < names.length; c++)
			{
				if (TheVisualObject[names[c]] == curr)
					break;
			}
			
			if (c != names.length && event.keyCode == Keyboard.TAB)
			{
				if (event.shiftKey)
				{
					if (c != 0)
						TheVisualObject.stage.focus = TheVisualObject[names[c-1]];
					else
						TheVisualObject.stage.focus = TheVisualObject[names[names.length-1]];
				}
				else
				{
					if (c != names.length-1)
						TheVisualObject.stage.focus = TheVisualObject[names[c+1]];
					else
						TheVisualObject.stage.focus = TheVisualObject[names[0]];
				}
			}
			
			if (c != names.length && event.keyCode == Keyboard.ENTER)
			{
				if (enterFunction != null)
					enterFunction(names[c]);
			}
		}
		
		static public function AddProvinciasToComboBox(cb : Object):void
		{
			cb.addItem({label:"", data:""});
			cb.addItem({label:"Álava", data:""});
			cb.addItem({label:"Albacete", data:""});
			cb.addItem({label:"Alicante", data:""});
			cb.addItem({label:"Almería", data:""});
			cb.addItem({label:"Asturias", data:""});
			cb.addItem({label:"Ávila", data:""});
			cb.addItem({label:"Badajoz", data:""});
			cb.addItem({label:"Barcelona", data:""});
			cb.addItem({label:"Burgos", data:""});
			cb.addItem({label:"Cáceres", data:""});
			cb.addItem({label:"Cádiz", data:""});
			cb.addItem({label:"Cantabria", data:""});
			cb.addItem({label:"Castellón", data:""});
			cb.addItem({label:"Ciudad Real", data:""});
			cb.addItem({label:"Córdoba", data:""});
			cb.addItem({label:"La Coruña", data:""});
			cb.addItem({label:"Cuenca", data:""});
			cb.addItem({label:"Gerona", data:""});
			cb.addItem({label:"Granada", data:""});
			cb.addItem({label:"Guadalajara", data:""});
			cb.addItem({label:"Guipúzcoa", data:""});
			cb.addItem({label:"Huelva", data:""});
			cb.addItem({label:"Huesca", data:""});
			cb.addItem({label:"Islas Baleares", data:""});
			cb.addItem({label:"Jaén", data:""});
			cb.addItem({label:"León", data:""});
			cb.addItem({label:"Lérida", data:""});
			cb.addItem({label:"Lugo", data:""});
			cb.addItem({label:"Madrid", data:""});
			cb.addItem({label:"Málaga", data:""});
			cb.addItem({label:"Murcia", data:""});
			cb.addItem({label:"Navarra", data:""});
			cb.addItem({label:"Orense", data:""});
			cb.addItem({label:"Palencia", data:""});
			cb.addItem({label:"Las Palmas", data:""});
			cb.addItem({label:"Pontevedra", data:""});
			cb.addItem({label:"La Rioja", data:""});
			cb.addItem({label:"Salamanca", data:""});
			cb.addItem({label:"Segovia", data:""});
			cb.addItem({label:"Sevilla", data:""});
			cb.addItem({label:"Soria", data:""});
			cb.addItem({label:"Tarragona", data:""});
			cb.addItem({label:"Santa Cruz de T.", data:""});
			cb.addItem({label:"Teruel", data:""});
			cb.addItem({label:"Toledo", data:""});
			cb.addItem({label:"Valencia", data:""});
			cb.addItem({label:"Valladolid", data:""});
			cb.addItem({label:"Vizcaya", data:""});
			cb.addItem({label:"Zamora", data:""});
			cb.addItem({label:"Zaragoza", data:""});
		}
			
		static public function AddMonths(cb : Object) : void
		{
			cb.addItem({label:"Enero", data:""});
			cb.addItem({label:"Febrero", data:""});
			cb.addItem({label:"Marzo", data:""});
			cb.addItem({label:"Abril", data:""});
			cb.addItem({label:"Mayo", data:""});
			cb.addItem({label:"Junio", data:""});
			cb.addItem({label:"Julio", data:""});
			cb.addItem({label:"Agosto", data:""});
			cb.addItem({label:"Septiembre", data:""});
			cb.addItem({label:"Octubre", data:""});
			cb.addItem({label:"Noviembre", data:""});
			cb.addItem({label:"Diciembre", data:""});			
		}
	}
}
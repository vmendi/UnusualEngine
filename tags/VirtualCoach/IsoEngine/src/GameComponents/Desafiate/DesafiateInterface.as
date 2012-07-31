package GameComponents.Desafiate
{
	import GameComponents.Character;
	import GameComponents.GameComponent;
	
	import flash.events.MouseEvent;
	
	/**
	 * Componente ...
	 */
	public final class DesafiateInterface extends GameComponent
	{

		override public function OnStart():void
		{
			TheVisualObject.gotoAndStop("empty");
			TheVisualObject.btWindowsPhone.addEventListener(MouseEvent.CLICK, OnWindowsPhoneClick);
			TheVisualObject.btSalaIT.addEventListener(MouseEvent.CLICK, OnGotoSalaIT);
			TheVisualObject.btRecepcion.addEventListener(MouseEvent.CLICK, OnGotoRecepcion);
			TheVisualObject.btSalaTrabajo.addEventListener(MouseEvent.CLICK, OnGotoSalaTrabajo);
			TheVisualObject.btCerrarWindowsPhone.addEventListener(MouseEvent.CLICK, OnCerrarWindowsPhone);
			TheVisualObject.btCerrarPanelAscensor.addEventListener(MouseEvent.CLICK, OnCerrarPanelAscensor);
			
			mCharacter = TheGameModel.FindGameComponentByShortName("Character") as Character;
		}
		
		public function ShowElevatorConsole() : void
		{
			TheVisualObject.gotoAndPlay("panel_ascensor_show");
			TheGameModel.PauseGame(true);
		}
		
		private function OnWindowsPhoneClick(e:MouseEvent) : void
		{
			TheVisualObject.gotoAndPlay("windows_phone_show");
			TheGameModel.PauseGame(true);
		}
		
		private function OnGotoSalaIT(e:MouseEvent) : void
		{
			TheGameModel.TheIsoEngine.Load("Maps/Desafiate/SalaIT.xml");
		}
		
		private function OnGotoRecepcion(e:MouseEvent) : void
		{
			TheGameModel.TheIsoEngine.Load("Maps/Desafiate/Recepcion.xml");
		}
		
		private function OnGotoSalaTrabajo(e:MouseEvent) : void
		{
			TheGameModel.TheIsoEngine.Load("Maps/Desafiate/SalaTrabajo.xml");
		}
		
		private function OnCerrarWindowsPhone(e:MouseEvent) : void
		{
			TheVisualObject.gotoAndPlay("windows_phone_hide");
			TheGameModel.PauseGame(false);
		}
		
		private function OnCerrarPanelAscensor(e:MouseEvent) : void
		{
			TheVisualObject.gotoAndPlay("panel_ascensor_hide");
			TheGameModel.PauseGame(false);
		}
		
		private var mCharacter : Character;
				
	}
}
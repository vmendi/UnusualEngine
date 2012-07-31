package GameComponents.FerrariShell
{
	import GameComponents.GameComponent;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class FerrariTabbedMenu extends GameComponent
	{
		override public function OnStart():void
		{
			TheVisualObject.btClasificacion.addEventListener(MouseEvent.CLICK, OnClasificacionClick);
			TheVisualObject.btJugar.addEventListener(MouseEvent.CLICK, OnJugarClick);
			TheVisualObject.btGanadores.addEventListener(MouseEvent.CLICK, OnGanadoresClick);
		}
		
		private function OnGanadoresClick(event:Event):void
		{
			//TheAssetObject.FindGameComponentByShortName("ScreenNavigator").GotoScreenTab("Ganadores");
		}
		
		private function OnClasificacionClick(event:Event) : void
		{
			TheAssetObject.FindGameComponentByShortName("ScreenNavigator").GotoScreenTab("Ranking");
		}
		
		private function OnJugarClick(event:Event):void
		{
			TheAssetObject.FindGameComponentByShortName("ScreenNavigator").GotoScreenTab("TrackSelection");
		}
	}
}
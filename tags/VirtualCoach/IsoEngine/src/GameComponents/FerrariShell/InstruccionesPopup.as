package GameComponents.FerrariShell
{
	import GameComponents.GameComponent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class InstruccionesPopup extends GameComponent
	{
		override public function OnStart():void
		{
			TheVisualObject.btComenzar.addEventListener(MouseEvent.CLICK, OnComenzar);
			TheVisualObject.btComenzar.buttonMode = true;	
		}
		
		private function OnComenzar(e:Event):void
		{
			TheGameModel.FindGameComponentByShortName("RaceControl").StartRace();
			TheGameModel.DeleteSceneObject(TheSceneObject);
		}
	}
}
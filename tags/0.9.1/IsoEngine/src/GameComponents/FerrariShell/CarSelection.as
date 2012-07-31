package GameComponents.FerrariShell
{
	import GameComponents.Screen;
	
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class CarSelection extends Screen
	{
		override public function OnScreenStart():void
		{			
			TheVisualObject.mcCoche1.addEventListener(MouseEvent.CLICK, OnCoche1Click);
			TheVisualObject.mcCoche2.addEventListener(MouseEvent.CLICK, OnCoche2Click);
			TheVisualObject.mcCoche3.addEventListener(MouseEvent.CLICK, OnCoche3Click);
		}
		
		private function OnCoche1Click(e:Event) : void
		{
			TheGameModel.GlobalGameState.SelectedCar = 0;
			TheGameModel.TheIsoEngine.Load(TheGameModel.GlobalGameState.SelectedTrackName);
		}
		
		private function OnCoche2Click(e:Event) : void
		{
			TheGameModel.GlobalGameState.SelectedCar = 1;
			TheGameModel.TheIsoEngine.Load(TheGameModel.GlobalGameState.SelectedTrackName);
		}
		
		private function OnCoche3Click(e:Event) : void
		{
			TheGameModel.GlobalGameState.SelectedCar = 2;
			TheGameModel.TheIsoEngine.Load(TheGameModel.GlobalGameState.SelectedTrackName);
		}
	}
}
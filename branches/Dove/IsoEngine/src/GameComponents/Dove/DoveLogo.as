package GameComponents.Dove
{
	import GameComponents.GameComponent;
	import GameComponents.ScreenSystem.FadeTransition;
	import GameComponents.ScreenSystem.ScreenNavigator;
	
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class DoveLogo extends GameComponent
	{
		override public function OnStart():void
		{
			TheVisualObject.buttonMode = true;
			
			TheVisualObject.addEventListener(MouseEvent.CLICK, OnClick);
		}
		
		private function OnClick(e:Event) : void
		{
			var screenNav : ScreenNavigator = TheGameModel.FindGameComponentByShortName("ScreenNavigator") as ScreenNavigator;
			
			if (!screenNav.IsTransitioning())
			{
				TheGameModel.FindGameComponentByShortName("DoveMainMenu").ResetPos();
				screenNav.GotoScreen("mcHome", new FadeTransition(500).Transition);
			}
		}
	}
}
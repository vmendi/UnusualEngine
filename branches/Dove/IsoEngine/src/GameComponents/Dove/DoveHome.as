package GameComponents.Dove
{
	import GameComponents.GameComponent;
	
	import flash.display.Loader;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;

	public class DoveHome extends GameComponent
	{
		override public function OnStart():void
		{
			// Siempre que aparecemos, el menu esta en 0... ya bajara al seleccionar una de sus opciones
			TheGameModel.FindGameComponentByShortName("DoveMainMenu").ResetPos();
			
			TheVisualObject.mcButGana.addEventListener(MouseEvent.CLICK, OnButGana);
			TheVisualObject.mcButGana.buttonMode = true;
			TheVisualObject.mcButGana.handCursor = true;
			
			SendTag();
		}
		
		private function SendTag() : void
		{
			var ebRand : Number = Math.random();
			ebRand = ebRand * 1000000;
						
			var activityParams : String = escape('ActivityID=55340&f=1');			
			var loader : Loader = new Loader();
			var theRequest : URLRequest = new URLRequest('HTTP://bs.serving-sys.com/BurstingPipe/activity.swf?ebAS=bs.serving-sys.com&activityParams=' + activityParams + '&rnd='+ ebRand);
			theRequest.method = URLRequestMethod.POST;
			loader.load(theRequest);
		}
	
		
		private function OnButGana(event:MouseEvent):void
		{
			var mainMenu : DoveMainMenu = (TheGameModel.FindGameComponentByShortName("DoveMainMenu") as DoveMainMenu);
			mainMenu.MakeTransition(mainMenu.TheVisualObject.mcButWall, "mcWorkInProgress");
			//mainMenu.GotoTrucos();
		}
	}
}
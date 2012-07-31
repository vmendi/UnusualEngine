package GameComponents.Dove
{
	import GameComponents.GameComponent;
	import GameComponents.ScreenSystem.FadeTransition;
	
	import flash.display.Loader;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	public class DoveTestEnd extends GameComponent
	{
		override public function OnStart():void
		{
			TheVisualObject.mcConsiguelosGratis.addEventListener(MouseEvent.CLICK, OnConsiguelosClick);
			
			SendTag();
		}
		
		private function SendTag() : void
		{
			var ebRand : Number = Math.random();
			ebRand = ebRand * 1000000;
						
			var activityParams : String = escape('ActivityID=55343&f=1');			
			var loader : Loader = new Loader();
			var theRequest : URLRequest = new URLRequest('HTTP://bs.serving-sys.com/BurstingPipe/activity.swf?ebAS=bs.serving-sys.com&activityParams=' + activityParams + '&rnd='+ ebRand);
			theRequest.method = URLRequestMethod.POST;
			loader.load(theRequest);
		}
		
		private function OnConsiguelosClick(event:MouseEvent):void
		{
			TheGameModel.FindGameComponentByShortName("ScreenNavigator").GotoScreen("mcForm", 
														new FadeTransition(500).Transition);
		}	
	}
}
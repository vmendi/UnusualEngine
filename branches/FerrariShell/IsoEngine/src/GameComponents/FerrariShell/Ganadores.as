package GameComponents.FerrariShell
{
	import GameComponents.ScreenSystem.ScreenTab;
	
	import flash.display.Loader;

	public class Ganadores extends ScreenTab
	{
		override public function OnStart():void
		{

		}
		
		private function onSuccess(loader:Loader):void
		{
			mLoaded = loader;
			TheVisualObject.addChild(mLoaded);
			mLoaded.x = -mLoaded.width + 150;
			mLoaded.y = -mLoaded.height + 130;
		}
		
		override public function OnScreenTabStart():void
		{
			TheGameModel.TheIsoEngine.TheCentralLoader.Load("http://www.hazlorealidadconshell.com/velocitaIII/ranking.swf", true, onSuccess, null, false);				
		}
		
		override public function OnScreenTabEnd():void
		{
			if (mLoaded != null)
				TheVisualObject.removeChild(mLoaded);
		}
		
		private var mLoaded : Loader;

	}
}
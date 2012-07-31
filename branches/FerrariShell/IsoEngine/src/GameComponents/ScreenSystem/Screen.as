package GameComponents.ScreenSystem
{
	import GameComponents.GameComponent;
	
	import utils.MovieClipLabels;
	
	public class Screen extends GameComponent
	{
		public var DefaultScreenTabName : String = "Unknown"; 
		
		override public function OnStart():void
		{
			mScreenTabs = new Object();
			
			for each(var comp : GameComponent in TheAssetObject.TheGameComponents)
			{
				if (comp is ScreenTab)
				{
					// Veamos si tenemos la etiqueta
					var screenTab : ScreenTab = comp as ScreenTab;
					var frameOfScreenTab : int = MovieClipLabels.GetFrameOfLabel(screenTab.ScreenTabName, TheVisualObject);
					
					if (frameOfScreenTab == -1)
						throw "ScreenTab " + screenTab.ScreenTabName + " does not exist in the movieclip's labels";
					
					mScreenTabs[screenTab.ScreenTabName] = comp;
				}
			}
		}
		
		public function get ScreenTabs() : Object { return mScreenTabs; }
		
		private var mScreenTabs : Object;	// Indexadas por nombre
	}
}
package GameComponents
{
	import utils.MovieClipLabels;
	
	public class ScreenManager extends GameComponent
	{
		public var DefaultScreenName : String = "Unknown";
		
		
		public function ScreenManager()
		{
			mScreens = new Object();
		}
		
		override public function OnStart():void
		{
			for each(var comp : GameComponent in TheAssetObject.TheGameComponents)
			{
				if (comp is Screen)
				{
					// Veamos si tenemos la etiqueta
					var screen : Screen = comp as Screen;
					var frameOfScreen : int = MovieClipLabels.GetFrameOfLabel(screen.ScreenName, TheVisualObject);
					
					if (frameOfScreen == -1)
						throw "Screen " + screen.ScreenName + " does not exist in the movieclip's labels";
					
					mScreens[screen.ScreenName] = comp;
				}
			}
			
			GotoScreen(DefaultScreenName);
		}
		
		public function GotoScreen(screenName : String):void
		{
			var targetScreen : Screen = mScreens[screenName];
			
			if (targetScreen == null)
				throw "Unknown screen";
				
			if (mTargetScreen != null)
			{
				trace("Can't jump to another screen while still transitioning. Ignoring!");
				return;
			}
			
			mTargetScreen = targetScreen;
			
			var exitStartFrame : int = -1;
			var exitEndFrame : int = -1;
			
			if (mCurrentScreen != null)
			{
				exitStartFrame = MovieClipLabels.GetFrameOfLabel(mCurrentScreen.ScreenName+"ExitStart", TheVisualObject);
			 	exitEndFrame = MovieClipLabels.GetFrameOfLabel(mCurrentScreen.ScreenName+"ExitEnd", TheVisualObject);
			}
			
			if (exitStartFrame != -1 && exitEndFrame != -1)
			{
				TheVisualObject.addFrameScript(exitEndFrame-1, OnExitEndArrivalNotification);
				TheVisualObject.gotoAndPlay(exitStartFrame);
			}
			else
			{
				InternalStartGotoScreen();
			}			
		}
		
		private function InternalStartGotoScreen() : void
		{
			if (mCurrentScreen != null)
				mCurrentScreen.OnScreenEnd();
			// Transicionalmente, tenemos target pero no current. Esto ocurre durante la entry del target.
			mCurrentScreen = null;	
			
			var entryStartFrame : int = MovieClipLabels.GetFrameOfLabel(mTargetScreen.ScreenName+"EntryStart", TheVisualObject);
			var entryEndFrame : int = MovieClipLabels.GetFrameOfLabel(mTargetScreen.ScreenName, TheVisualObject);
				
			// entryEnd siempre existe, puesto que es el label de la propia pantalla. Se verifica al añadirla.
			TheVisualObject.addFrameScript(entryEndFrame-1, OnEntryEndArrivalNotification);
			
			if (entryStartFrame != -1)
				TheVisualObject.gotoAndPlay(entryStartFrame);
			else
				TheVisualObject.gotoAndPlay(entryEndFrame);
		}
		
		private function OnExitEndArrivalNotification():void
		{
			TheVisualObject.addFrameScript(TheVisualObject.currentFrame-1, null);
			
			InternalStartGotoScreen();
		}
		
		private function OnEntryEndArrivalNotification():void
		{
			TheVisualObject.stop();
			TheVisualObject.addFrameScript(TheVisualObject.currentFrame-1, null);
			
			mCurrentScreen = mTargetScreen;
			mTargetScreen = null;
			mCurrentScreen.OnScreenStart();
		}
		
		private var mCurrentScreen : Screen;
		private var mTargetScreen : Screen;
		private var mScreens : Object;			/* Indexado por nombre de pantalla */
	}
}
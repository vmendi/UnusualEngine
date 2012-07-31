package GameComponents.ScreenSystem
{
	import GameComponents.GameComponent;
	
	import Model.SceneObject;
	import Model.UpdateEvent;
	
	import utils.MovieClipLabels;
	
	public class ScreenNavigator extends GameComponent
	{
		public var DefaultScreenName : String = "Self";
		
		override public function OnStart():void
		{		
		}
		
		override public function OnStartComplete():void
		{
			GotoScreen(DefaultScreenName, null);				
		}
		
		public function IsTransitioning() : Boolean
		{
			return mOldScreen != null;
		}
		
		public function GotoScreen(screenName : String, transitionFunc : Function) : void
		{ 			
			if (mCurrentScreen != null && mCurrentScreen.TheAssetObject.TheDefaultGameComponent.MovieClipName == screenName)
			{
				trace("Duplicate GotoScreen executed");
				return;
			}
			
			if (mOldScreen != null)
			{
				trace("3 way transition...");
				EndTransition();
			}

			if (screenName == "Self" || screenName == "")
			{
				ChangeToScreenAndDefaultTab(TheSceneObject);				
			}
			else
			{
				var newScreen : SceneObject = TheGameModel.CreateSceneObject(TheGameModel.TheAssetLibrary.FindAssetObjectByMovieClipName(screenName));
				
				if (mCurrentScreen == null)
				{
					ChangeToScreenAndDefaultTab(newScreen);
				}
				else
				if (transitionFunc == null)
				{
					TheGameModel.DeleteSceneObject(mCurrentScreen);
					mCurrentScreen = null;
									
					ChangeToScreenAndDefaultTab(newScreen);
				}
				else
				{
					mOldScreen = mCurrentScreen;
					mTransitionFunc = transitionFunc;
															
					ChangeToScreenAndDefaultTab(newScreen);
					
					// Re-ordenemos para que funcione bien la transicion, el target siempre por arriba (mayor z-order)
					if (mCurrentScreen.TheAssetObject.TheRender2DComponent.ZOrder < mOldScreen.TheAssetObject.TheRender2DComponent.ZOrder)
					{
						var swap : int = mCurrentScreen.TheAssetObject.TheRender2DComponent.ZOrder;
						mCurrentScreen.TheAssetObject.TheRender2DComponent.ZOrder = mOldScreen.TheAssetObject.TheRender2DComponent.ZOrder;
						mOldScreen.TheAssetObject.TheRender2DComponent.ZOrder = swap;
					}
					
					mTransitionFunc(mOldScreen.TheVisualObject, mCurrentScreen.TheVisualObject, 0);
				}
			}
		}
		
		override public function OnUpdate(event:UpdateEvent):void
		{
			if (mOldScreen != null)
			{
				var isFinished : Boolean = mTransitionFunc(mOldScreen.TheVisualObject, mCurrentScreen.TheVisualObject, event.ElapsedTime);
				
				if (isFinished)
					EndTransition();
			}
		}
		
		private function EndTransition() : void
		{
			// Lo borramos de la escena. Cuidado: Si la Screen es "Self" se acabo este Navigator.
			TheGameModel.DeleteSceneObject(mOldScreen);
					
			mOldScreen = null;
			mTransitionFunc = null;
		}
		
		private function ChangeToScreenAndDefaultTab(screen : SceneObject):void
		{
			mCurrentScreen = screen;
			
			// Dentro de la Screen, vamos al Tab por defecto si es que está configurado
			var screenComp : Screen = mCurrentScreen.TheAssetObject.FindGameComponentByShortName("Screen") as Screen;			
			if (screenComp != null)
				GotoScreenTab(screenComp.DefaultScreenTabName);
		}
		
		public function GotoScreenTab(screenTabName : String):void
		{
			// Veamos si nuestra pantalla actual tiene Tabs
			var screenComp : Screen = mCurrentScreen.TheAssetObject.FindGameComponentByShortName("Screen") as Screen;
			
			if (screenComp == null)
				throw "The current screen doesn't have Tabs";
			
			var targetTab : ScreenTab = screenComp.ScreenTabs[screenTabName];
			
			if (targetTab == null)
				throw "Unknown tab";
				
			if (mTargetTab != null)
			{
				trace("Can't jump to another tab while still transitioning. Ignoring!");
				return;
			}
			
			mTargetTab = targetTab;
			
			var exitStartFrame : int = -1;
			var exitEndFrame : int = -1;
			
			if (mCurrentTab != null)
			{
				exitStartFrame = MovieClipLabels.GetFrameOfLabel(mCurrentTab.ScreenTabName+"ExitStart", TheVisualObject);
			 	exitEndFrame = MovieClipLabels.GetFrameOfLabel(mCurrentTab.ScreenTabName+"ExitEnd", TheVisualObject);
			}
			
			if (exitStartFrame != -1 && exitEndFrame != -1)
			{
				TheVisualObject.addFrameScript(exitEndFrame-1, OnExitEndArrivalNotification);
				TheVisualObject.gotoAndPlay(exitStartFrame);
			}
			else
			{
				InternalStartGotoTab();
			}			
		}
		
		private function InternalStartGotoTab() : void
		{
			if (mCurrentTab != null)
				mCurrentTab.OnScreenTabEnd();
			// Transicionalmente, tenemos target pero no current. Esto ocurre durante la entry del target.
			mCurrentTab = null;	
			
			var entryStartFrame : int = MovieClipLabels.GetFrameOfLabel(mTargetTab.ScreenTabName+"EntryStart", TheVisualObject);
			var entryEndFrame : int = MovieClipLabels.GetFrameOfLabel(mTargetTab.ScreenTabName, TheVisualObject);
				
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
			
			InternalStartGotoTab();
		}
		
		private function OnEntryEndArrivalNotification():void
		{
			TheVisualObject.stop();
			TheVisualObject.addFrameScript(TheVisualObject.currentFrame-1, null);
			
			mCurrentTab = mTargetTab;
			mTargetTab = null;
			mCurrentTab.OnScreenTabStart();
		}
		
		private var mCurrentScreen : SceneObject;
		private var mOldScreen : SceneObject;
		private var mTransitionFunc : Function;
		
		private var mCurrentTab : ScreenTab;
		private var mTargetTab : ScreenTab;
	}
}
package GameComponents.ScreenSystem
{
	import GameComponents.GameComponent;
	
	import Model.UpdateEvent;
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;

	public class TabbedMenu extends GameComponent
	{
		public var FadeTotalTime : Number = 300;
		
		override public function OnStart():void
		{	
		}
		
		protected function CreateSubScreen(menuBut:MovieClip, contentName:String) : void
		{
			var newSubScreen : Object = new Object();
			newSubScreen.MenuButton = menuBut;
			newSubScreen.ContentName = contentName;
			newSubScreen.ContentMovieClip = TheGameModel.TheAssetLibrary.CreateMovieClip(newSubScreen.ContentName);
			mSubScreens.push(newSubScreen);	
			
			EnableSubScreen(mSubScreens.length-1);
		}
		
		protected function DisableSubScreen(idx:int):void
		{
			mSubScreens[idx].MenuButton.gotoAndStop("inactive");
			mSubScreens[idx].MenuButton.buttonMode = false;
			mSubScreens[idx].MenuButton.useHandCursor = false;
			mSubScreens[idx].MenuButton.removeEventListener(MouseEvent.CLICK, OnMenuButtonClick);
			mSubScreens[idx].MenuButton.removeEventListener(MouseEvent.MOUSE_OVER, OnMenuButtonOver);
			mSubScreens[idx].MenuButton.removeEventListener(MouseEvent.MOUSE_OUT, OnMenuButtonOut);
		}
		
		protected function EnableSubScreen(idx:int):void
		{
			mSubScreens[idx].MenuButton.gotoAndStop("off");
			mSubScreens[idx].MenuButton.buttonMode = true;
			mSubScreens[idx].MenuButton.useHandCursor = true;
			mSubScreens[idx].MenuButton.addEventListener(MouseEvent.CLICK, OnMenuButtonClick);
			mSubScreens[idx].MenuButton.addEventListener(MouseEvent.MOUSE_OVER, OnMenuButtonOver);
			mSubScreens[idx].MenuButton.addEventListener(MouseEvent.MOUSE_OUT, OnMenuButtonOut);
		}
		
		public function ShowSubScreen(idx : int):void
		{
			if (mOldSubScreen != null)
				return;
				
			if (mCurrentSubScreen == mSubScreens[idx])
				return;

			if (mSelectedButton != null)
				mSelectedButton.gotoAndStop("off");
			mSelectedButton = mSubScreens[idx].MenuButton;
			mSelectedButton.gotoAndStop("on");
					
			mOldSubScreen = mCurrentSubScreen;
			TheVisualObject.addChildAt(mSubScreens[idx].ContentMovieClip, 1);
			mCurrentSubScreen = mSubScreens[idx];
				
			if (mOldSubScreen != null)
			{
				mInterp = OnTransisitionToSubScreenStart();
				mInterp(mOldSubScreen.ContentMovieClip, mCurrentSubScreen.ContentMovieClip, 0);
			}
			else
			{
				OnTransisitionToSubScreenStart();
				OnTransisitionToSubScreenEnd();
			}
		}
		
		public function get IndexOfCurrentSubScreen() : int 
		{
			return GetIndexOfMenuButton(mSelectedButton);
		}
					
		private function GetIndexOfMenuButton(mc : MovieClip) : int
		{
			for (var c:int=0; c < mSubScreens.length; c++)
				if (mc == mSubScreens[c].MenuButton)
					return c;
			return -1;
		}
		
		private function OnMenuButtonClick(event:MouseEvent):void
		{
			ShowSubScreen(GetIndexOfMenuButton(event.target as MovieClip));	
		}
				
		private function OnMenuButtonOver(e:MouseEvent):void
		{
			var mcTarget : MovieClip = e.target as MovieClip;
		
			if (mcTarget != null)
				mcTarget.gotoAndStop("on");
		}
		
		private function OnMenuButtonOut(e:MouseEvent):void
		{
			var mcTarget : MovieClip = e.target as MovieClip;
			
			if (mcTarget != null && mSelectedButton != mcTarget)
				mcTarget.gotoAndStop("off");
		}
		
		override public function OnUpdate(event:UpdateEvent):void
		{
			if (mInterp != null)
			{
				var isFinished : Boolean = mInterp(mOldSubScreen.ContentMovieClip, mCurrentSubScreen.ContentMovieClip, event.ElapsedTime);
				
				if (isFinished)
				{
					OnTransisitionToSubScreenEnd();
					TheVisualObject.removeChild(mOldSubScreen.ContentMovieClip);
					mOldSubScreen = null;
					mInterp = null;
				}
			}
		}
		
		virtual public function OnTransisitionToSubScreenStart() : Function
		{
			return new FadeTransition(FadeTotalTime).Transition;
		}
		
		virtual public function OnTransisitionToSubScreenEnd():void
		{
		}
	
		public function get CurrentSubScreen() : Object { return mCurrentSubScreen; }
		public function get NumSubScreens() : int { return mSubScreens.length; }
		public function get SubScreens() : Array { return mSubScreens; }
		
		
		private var mInterp : Function;	
		private var mOldSubScreen : Object;
		private var mCurrentSubScreen : Object;
		private var mSelectedButton : MovieClip;
		private var mSubScreens : Array = new Array;
	}
}
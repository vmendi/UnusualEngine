package GameComponents.Dove
{
	import GameComponents.ScreenSystem.TabbedMenu;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	import utils.MovieClipBackwardsPlayer;

	public class DoveMenuProducts extends TabbedMenu
	{		
		override public function OnStart():void
		{			
			CreateSubScreen(TheVisualObject.mcMenu.mcPielNormal, "mcProductsPielNormal"); 
			CreateSubScreen(TheVisualObject.mcMenu.mcPielSeca, "mcProductsPielSeca");
			CreateSubScreen(TheVisualObject.mcMenu.mcPielExtraSeca, "mcProductsPielExtraSeca");
			
			for (var c:int = 0; c < NumSubScreens; c++)
			{
				SubScreens[c].CurrTextOver = null;

				var textIdx : int = 1;
				var textMC : MovieClip = SubScreens[c].ContentMovieClip["mcText"+textIdx];
				
				if (textMC != null)
					ShowText(SubScreens[c], textMC);
				 
				while (textMC != null)
				{
					textMC["BackwardsPlayer"] = new MovieClipBackwardsPlayer(textMC);
					textMC.addEventListener(MouseEvent.MOUSE_OVER, OnTextOver);
					
					if (textIdx != 1)
						textMC.gotoAndStop(1);
					
					textIdx++;					
					textMC = SubScreens[c].ContentMovieClip["mcText"+textIdx];
				}
			}
			
			ShowSubScreen(0);
			SendTag();
		}
		
		private function SendTag() : void
		{
			var ebRand : Number = Math.random();
			ebRand = ebRand * 1000000;
						
			var activityParams : String = escape('ActivityID=55341&f=1');			
			var loader : Loader = new Loader();
			var theRequest : URLRequest = new URLRequest('HTTP://bs.serving-sys.com/BurstingPipe/activity.swf?ebAS=bs.serving-sys.com&activityParams=' + activityParams + '&rnd='+ ebRand);
			theRequest.method = URLRequestMethod.POST;
			loader.load(theRequest);
		}
		
		private function OnTextOver(e:Event):void
		{
			ShowText(CurrentSubScreen, e.target as MovieClip);
		}
		
		private function ShowText(subScreen:Object, mc : MovieClip) : void
		{
			if (subScreen.CurrTextOver != mc)
			{
				if (subScreen.CurrTextOver != null)
				{
					var backPlayer : MovieClipBackwardsPlayer = subScreen.CurrTextOver["BackwardsPlayer"] as MovieClipBackwardsPlayer;
					backPlayer.GotoAndStopBackwards("off");	
				}
				
				subScreen.CurrTextOver = mc;
				
				if (subScreen.CurrTextOver != null)
				{
					backPlayer = subScreen.CurrTextOver["BackwardsPlayer"] as MovieClipBackwardsPlayer;
					if (backPlayer != null)
						backPlayer.Stop();	
					subScreen.CurrTextOver.gotoAndPlay(subScreen.CurrTextOver.currentFrame+1);
				}
			}		
		}
		
	}
}
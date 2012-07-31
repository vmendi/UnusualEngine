package GameComponents.Dove
{
	import GameComponents.ScreenSystem.FadeTransition;
	import GameComponents.ScreenSystem.TabbedMenu;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	import gs.TweenLite;
	
	import mx.core.Application;

	public class DoveMenuTest extends TabbedMenu
	{
		override public function OnStart():void
		{
			for (var c:int=0; c < 6; c++)
			{
				CreateSubScreen(TheVisualObject.mcMenu["mcBut"+(c+1).toString()], "mcPreg"+ (c+1).toString());
				DisableSubScreen(c);
				
				mRespuestas.push(-1);
				mAvailableAnswers.push(new Array());
				AddRespuestas(SubScreens[c].ContentMovieClip, 1, c);
			}
						
			EnableSubScreen(0);			
			ShowSubScreen(0);
			
			SendTag();
		}
		
		private function SendTag() : void
		{
			var ebRand : Number = Math.random();
			ebRand = ebRand * 1000000;
						
			var activityParams : String = escape('ActivityID=55342&f=1');			
			var loader : Loader = new Loader();
			var theRequest : URLRequest = new URLRequest('HTTP://bs.serving-sys.com/BurstingPipe/activity.swf?ebAS=bs.serving-sys.com&activityParams=' + activityParams + '&rnd='+ ebRand);
			theRequest.method = URLRequestMethod.POST;
			loader.load(theRequest);
		}
					
		override public function OnTransisitionToSubScreenStart():Function
		{
			// Cada vez que volvemos a la 1, se desactiva todo
			if (IndexOfCurrentSubScreen == 0)
			{
				for (var c:int=1; c < NumSubScreens; c++)
				{
					DisableSubScreen(c);
					mRespuestas[c] = -1;
					
					for each(var mc:MovieClip in mAvailableAnswers[c])
						mc.gotoAndStop("off");
						
					if (c != NumSubScreens - 1)
					{
						SubScreens[c].ContentMovieClip["mcNextQuestion"].alpha = 0;
						SubScreens[c].ContentMovieClip["mcNextQuestion"].useHandCursor = false;
						SubScreens[c].ContentMovieClip["mcNextQuestion"].removeEventListener(MouseEvent.CLICK, OnNextQuestionClick);
					}
					else
					{
						SubScreens[c].ContentMovieClip["mcEndTest"].alpha = 0;
						SubScreens[c].ContentMovieClip["mcEndTest"].useHandCursor = false;
						SubScreens[c].ContentMovieClip["mcEndTest"].removeEventListener(MouseEvent.CLICK, OnGotoResult);
					}
				}					
			}
								
			return super.OnTransisitionToSubScreenStart();
		}

		private function OnRespuestaClick(e:MouseEvent):void
		{	
			var selected : MovieClip = (e.target as MovieClip); 
			var bValidClick : Boolean = true;
			
			// El caso especial
			if (IndexOfCurrentSubScreen == 0)
			{
				var subRes : MovieClip = CurrentSubScreen.ContentMovieClip["mcSubRespuestas"]
			
				if (selected.name == "mcRespuesta2" && selected.parent != subRes)
				{
					if (mAvailableAnswers[0].length <= 2)
					{
						TweenLite.to(subRes, 0.3, {alpha:1.0});
						TweenLite.to(selected, 0.3, {alpha:0});
						selected.useHandCursor = false;
						selected.buttonMode = false;
						selected.removeEventListener(MouseEvent.CLICK, OnRespuestaClick);	
						AddRespuestas(subRes, 2, IndexOfCurrentSubScreen);
						bValidClick = false;
						TweenLite.to(CurrentSubScreen.ContentMovieClip["mcNextQuestion"], 0.3, { alpha: 0 });
						CurrentSubScreen.ContentMovieClip["mcNextQuestion"].removeEventListener(MouseEvent.CLICK, OnNextQuestionClick);
						CurrentSubScreen.ContentMovieClip["mcNextQuestion"].useHandCursor = false;
					}
				}
			}
			
			var idxOfNumber : int = "mcRespuesta".length;
			mRespuestas[IndexOfCurrentSubScreen] = selected.name.substr(idxOfNumber, selected.name.length - idxOfNumber);
			
			if (bValidClick)
			{
				if (IndexOfCurrentSubScreen == 0)
				{
					if (mRespuestas[0] > 1)
						mSaltaPreguntas = true;
					else
						mSaltaPreguntas = false;
				}
				
				ShowNext();
				
				for each(var mc:MovieClip in mAvailableAnswers[IndexOfCurrentSubScreen])
					mc.gotoAndStop("off");
				
				selected.gotoAndStop("on");
			}
		}
		
		private var mSaltaPreguntas : Boolean = false;
		
		private function ShowNext() : void
		{
			if (IndexOfCurrentSubScreen <= 4)
			{
				if (CurrentSubScreen.ContentMovieClip["mcNextQuestion"].alpha == 0)
				{
					TweenLite.to(CurrentSubScreen.ContentMovieClip["mcNextQuestion"], 0.3, { alpha: 1 });
					CurrentSubScreen.ContentMovieClip["mcNextQuestion"].addEventListener(MouseEvent.CLICK, OnNextQuestionClick);
					CurrentSubScreen.ContentMovieClip["mcNextQuestion"].useHandCursor = true;
				}
			}
			else
			{
				if (CurrentSubScreen.ContentMovieClip["mcEndTest"].alpha == 0)
				{
					TweenLite.to(CurrentSubScreen.ContentMovieClip["mcEndTest"], 0.3, { alpha: 1 });
					CurrentSubScreen.ContentMovieClip["mcEndTest"].addEventListener(MouseEvent.CLICK, OnGotoResult);
					CurrentSubScreen.ContentMovieClip["mcEndTest"].useHandCursor = true;
				}
			}	
		}
		
		private function OnGotoResult(event:Event):void
		{
			var result : Number = 0;
			var numRespuestas : int = mRespuestas.length;
			
			for (var c:int = 1; c < mRespuestas.length; c++)
			{
				var curr : Number = parseFloat(mRespuestas[c]);
				
				if (curr == -1)
				{
					numRespuestas--;
				}
				else
				{
					result += curr;
				}
			}
			
			result /= numRespuestas - 1;
			
			var resultScreen : String = "mcTestEndNormal";
			var idxToScreen : int = 0;
			
			if (result >= 2.5)
			{
				resultScreen = "mcTestEndExtraSeca";
				idxToScreen = 2;
			}
			else if(result >= 1.5)
			{
				resultScreen = "mcTestEndSeca";
				idxToScreen = 1;
			}
			
			TheGameModel.GlobalGameState.LastTestResult = idxToScreen;
			
			TheGameModel.FindGameComponentByShortName("ScreenNavigator").GotoScreen(resultScreen, new FadeTransition(500).Transition);
			
			// Envio al server
			(Application.application as Object).SaveTestResult(mRespuestas);
		}
		
		private function OnNextQuestionClick(event:Event):void
		{
			var offsetIdx : int = 1;
			
			if (mSaltaPreguntas)
			{
				if (IndexOfCurrentSubScreen == 0 || IndexOfCurrentSubScreen == 2)
					offsetIdx = 2;					
			}
			
			EnableSubScreen(IndexOfCurrentSubScreen + offsetIdx);
			ShowSubScreen(IndexOfCurrentSubScreen + offsetIdx);
		}
		
		private function AddRespuestas(mc : MovieClip, startIdx : int, indexOfCurrent:int):void
		{
			var idxRespuesta : int = startIdx;
			var mcRespuesta : MovieClip = mc["mcRespuesta" + idxRespuesta];
			
			while (mcRespuesta != null)
			{
				mAvailableAnswers[indexOfCurrent].push(mcRespuesta);
				mcRespuesta.addEventListener(MouseEvent.CLICK, OnRespuestaClick);
				mcRespuesta.useHandCursor = true;
				mcRespuesta.buttonMode = true;
				idxRespuesta++;
				mcRespuesta  = mc["mcRespuesta" + idxRespuesta];
			}
		}
		
		private var mRespuestas : Array = new Array;
		
		// Los movieclips de las respuestas de la subscreen actual
		private var mAvailableAnswers : Array = new Array();
	}
}
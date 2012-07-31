package GameComponents.Desafiate
{
	import GameComponents.Bso;
	import GameComponents.GameComponent;

	import Model.UpdateEvent;

	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	import mx.core.Application;
	import mx.events.FlexEvent;
	import mx.managers.SystemManager;

	import utils.Delegate;
	import utils.MovieClipListener;

	public class MiniGameManager extends GameComponent
	{
		// Una vez llegado al checkpoint, segundos entre ofrecimiento de minijuegos en el WindowsPhone
		public const SECONDS_BETWEEN_MINIGAMES : int = 10;

		// Cuando se agota este tiempo, abrimos el siguiente TM
		public const SECONDS_OF_INTERLUDE : int = 360;


		override public function OnStart():void
		{
			mStatus = TheGameModel.FindGameComponentByShortName("GameStatus") as GameStatus;
			mWindowsPhone = TheGameModel.FindGameComponentByShortName("WindowsPhone") as WindowsPhone;

			if (mStatus.Bag.child("MiniGameManager").length() == 0)
			{
				mStatus.Bag.MiniGameManager.MessageSequenceCount = -1;
				mStatus.Bag.MiniGameManager.NextTimeManagementCount = -1;
			}
		}

		public function PlayMiniGame(whichOne : String, onMiniGameEnded : Function) : void
		{
			mOnEndCallback = onMiniGameEnded;

			TheVisualObject.visible = true;
			TheVisualObject.mcWait.visible = true;
			TheVisualObject.mcCortina.visible = false;

			(TheGameModel.FindGameComponentByShortName("Bso") as Bso).CrossFadeTo("Assets/Desafiate/Music/Minijuego.mp3");

			TheGameModel.TheIsoEngine.TheCentralLoader.Load("Assets/Desafiate/"+whichOne+".swf",
																true, Delegate.create(OnMiniGameLoaded, whichOne));

			mStatus.Bag.MiniGameManager[whichOne].Score = -1;
			IncrementNumTimesPlayed(whichOne);
		}

		public function IsMiniGamePlayed(whichOne : String): Boolean
		{
			return (mStatus.Bag.MiniGameManager.child(whichOne).length() > 0) &&
				   (parseInt(mStatus.Bag.MiniGameManager[whichOne].Score) >= 0);
		}

		public function GetScoreForMiniGame(whichOne : String) : int
		{
			if (!IsMiniGamePlayed(whichOne))
				return -1;
			else
				return parseInt(mStatus.Bag.MiniGameManager[whichOne].Score);
		}

		private function OnMiniGameLoaded(loader : Loader, whichOne : String):void
		{
			mCurrentMiniGameName = whichOne;
			mCurrentDisplayed = loader.content;
			TheVisualObject.addChild(mCurrentDisplayed);
			TheVisualObject.mcWait.visible = false;
			mCurrentDisplayed.x = -457;
			mCurrentDisplayed.y = -254;

			if ((mCurrentDisplayed as SystemManager) != null)
			{
				var sysManager : SystemManager = mCurrentDisplayed as SystemManager;
				sysManager.addEventListener(FlexEvent.APPLICATION_COMPLETE, OnAppComplete);
			}
			else
			{
				mCurrentMiniGameAPI = mCurrentDisplayed;
				mCurrentMiniGameAPI.Start();

				if (whichOne == "SilverFlash")
				{
					mCurrentMiniGameAPI.GetbtNavegar().addEventListener(MouseEvent.CLICK, OnSilverFlashNavegarClick);
				}
			}
		}

		private function OnSilverFlashNavegarClick(e:Event):void
		{
			navigateToURL(new URLRequest("/Silverlight"), "_blank");
			(TheGameModel.FindGameComponentByShortName("Bso") as Bso).Stop();
		}

		private function OnAppComplete(e:Event):void
		{
			mCurrentMiniGameAPI = (mCurrentDisplayed as SystemManager).application as Application;
			mCurrentMiniGameAPI.Start();
		}

		override public function OnUpdate(event:UpdateEvent):void
		{
			if (mCurrentMiniGameAPI != null)
			{
				if (mCurrentMiniGameAPI.IsEnded())
				{
					EndCurrentMinigame(mCurrentMiniGameAPI.GetScore());
				}
				else
				if (mCurrentMiniGameName == "SilverFlash" && IsSilverlightEnded())
				{
					EndCurrentMinigame(800);
				}
			}
			else
			{
				OnUpdateMessageSequence(event);
				OnUpdateNextTimeManagement(event);
			}
		}

		private function EndCurrentMinigame(score:int):void
		{
			// El silverflash aunque salga con la X, lo damos por acabado
			if (mCurrentMiniGameName == "SilverFlash" && score == -1)
				score = 0;

			// Grabamos la puntuacion en memoria
			mStatus.Bag.MiniGameManager[mCurrentMiniGameName].Score = score;

			mCurrentMiniGameAPI.Stop();
			mCurrentMiniGameAPI = null;

			TheVisualObject.visible = false;
			TheVisualObject.removeChild(mCurrentDisplayed);
			mCurrentDisplayed = null;

			(TheGameModel.FindGameComponentByShortName("Bso") as Bso).CrossFadeTo("Assets/Desafiate/Music/General.mp3");

			// Quitamos el mensaje para este minijuego en el WindowsPhone, si existiera
			if (score != -1)
				DisableWindowsPhoneMessageForCurrentMinigame();

			// Veamos si acabamos el interludio y ofrecemos el siguiente TM
			if (AllMiniGamesForThisInterludeCompleted())
				GotoNextTimeManagementCheckpoint();

			// Siempre al acabar un minijuego, grabamos al servidor tanto los puntos como el status
			mStatus.AddGeekPoints("MiniGameEnded"+mCurrentMiniGameName, score)
			mStatus.SaveToServer();

			mCurrentMiniGameName = null;

			mOnEndCallback(score);
			mOnEndCallback = null;
		}

		private function IncrementNumTimesPlayed(gameName : String) : void
		{
			var timesPlayed : int = parseInt(mStatus.Bag.MiniGameManager[gameName].TimesPlayed);
			mStatus.Bag.MiniGameManager[gameName].TimesPlayed = timesPlayed + 1;
		}

		public function GetNumTimesPlayed(gameName : String) : int
		{
			return parseInt(mStatus.Bag.MiniGameManager[gameName].TimesPlayed);
		}

		private function IsSilverlightEnded():Boolean
		{
			var bRet : Boolean = false;
			if (mCurrentMiniGameName == "SilverFlash")
			{
				var ret : Object = ExternalInterface.call("getSilver");
				bRet = ret as Boolean;
			}
			return bRet;
		}


		private function GotoNextTimeManagementCheckpoint():void
		{
			// Cambiar el Checkpoint provocara el evento OnCheckpointChanged
			if (mStatus.AreWeBetweenCheckpoints(Checkpoints.INTER01, Checkpoints.TM02_START))
				mStatus.Checkpoint = Checkpoints.TM02_START;
			else if (mStatus.AreWeBetweenCheckpoints(Checkpoints.INTER02, Checkpoints.TM03_START))
				mStatus.Checkpoint = Checkpoints.TM03_START;
		}

		private function DisableWindowsPhoneMessageForCurrentMinigame() : void
		{
			if (mCurrentMiniGameName == "SuenoDelGeek")
				mWindowsPhone.DisableMessage(Checkpoints.INTER01, 100);
			else
			if (mCurrentMiniGameName == "GuessPassword")
				mWindowsPhone.DisableMessage(Checkpoints.INTER01, 101);
			else
			if (mCurrentMiniGameName == "PowerShellBug")
				mWindowsPhone.DisableMessage(Checkpoints.INTER01, 102);
			else
			if (mCurrentMiniGameName == "VendingMachine")
				mWindowsPhone.DisableMessage(Checkpoints.INTER02, 100);
			else
			if (mCurrentMiniGameName == "GuessPassword2")
				mWindowsPhone.DisableMessage(Checkpoints.INTER02, 101);
			else
			if (mCurrentMiniGameName == "SilverFlash")
				mWindowsPhone.DisableMessage(Checkpoints.INTER02, 102);
			else
			if (mCurrentMiniGameName != "GeekQuiz")
				throw "Unknown minigame";
		}

		private function AllMiniGamesForThisInterludeCompleted() : Boolean
		{
			var bRet : Boolean = false;

			if (mStatus.AreWeBetweenCheckpoints(Checkpoints.INTER01, Checkpoints.TM02_START))
			{
				if (IsMiniGamePlayed("GuessPassword") && IsMiniGamePlayed("SuenoDelGeek") &&
					IsMiniGamePlayed("PowerShellBug"))
					bRet = true;
			}
			else
			if (mStatus.AreWeBetweenCheckpoints(Checkpoints.INTER02, Checkpoints.TM03_START))
			{
				if (IsMiniGamePlayed("VendingMachine") && IsMiniGamePlayed("GuessPassword2") &&
					IsMiniGamePlayed("SilverFlash") )
					bRet = true;
			}

			return bRet;
		}

		private function OnUpdateNextTimeManagement(event:UpdateEvent):void
		{
			if (mStatus.Bag.MiniGameManager.NextTimeManagementCount == -1)
				return;

			mNextTimeManagementCurrentTime += event.ElapsedTime;

			if (mNextTimeManagementCurrentTime >= 1000)
			{
				mNextTimeManagementCurrentTime = 0;
				mStatus.Bag.MiniGameManager.NextTimeManagementCount--;

				if (mStatus.Bag.MiniGameManager.NextTimeManagementCount == 0)
				{
					mStatus.Bag.MiniGameManager.NextTimeManagementCount = -1;
					GotoNextTimeManagementCheckpoint();
				}
			}
		}

		private function OnUpdateMessageSequence(event:UpdateEvent):void
		{
			if (mStatus.Bag.MiniGameManager.MessageSequenceCount < 0)
				return;

			mMessageSequenceCurrentTime += event.ElapsedTime;

			if (mMessageSequenceCurrentTime >= 1000)
			{
				mStatus.Bag.MiniGameManager.MessageSequenceCount--;
				mMessageSequenceCurrentTime = 0;

				if ((mStatus.Bag.MiniGameManager.MessageSequenceCount % SECONDS_BETWEEN_MINIGAMES) == 0)
					ShowNextMiniGameOnWindowsPhone();

				// Cuenta atras acabada == -2
				if (mStatus.Bag.MiniGameManager.MessageSequenceCount == 0)
					mStatus.Bag.MiniGameManager.MessageSequenceCount = -2;
			}
		}

		private function StartInterlude():void
		{
			if (mStatus.Bag.MiniGameManager.MessageSequenceCount >= 0)
				throw "WTF";

			if (mStatus.Checkpoint == Checkpoints.INTER01)
				mStatus.Bag.MiniGameManager.MessageSequenceCount = SECONDS_BETWEEN_MINIGAMES*3;
			else
			if (mStatus.Checkpoint == Checkpoints.INTER02)
				mStatus.Bag.MiniGameManager.MessageSequenceCount = SECONDS_BETWEEN_MINIGAMES*3;
			else
				throw "WTF?!?";

			mStatus.Bag.MiniGameManager.NextTimeManagementCount = SECONDS_OF_INTERLUDE;
		}

		public function OnCheckpointChanged(chk : String):void
		{
			if (chk == Checkpoints.INTER01 || chk == Checkpoints.INTER02)
			{
				StartInterlude();
			}
			else
			if (chk == Checkpoints.TM02_START)
			{
				// Quitamos todos los mensajes de los minijuegos para este interludio, si los hubiera
				mWindowsPhone.DisableMessage(Checkpoints.INTER01, 100);
				mWindowsPhone.DisableMessage(Checkpoints.INTER01, 101);
				mWindowsPhone.DisableMessage(Checkpoints.INTER01, 102);

				// Ponemos el mensaje de "ve al siguiente TM"
				mWindowsPhone.EnableMessage(Checkpoints.TM02_START, 0, true);
			}
			else
			if (chk == Checkpoints.TM03_START)
			{
				mWindowsPhone.DisableMessage(Checkpoints.INTER02, 100);
				mWindowsPhone.DisableMessage(Checkpoints.INTER02, 101);
				mWindowsPhone.DisableMessage(Checkpoints.INTER02, 102);

				mWindowsPhone.EnableMessage(Checkpoints.TM03_START, 0, true);
			}
		}

		private function ShowNextMiniGameOnWindowsPhone():void
		{
			if (mStatus.Bag.MiniGameManager.MessageSequenceCount % SECONDS_BETWEEN_MINIGAMES != 0)
				throw "WTF";

			var onSequenceInt : int = 2 - (mStatus.Bag.MiniGameManager.MessageSequenceCount / SECONDS_BETWEEN_MINIGAMES);

			// Inicializamos suponiendo q estamos en INTER01
			var miniGames : Array = [ "SuenoDelGeek", "GuessPassword", "PowerShellBug" ];
			var chk : String = Checkpoints.INTER01;

			if (mStatus.AreWeBetweenCheckpoints(Checkpoints.INTER02, Checkpoints.END))
			{
				chk = Checkpoints.INTER02;
				miniGames = [ "VendingMachine", "GuessPassword2", "SilverFlash" ];
			}
			else if (!mStatus.AreWeBetweenCheckpoints(Checkpoints.INTER01, Checkpoints.INTER02))
				throw "WTF";

			while (onSequenceInt < miniGames.length)
			{
				if (!IsMiniGamePlayed(miniGames[onSequenceInt]))
				{
					mWindowsPhone.EnableMessage(chk, 100+onSequenceInt, true);
					break;
				}
				onSequenceInt++;

				if (onSequenceInt < miniGames.length)
					mStatus.Bag.MiniGameManager.MessageSequenceCount = (2-onSequenceInt) * SECONDS_BETWEEN_MINIGAMES;
				else
					mStatus.Bag.MiniGameManager.MessageSequenceCount = 0;
			}
		}

		public function PlayIntro(whichOne : String, onEndCallback:Function, blackLoading : Boolean):void
		{
			if (blackLoading)
				TheVisualObject.mcCortina.visible = true
			else
				TheVisualObject.mcCortina.visible = false;

			TheGameModel.PauseGame(true);
			mOnEndCallback = onEndCallback;
			TheGameModel.TheIsoEngine.TheCentralLoader.Load("Assets/Desafiate/"+whichOne+".swf",
															true, Delegate.create(OnIntroLoaded, whichOne));
			TheVisualObject.visible = true;
			TheVisualObject.mcWait.visible = true;
			
			mCurrentMiniGameName = whichOne;

			(TheGameModel.FindGameComponentByShortName("Bso") as Bso).CrossFadeTo("Assets/Desafiate/Music/Animacion.mp3");
		}

		private function OnIntroLoaded(loader : Loader, whichOne : String):void
		{
			mCurrentDisplayed = loader.content;
			TheVisualObject.addChild(mCurrentDisplayed);
			TheVisualObject.mcWait.visible = false;
			mCurrentDisplayed.x = -457;
			mCurrentDisplayed.y = -254;

			MovieClipListener.AddFrameScript(mCurrentDisplayed as MovieClip, "end", OnIntroEnd);
			(mCurrentDisplayed as MovieClip).gotoAndPlay("start");
		}

		private function OnIntroEnd():void
		{
			(TheGameModel.FindGameComponentByShortName("Bso") as Bso).CrossFadeTo("Assets/Desafiate/Music/General.mp3");

			(mCurrentDisplayed as MovieClip).stop();
			TheGameModel.PauseGame(false);

			TheVisualObject.visible = false;
			TheVisualObject.removeChild(mCurrentDisplayed);
			mOnEndCallback();
			
			if (mCurrentMiniGameName == "Animacion02")
				AtlasManager.CallToUrl("http://clk.atdmt.com/MSA/go/236034353/direct/01/");
			else
			if (mCurrentMiniGameName == "Animacion03")
				AtlasManager.CallToUrl("http://clk.atdmt.com/MSA/go/236034355/direct/01/");
			else
			if (mCurrentMiniGameName == "Animacion04")
				AtlasManager.CallToUrl("http://clk.atdmt.com/MSA/go/236034357/direct/01/");
			
			mCurrentMiniGameName = null;
			mOnEndCallback = null;
			mCurrentDisplayed = null;
		}

		private var mCurrentDisplayed : DisplayObject;
		private var mCurrentMiniGameName : String;
		private var mCurrentMiniGameAPI : Object;
		private var mOnEndCallback : Function;
		private var mStatus : GameStatus;
		private var mWindowsPhone : WindowsPhone;
		private var mMessageSequenceCurrentTime : int = 0;
		private var mNextTimeManagementCurrentTime : int = 0;
	}
}
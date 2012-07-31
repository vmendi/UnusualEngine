package GameComponents.Desafiate
{
	import GameComponents.Character;
	import GameComponents.GameComponent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import gs.TweenLite;
	
	import utils.Delegate;
	import utils.TimeUtils;

	/**
	 * Componente ...
	 */
	public final class DesafiateInterface extends GameComponent
	{
		override public function OnStart():void
		{
			TheVisualObject.gotoAndStop("empty");
			TheVisualObject.mcTime.visible = false;
			TheVisualObject.mcProfileScreen.visible = false;
			TheVisualObject.mcProfileScreen.alpha = 0.0;

			TheVisualObject.btWindowsPhone.addEventListener(MouseEvent.CLICK, OnWindowsPhoneClick);
			TheVisualObject.mcGeekPoints.mcProfileScreenButton.addEventListener(MouseEvent.CLICK, OnProfileScreenButtonClick);

			TheVisualObject.btWindowsPhone.useHandCursor = true;
			TheVisualObject.mcGeekPoints.mcProfileScreenButton.useHandCursor = true;
			TheVisualObject.mcGeekPoints.mcProfileScreenButton.buttonMode = true;

			mCharacter = TheGameModel.FindGameComponentByShortName("Character") as Character;
			mWindowsPhone = TheGameModel.FindGameComponentByShortName("WindowsPhone") as WindowsPhone;
			mStatus = TheGameModel.FindGameComponentByShortName("GameStatus") as GameStatus;

			TheVisualObject.mcGeekPoints.ctPoints.text = mStatus.Bag.Geekpoints;
		}

		override public function OnStop():void
		{
			TweenLite.killTweensOf(TheVisualObject.btWindowsPhone);
		}

		private function OnWindowsPhoneClick(e:MouseEvent) : void
		{
			mWindowsPhone.Show(null);
		}

		private function OnProfileScreenButtonClick(e:MouseEvent):void
		{
			ShowProfileScreen();
		}

		public function ShowAll(bShow:Boolean):void
		{
			if (bShow)
			{
				TheVisualObject.visible = true;
				TweenLite.to(TheVisualObject, 0.25, {alpha:1});
			} else {
				TweenLite.to(TheVisualObject, 0.25, {alpha:0, onComplete:OnAllAlphaComplete } );
			}
		}

		private function OnAllAlphaComplete():void
		{
			TheVisualObject.visible=false;
		}

		public function ShowPhone(bShow:Boolean, bInmediate:Boolean):void
		{
			if (bShow)
			{
				TheVisualObject.btWindowsPhone.visible = true;

				if (!bInmediate)
					TweenLite.to(TheVisualObject.btWindowsPhone, 0.25, {alpha:1});
				else
					TheVisualObject.btWindowsPhone.alpha = 1;
			}
			else
			{
				if (!bInmediate)
					TweenLite.to(TheVisualObject.btWindowsPhone, 0.25, {alpha:0, onComplete:HidePhoneInmediate});
				else
					HidePhoneInmediate();
			}
		}

		private function HidePhoneInmediate():void
		{
			TheVisualObject.btWindowsPhone.visible = false;
		}

		public function BlinkPhone() : void
		{
			InnerBlink(0, 0.25);
		}


		public function SetTime(milisecs : int):void
		{
			TheVisualObject.mcTime.ctTime.text = TimeUtils.ConvertMilisecsToString(milisecs);
		}

		public function ShowTime(bShow : Boolean):void
		{
			if (bShow)
			{
				TheVisualObject.mcTime.visible = true;
				TweenLite.to(TheVisualObject.mcTime, 0.25, {alpha:1});
			}
			else
			{
				TweenLite.to(TheVisualObject.mcTime, 0.25, {alpha:0, onComplete:OnTimeAlphaComplete } );
			}
		}

		private function OnTimeAlphaComplete():void
		{
			TheVisualObject.mcTime.visible=false;
		}

		private function InnerBlink(count:int, targetAlpha:Number):void
		{
			if (count<8)
			{
				var newTargetAlpha : Number = targetAlpha == 0.25? 1 : 0.25;
				TweenLite.to(TheVisualObject.btWindowsPhone, 0.50, {alpha:targetAlpha,
							 onComplete:Delegate.create(InnerBlink, count+1, newTargetAlpha)});
			}
		}

		public function OnScoreChanged(scoreInfo:Object):void
		{
			TheVisualObject.mcGeekPoints.ctPoints.text = scoreInfo.TotalPoints;
		}

		private function ShowProfileScreen():void
		{
			TheGameModel.PauseGame(true);

			TheVisualObject.mcProfileScreen.visible = true;
			TheVisualObject.mcProfileScreen.mcConfirma.visible = false;
			TweenLite.to(TheVisualObject.mcProfileScreen, 0.5, { alpha:1.0 });

			TheVisualObject.mcProfileScreen.mcButtonNueva.addEventListener(MouseEvent.CLICK, OnButtonNuevaClick);
			TheVisualObject.mcProfileScreen.mcButtonVolver.addEventListener(MouseEvent.CLICK, OnButtonVolverClick);

			TheVisualObject.mcProfileScreen.mcButtonNueva.buttonMode = true;
			TheVisualObject.mcProfileScreen.mcButtonNueva.useHandCursor = true;

			TheVisualObject.mcProfileScreen.mcButtonVolver.buttonMode = true;
			TheVisualObject.mcProfileScreen.mcButtonVolver.useHandCursor = true;

			ShowHideLogros();
			ShowCurrentCheckpoint();
		}

		private function OnButtonNuevaClick(e:MouseEvent):void
		{
			TheVisualObject.mcProfileScreen.mcConfirma.visible = true;
			TheVisualObject.mcProfileScreen.mcConfirma.mcButtonSi.addEventListener(MouseEvent.CLICK, OnButtonSi);
			TheVisualObject.mcProfileScreen.mcConfirma.mcButtonNo.addEventListener(MouseEvent.CLICK, OnButtonNo);
			TheVisualObject.mcProfileScreen.mcConfirma.mcButtonSi.buttonMode = true;
			TheVisualObject.mcProfileScreen.mcConfirma.mcButtonNo.buttonMode = true;
			TheVisualObject.mcProfileScreen.mcConfirma.mcButtonSi.useHandCursor = true;
			TheVisualObject.mcProfileScreen.mcConfirma.mcButtonNo.useHandCursor = true;
		}
		
		private function OnButtonSi(e:Event):void
		{
			mStatus.RestartGame();	
		}
		
		private function OnButtonNo(e:Event):void
		{
			TheVisualObject.mcProfileScreen.mcConfirma.visible = false;
			TheVisualObject.mcProfileScreen.mcConfirma.mcButtonSi.removeEventListener(MouseEvent.CLICK, OnButtonSi);
			TheVisualObject.mcProfileScreen.mcConfirma.mcButtonNo.removeEventListener(MouseEvent.CLICK, OnButtonNo);
		}

		private function OnButtonVolverClick(e:MouseEvent):void
		{
			TheVisualObject.mcProfileScreen.mcButtonNueva.removeEventListener(MouseEvent.CLICK, OnButtonNuevaClick);
			TheVisualObject.mcProfileScreen.mcButtonVolver.removeEventListener(MouseEvent.CLICK, OnButtonVolverClick);

			TweenLite.to(TheVisualObject.mcProfileScreen, 0.5, { alpha:0.0, onComplete:OnProfileScreenHidden });
		}

		private function OnProfileScreenHidden():void
		{
			TheVisualObject.mcProfileScreen.visible = false;

			TheGameModel.PauseGame(false);
		}

		private function ShowHideLogros():void
		{
			for (var c:int=0; c < mStatus.LOGROS.length; c++)
			{
				if (mStatus.IsLogroAchieved(mStatus.LOGROS[c].Name))
					TheVisualObject.mcProfileScreen["mc"+mStatus.LOGROS[c].Name].visible = true;
				else
					TheVisualObject.mcProfileScreen["mc"+mStatus.LOGROS[c].Name].visible = false;
			}
		}

		private function ShowCurrentCheckpoint() : void
		{
			var checkPointIdx : int = Checkpoints.GetIndexOf(mStatus.Checkpoint);
			TheVisualObject.mcProfileScreen.mcCheckpoints.gotoAndStop(checkPointIdx+1);
		}

		private var mCharacter : Character;
		private var mWindowsPhone : WindowsPhone;
		private var mStatus : GameStatus;
	}
}
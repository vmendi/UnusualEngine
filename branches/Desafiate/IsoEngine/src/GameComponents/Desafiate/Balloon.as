package GameComponents.Desafiate
{
	import GameComponents.GameComponent;

	import Model.UpdateEvent;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.Timer;

	import mx.core.Application;

	public class Balloon extends GameComponent
	{
		override public function OnPreStart():void
		{
			mTextField = TheVisualObject.mcText;
			mTextFieldOutline = TheVisualObject.mcTextOutline;
			mTextField.text = "";
			mTextFieldOutline.text = "";
			mTimer = new Timer(1000);
			mTimer.addEventListener(TimerEvent.TIMER, OnTimer);
			mDefaultDisplacement = new Point(0,0);
			mStatus = TheGameModel.FindGameComponentByShortName("GameStatus") as GameStatus;
		}

		override public function OnStart():void
		{
			TheVisualObject.addEventListener(MouseEvent.CLICK, OnMouseClick);
			TheVisualObject.visible = false;
		}

		override public function OnPause():void
		{
			if (mTimer.running)
				mTimer.stop();
		}
		override public function OnResume():void
		{
			if (TheVisualObject.visible)
				mTimer.start();
		}

		override public function OnStop():void
		{
			TheVisualObject.removeEventListener(MouseEvent.CLICK, OnMouseClick);
		}

		private function OnMouseClick(e:Event):void
		{
			// Pasamos al siguiente texto dentro del dialogo
			if (mTimer.running && mClickAdvancesDialog)
				OnTimer(null);
		}

		public function FollowObject(obj : MovieClip):void
		{
			mFollowing = obj;
		}

		public function SetText(text : String):void
		{
			StopDialog();
			InnerSetText(text);
		}

		private function InnerSetText(text : String) : void
		{
			text = ReplaceTokens(text);
			TheVisualObject.visible = true;
			mTextField.height = 500;
			mTextFieldOutline.height = 500;
			mTextField.text = text;
			mTextFieldOutline.text = text;

			TheVisualObject.mcSound.gotoAndPlay("play");
		
			// Forzamos el recalculo de posicion
			OnUpdate(null);
		}

		private function ReplaceTokens(text : String):String
		{
			return text.replace("%NOMBRE%", Application. application.parameters.first_name)
					   .replace("%APELLIDO%", Application.application.parameters.last_name);
		}

		public function SetBalloon(width : Number, displacement : Point):void
		{
			mTextField.width = width;
			mTextFieldOutline.width = width;
			mDefaultDisplacement = displacement;
		}

		public function SetColor(color : uint):void
		{
			mTextField.textColor = color;
		}

		public function SetSpeech(texts : Array, action : Function, clickAdvancesDialog : Boolean = true):void
		{
			StopDialog();

			mDialogLines = texts;
			mDialogCounter = 0;
			mFinalFunction = action;
			mClickAdvancesDialog = clickAdvancesDialog;

			InnerSetText(mDialogLines[0]);

			mTimer.reset();
			mTimer.repeatCount = mDialogLines.length/2;
			mTimer.delay = mDialogLines[1];
			mTimer.start();
		}

		private function OnTimer(e:TimerEvent):void
		{
			mDialogCounter++;

			if (mDialogCounter < mDialogLines.length/2)
			{
				mTimer.delay = mDialogLines[(mDialogCounter*2)+1];
				InnerSetText(mDialogLines[mDialogCounter*2]);
			}
			else
			{
				StopDialog();
			}
		}

		public function StopDialog() : void
		{
			if (mTimer.running)
			{
				TheVisualObject.visible = false;
				mTimer.stop();
				if (mFinalFunction != null)
					mFinalFunction();
			}
		}

		override public function OnUpdate(event:UpdateEvent):void
		{
			if (mFollowing != null)
			{
				//CalculateDisplacement();

				mDisplacement = mDefaultDisplacement;

				var gl : Point = mFollowing.localToGlobal(mDisplacement);
				var lo : Point = TheVisualObject.parent.globalToLocal(gl);

				TheVisualObject.x = lo.x;
				TheVisualObject.y = lo.y;
			}
		}

		private function CalculateDisplacement():void
		{
			var globalPos : Point = mFollowing.localToGlobal(new Point(0,0));

			if (mFollowing.x < 100)
				mDisplacement.x = 40 + mDefaultDisplacement.x;
			else
				mDisplacement.x = -(mTextField.textWidth+40) + mDefaultDisplacement.x;

			if (globalPos.y < 100)
				mDisplacement.y = -30 + mDefaultDisplacement.y;
			else
				mDisplacement.y = -120 + mDefaultDisplacement.y;
		}

		private var mDisplacement : Point = new Point(0,0);

		private var mText : String = "";
		private var mTextField : TextField = null;
		private var mTextFieldOutline : TextField = null;
		private var mFollowing : MovieClip;
		private var mTimer : Timer;
		private var mDialogCounter : Number;
		private var mDialogLines : Array;
		private var mFinalFunction : Function;
		private var mDefaultDisplacement : Point;
		private var mClickAdvancesDialog : Boolean = true;
		private var mStatus : GameStatus;
	}
}
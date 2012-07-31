package GameComponents.Desafiate
{
	import GameComponents.GameComponent;
	import GameComponents.Interaction;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import utils.Delegate;
	import utils.MovieClipListener;
	import utils.MovieClipMouseDisabler;

	public class TimeManagementNPC extends GameComponent
	{
		override public function OnPreStart():void
		{
			mBalloon = TheGameModel.CreateSceneObjectFromMovieClip("mcBalloon", "Balloon") as Balloon;
		}

		override public function OnStart():void
		{
			mStatus = TheGameModel.FindGameComponentByShortName("GameStatus") as GameStatus;
			mTimeManagementMaster = TheGameModel.FindGameComponentByShortName("TimeManagementMaster") as TimeManagementMaster;

			mBalloon.SetColor(0xdbdeea);
			mBalloon.SetBalloon(250, new Point(-270, -110));
			mBalloon.FollowObject(TheVisualObject);
			mBalloon.TheVisualObject.visible = false;

			TheVisualObject.gotoAndStop("idle");
		}

		private function OnTaskReached():void
		{
			MovieClipListener.AddFrameScript(TheVisualObject, TheVisualObject.currentLabel, null);

			TheVisualObject.mcIconoTM.btTask.addEventListener(MouseEvent.CLICK, OnIconClick);
			MovieClipMouseDisabler.DisableMouse(TheVisualObject.mcIconoTM, true);
			TheVisualObject.mcIconoTM.btTask.mouseEnabled = true;
		}

		private function OnIconClick(e:Event):void
		{
			(TheAssetObject.FindGameComponentByShortName("Interaction") as Interaction).EmulateMouseClick();
			e.stopPropagation();
		}

		public function ShowExclamation(bShow : Boolean) : void
		{
			if (bShow && TheVisualObject.currentLabel == "task")
				throw "Se está intentando ejecutar otra tarea tipo tool";

			if (bShow)
			{
				MovieClipListener.AddFrameScript(TheVisualObject, "task", OnTaskReached);
				TheVisualObject.gotoAndStop("task");
			}
			else
				TheVisualObject.gotoAndStop("idle");
		}

		public function ShowExclamationResult(resultado : String):void
		{
			// Si estamos en la primera parte de la tarea y fallamos, mostramos el resultado en el jefe, no en la tarea
			if (TheVisualObject.currentLabel == "task")
				TheVisualObject.mcResultado.gotoAndPlay(resultado);
		}

		public function SetPercentTime(percent : Number) : void
		{
			if (TheVisualObject.mcTime != null)
				TheVisualObject.mcTime.gotoAndStop(percent);
		}

		public function Talk(speech : Array, callback : Function) : void
		{
			TheVisualObject.gotoAndPlay("talk");
			mBalloon.SetSpeech(speech, Delegate.create(OnTalkEnd, callback));
		}

		public function SetBalloon(width : Number, coords : Point) : void
		{
			mBalloon.SetBalloon(width, coords);
		}

		private function OnTalkEnd(callback : Function) : void
		{
			TheVisualObject.gotoAndStop("idle");

			if (callback != null)
				callback();
		}

		private var mStatus : GameStatus;
		private var mBalloon : Balloon;
		private var mTimeManagementMaster : TimeManagementMaster;
	}
}
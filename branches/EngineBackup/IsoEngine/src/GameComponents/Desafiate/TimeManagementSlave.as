package GameComponents.Desafiate
{
	import GameComponents.GameComponent;
	import GameComponents.Interaction;

	import Model.SceneObject;
	import Model.UpdateEvent;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;

	import utils.MovieClipListener;
	import utils.MovieClipMouseDisabler;

	public class TimeManagementSlave extends GameComponent
	{
		override public function OnStart() : void
		{
			mCharacter = TheGameModel.FindGameComponentByShortName("DesafiateCharacter") as DesafiateCharacter;
			mShelf = TheGameModel.FindGameComponentByShortName("TimeManagementShelf") as TimeManagementShelf;
			mSecondaryChar = TheGameModel.FindGameComponentByShortName("TimeManagementNPC") as TimeManagementNPC;
		}

		public function TimeManagementStart():void
		{
		}

		private function OnTMFrame():void
		{
			// Nos removemos
			MovieClipListener.AddFrameScript(TheVisualObject, "tm", null);

			mIcon = TheVisualObject.mcIconoTM;

			mIcon.btTask.addEventListener(MouseEvent.CLICK, OnIconClick);
			MovieClipMouseDisabler.DisableMouse(mIcon, true);
			mIcon.btTask.mouseEnabled = true;

			MovieClipListener.AddFrameScript(mIcon.mcResultado, "success_end", EndIconoResultadoAnim);
			MovieClipListener.AddFrameScript(mIcon.mcResultado, "fail_end", EndIconoResultadoAnim);

			StartTask();
		}

		private function OnIconClick(e:Event):void
		{
			(TheAssetObject.FindGameComponentByShortName("Interaction") as Interaction).EmulateMouseClick();
			e.stopPropagation();
		}

		public function SetTask(whichOne : String, firstWaitTime : int, secondWaitTime : int, thirdWaitTime:int, points:int, message:String) : void
		{
			if (mState != "NONE")
				throw "Accion comenzada cuando no se habia acabado la anterior";

			mCurrentTime = 0;
			mTimeToWait = firstWaitTime;
			mSecondWaitTime = secondWaitTime;
			mThirdWaitTime = thirdWaitTime;
			mCurrentTask = whichOne;
			mBasePoints = points;
			mRemainingTimePoints = 0;
			mMessage = message;

			if (TheVisualObject.mcIconoTM != null)
				StartTask();
			else
			{
				MovieClipListener.AddFrameScript(TheVisualObject, "tm", OnTMFrame);
				TheVisualObject.gotoAndStop("tm");
			}
		}

		private function StartTask() : void
		{
			if (mCurrentTask != "tool")
			{
				mIcon.gotoAndStop(mCurrentTask);
				mIcon.visible = true;
			}
			else
			{
				mIcon.visible = false;
				mSecondaryChar.ShowExclamation(true);
			}

			mState = "FIRST_WAIT";
		}

		public function OnCharacterInteraction(target : SceneObject) : void
		{
			if (mCurrentTask == "disk")
			{
				if (target == TheSceneObject)
				{
					// Llevo el disko?
					if (mCharacter.GrabbedObject == "disk")
					{
						TaskSuccess();
					}
					else if(mState != "SECOND_WAIT")
					{
						mShelf.AvailableObject = "disk";
						StartSecondWait();
					}
				}
				else
				if (target == mShelf.TheSceneObject)
				{
					// Le ponemos el disko al caracter, se lo quitamos al mueble
					mShelf.AvailableObject = null;
					mCharacter.GrabbedObject = "disk";
				}
			}
			else
			if (mCurrentTask == "tool")
			{
				if (target == mSecondaryChar.TheSceneObject && mState == "FIRST_WAIT")
				{
					mSecondaryChar.ShowExclamation(false);

					mIcon.visible = true;
					mIcon.gotoAndStop("tool");
					StartSecondWait();
				}
				else if (target == TheSceneObject && mState == "SECOND_WAIT")
				{
					StartThirdWait();
				}
			}
			else
			if (mCurrentTask == "bug")
			{
				if (target == TheSceneObject)
				{
					mRemainingTimePoints = mTimeToWait - mCurrentTime;
					TaskSuccess();
				}
			}
		}

		private function StartSecondWait():void
		{
			mRemainingTimePoints = mTimeToWait - mCurrentTime;
			mCurrentTime = 0;
			mState = "SECOND_WAIT";
			mTimeToWait = mSecondWaitTime;
		}

		private function StartThirdWait():void
		{
			mRemainingTimePoints += mTimeToWait - mCurrentTime;
			mCurrentTime = 0;
			mState = "THIRD_WAIT";
			mTimeToWait = mThirdWaitTime;
			mIcon.mcTime.gotoAndStop(101);

			TheGameModel.FindGameComponentByShortName("Character").MouseControlled = false;

			if (mCurrentTask == "tool")
			{
				var pos :String = "repair" + TheAssetObject.FindGameComponentByShortName("Interaction").FinalOrientation;
				TheGameModel.FindGameComponentByShortName("Character").TheVisualObject.gotoAndStop(pos);
			}
		}

		override public function OnUpdate(event:UpdateEvent):void
		{
			if (mState == "NONE")
				return;

			mCurrentTime += event.ElapsedTime;
			var percentTime : Number = mCurrentTime / mTimeToWait;
			if (percentTime >= 1)
			{
				if (mState != "THIRD_WAIT")
					TaskFailed();
				else
				{
					TheGameModel.FindGameComponentByShortName("Character").MouseControlled = true;
					var pos :String = "idle" + TheAssetObject.FindGameComponentByShortName("Interaction").FinalOrientation;
					TheGameModel.FindGameComponentByShortName("Character").TheVisualObject.gotoAndStop(pos);
					TaskSuccess();
				}
			}
			else
			{
				if (mState == "FIRST_WAIT")
				{
					if (mCurrentTask == "tool")
						mSecondaryChar.SetPercentTime(Math.floor((percentTime*100)+1));
					else
						mIcon.mcTime.gotoAndStop(Math.floor((percentTime*100)+1));
				}
				else
				if (mState == "SECOND_WAIT")
				{
					mIcon.mcTime.gotoAndStop(Math.floor((percentTime*100)+1));
				}
				else
				if (mState == "THIRD_WAIT")
				{
					mIcon.mcCompletado.gotoAndStop(Math.floor((percentTime*100)+1));
				}
			}
		}

		private function TaskSuccess():void
		{
			EndCurrentTask("success");
			TheGameModel.BroadcastMessage("OnTaskSuccess", {Slave:this, Points:GetTotalScore()});
		}

		private function GetTotalScore():int { return mBasePoints + Math.round(mRemainingTimePoints/10); }

		private function TaskFailed() : void
		{
			EndCurrentTask("fail");
			TheGameModel.BroadcastMessage("OnTaskFailed", this);
		}

		public function TimeManagementStop() : void
		{
			EndCurrentTask("fail");
		}

		private function EndCurrentTask(resultado : String):void
		{
			if (resultado == "success")
			{
				mIcon.mcPuntosAnim.mcPuntos.ctOutline.text = GetTotalScore();
				mIcon.mcPuntosAnim.mcPuntos.ctBase.text = GetTotalScore();
				mIcon.mcPuntosAnim.gotoAndPlay("anim");
				if (mMessage != null)
					mCharacter.Talk([mMessage,2000],null);
			}

			if (mCurrentTask == "disk")
			{
				mShelf.AvailableObject = null;
				mCharacter.GrabbedObject = null;
			}
			else
			if (mCurrentTask == "tool")
			{
				mSecondaryChar.ShowExclamationResult(resultado);
				mSecondaryChar.ShowExclamation(false);
				mIcon.mcCompletado.gotoAndStop(1);
			}

			if (mState != "NONE")
			{
				mCurrentTask = "";
				mState = "NONE";
				mIcon.mcResultado.gotoAndPlay(resultado);
			}
		}

		private function EndIconoResultadoAnim():void
		{
			mIcon.mcResultado.gotoAndStop("empty");
			mIcon.visible = false;
		}

		private var mCurrentTask : String = "";
		private var mTimeToWait : int = 0;
		private var mSecondWaitTime : int = 0;
		private var mThirdWaitTime : int = 0;
		private var mCurrentTime : int = 0;
		private var mState : String = "NONE";
		private var mBasePoints : int = 0;
		private var mRemainingTimePoints : int = 0;
		private var mMessage : String;

		private var mIcon : MovieClip;
		private var mCharacter : DesafiateCharacter;
		private var mShelf : TimeManagementShelf;
		private var mSecondaryChar : TimeManagementNPC;
	}
}
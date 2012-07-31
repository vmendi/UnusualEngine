package GameComponents.Desafiate
{
	import GameComponents.Character;
	import GameComponents.GameComponent;
	import GameComponents.IsoComponent;
	
	import Model.SceneObject;
	
	import flash.geom.Point;
	
	import gs.TweenLite;
	
	import utils.Delegate;
	import utils.GenericEvent;
	import utils.MovieClipListener;
	import utils.Point3;

	public class DesafiateBike extends GameComponent
	{
		override public function OnPreStart():void
		{
			mBalloon = TheGameModel.CreateSceneObjectFromMovieClip("mcBalloon", "Balloon") as Balloon;
			mGroundNavOK = TheGameModel.CreateSceneObjectFromMovieClip("mcGroundNavOK", "IsoComponent") as IsoComponent;
			mGroundNavOK.TheVisualObject.visible = false;

			MovieClipListener.AddFrameScript(mGroundNavOK.TheVisualObject, "end", OnGroundNavAnimEnd);
		}
		override public function OnStart():void
		{
			mStatus = TheGameModel.FindGameComponentByShortName("GameStatus") as GameStatus;

			mBalloon.FollowObject(TheVisualObject);
			mBalloon.SetBalloon(300, new Point(35,-100));
			
			
		}

		override public function OnStartComplete():void
		{
			mCharacter = TheAssetObject.FindGameComponentByShortName("Character") as Character;
			mCharacter.addEventListener("NavigationStart", OnNavigationStart);
			
			mCharacter.TheIsoComponent.WorldPos = new Point3(-10,0,-3);
			mCharacter.OrientToHeadingString("SW");
			
			Freeze();
			Hide();
			
			//Talk(["hola", 3000], null);
		}
		
		public function Hide():void
		{
			TheVisualObject.visible = false;
		}
		
		public function UnHide():void
		{
			TheVisualObject.visible = true;
		}
		
		public function Freeze():void
		{
			mCharacter.CamFollow = false;
			mCharacter.MouseControlled = false;
			mCharacter.NavigationStop();
		}
		
		public function UnFreeze():void
		{
			mCharacter.CamFollow = true;
			mCharacter.MouseControlled = true;
		}
		
		public function get WorldPos():Point3
		{
			return mCharacter.TheAssetObject.TheIsoComponent.WorldPos;
		}

		private function OnGroundNavAnimEnd():void
		{
			mGroundNavOK.TheVisualObject.visible = false;
		}

		public function OnCharacterInteraction(target:SceneObject):void
		{
			switch(target.Name)
			{
				// *** RECEPCIÓN ***		
				case "Sillon":
					switch (mStatus.Checkpoint)
					{
						case Checkpoints.INTRO:
							mBalloon.SetBalloon(250, new Point(35,-100));
							Talk(["Ahora no es el momento de descansar, quizá más tarde.",3500], null);
						break;					
						case Checkpoints.TM02_START:
							mBalloon.SetBalloon(250, new Point(35,-100));
							Talk(["Ahora no es el momento de descansar, tengo que ocuparme de los servidores.",3500], null);
						break;
						case Checkpoints.INTER02:
							mBalloon.SetBalloon(250, new Point(35,-100));
							Talk(["Preferiría no sentarme, que luego pasa lo que pasa.",3000], null);
						break;
						case Checkpoints.TM03_START:
							mBalloon.SetBalloon(250, new Point(35,-100));
							Talk(["Ahora no es el momento de descansar, hay una urgencia en la sala de reuniones.",3500], null);
						break;
					}
				break;
			}
		}

		public function Talk(speech : Array, callback : Function):void
		{
			mCallBack = callback;
			mSpeech = speech;
			TalkLoop(0);
		}
		
		public function SetBalloon(width : Number, displacement: Point):void
		{
			mBalloon.SetBalloon(width, displacement);
		}

		private function TalkLoop(step : Number):void
		{
			switch (step)
			{
				case 0:
					//TheVisualObject.mcRecepcionista.gotoAndPlay("talk_loop");
					mBalloon.SetSpeech(mSpeech, Delegate.create(TalkLoop, 1));
				break;
				case 1:
					//TheVisualObject.mcRecepcionista.gotoAndPlay("talk_end");
					if (mCallBack != null)
						mCallBack();
				break;
			}
		}

		private function OnNavigationStart(e:GenericEvent):void
		{
			mBalloon.StopDialog();

			mGroundNavOK.TheVisualObject.visible = true;
			mGroundNavOK.TheVisualObject.gotoAndPlay("start");

			//mGroundNavOK.WorldPos = GameModel.GetSnappedWorldPos(e.Data as Point3);
			mGroundNavOK.WorldPos = e.Data as Point3;
		}

		private function OnDream():void
		{
			mCharacter.MouseControlled = false;
			TheGameModel.FindGameComponentByShortName("MiniGameManager").PlayMiniGame("SuenoDelGeek", OnDreamEnd);
		}

		private function OnDreamEnd(score : Number):void
		{
			mCouch.TheVisualObject.gotoAndStop("seat");
			if (score == -1)
			{
				Talk(["¡Ufff! Menudo sueño. Espero que nadie me haya visto quedarme dormido.", 3000], UnFreezeCharacter);
			}
			else if (score == 0)
			{
				Talk(["¡Ufff! Menudo sueño. Espero que nadie me haya visto quedarme dormido.", 3000], UnFreezeCharacter);
			}
			else
			{
				Talk(["¡Ufff! Menudo sueño. Espero que nadie me haya visto quedarme dormido.", 3000, "Al menos he ganado " + score +  " puntos geek.", 3000], ShowLogro);
			}
		}
		
		private function ShowLogro():void
		{	
			mStatus.AddLogro("Empollon");
			TweenLite.delayedCall(5, UnFreezeCharacter);
		}
				
		private function UnFreezeCharacter():void
		{
			mCharacter.MouseControlled = true;
		}

		[NonSerializable]
		public function set GrabbedObject(objectName : String):void
		{
			if (objectName != null)
			{
				TheVisualObject.mcIconoTM.visible = true;
				TheVisualObject.mcIconoTM.gotoAndStop(objectName);
			}
			else
				TheVisualObject.mcIconoTM.visible = false;
		}
		public function get GrabbedObject() : String
		{
			return TheVisualObject.mcIconoTM.visible? TheVisualObject.mcIconoTM.currentLabel : null;
		}


		private var mCharacter : Character;
		private var mBalloon : Balloon;
		private var mSeated : Boolean = false;
		private var mStatus : GameStatus;
		private var mMainFase : GameComponent;
		private var mCouch : SceneObject;
		private var mCallBack : Function;
		private var mSpeech : Array;
		private var mGroundNavOK : IsoComponent;
	}
}
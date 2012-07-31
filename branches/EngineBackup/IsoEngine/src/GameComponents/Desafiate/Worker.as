package GameComponents.Desafiate
{
	import GameComponents.Character;
	import GameComponents.GameComponent;
	
	import Model.SceneObject;
	
	import flash.geom.Point;
	
	import gs.TweenLite;
	
	import utils.Delegate;

	public class Worker extends GameComponent
	{
		public var BalloonX : Number = 0;
		public var BalloonY : Number = 0;
		
		override public function OnPreStart():void
		{
			mBalloon = TheGameModel.CreateSceneObjectFromMovieClip("mcBalloon", "Balloon") as Balloon;
		}

		override public function OnStart():void
		{
			mStatus = TheGameModel.FindGameComponentByShortName("GameStatus") as GameStatus;
			mMainSalaTrabajo = TheGameModel.FindGameComponentByShortName("MainSalaTrabajo") as MainSalaTrabajo;

			mBalloon.SetColor(0xdbdeea);
			mBalloon.SetBalloon(250, new Point(BalloonX, BalloonY));
			mBalloon.FollowObject(TheVisualObject);
			mBalloon.TheVisualObject.visible = false;
		}
		
		override public function OnStartComplete():void
		{
			mCharacter = TheGameModel.FindGameComponentByShortName("Character") as Character;
			if (mStatus.Checkpoint == Checkpoints.END)
			{
				TheVisualObject.gotoAndStop("empty");
				TheVisualObject.InteractiveArea.visible = false;
			}
		}
		
		public function Talk(speech : Array, callback : Function) : void
		{
			mBalloon.SetSpeech(speech, Delegate.create(OnTalkEnd, callback));
		}
		
		private function OnTalkEnd(callback : Function):void
		{
			if (callback != null)
				callback();
		}
		
		public function OnCharacterInteraction(target:SceneObject):void
		{
			if (target != TheSceneObject)
				return;
				
			switch (mStatus.Checkpoint)
			{
				case Checkpoints.TM01_START:
					if (!mMainSalaTrabajo.PlayingTM)
						Talk(["Hola, tu debes ser el nuevo. Me encantaría hablar contigo, pero ahora no tengo tiempo.",3500], null);
				break;
				case Checkpoints.INTER01:
					if (mMainSalaTrabajo.PlayingTM)
						return;
						
					if (TheAssetObject.TheDefaultGameComponent.Name == "LostPassword")
					{
						if (TheGameModel.FindGameComponentByShortName("MiniGameManager").GetScoreForMiniGame("GuessPassword") > 0)
						{
							Talk(["Me salvaste la vida recuperando mi password. Realmente eres tan bueno como dicen.", 3000], null);
						}
						else
						{
							mCharacter.MouseControlled = false;
							Talk(["Ya era hora de que llegaras, no puedo entrar en mi ordenador.", 3000], Delegate.create(LaunchGuessPasswordGame));
						}
					}
					else
					{
						var workerMessages : Array= [["Con el Windows 7 este que nos has puesto funciona mucho mejor los programas antiguos ¡gracias!",3500],
											["Desde que nos pusiste Windows 7 no he vuelto a tener virus ni cosas así.",3000],
											["Parece magia, la batería de mi portátil dura mucho más que antes ¿sólo por haber puesto Windows 7?",3500],
											["Windows 7 está muy bien; puedo trabajar desde cualquier sitio mucho más cómodamente que antes sin tener que usar una VPN.",3500],
											["Eres un Crack, ahora si que va bien el ordenador.",2000],
											["¿Me habéis cambiado el ordenador? Desde que habéis puesto Windows 7 va mucho más deprisa.",3000],
											["Tenías razón, con Windows 7 y BitLocker no he vuelto a perder ni un solo dato.",3000],
											["Desde que has puesto Windows 7 han dejado de salir unas ventanitas raras que salían antes.",3000],
											["¿Adriana? Si, por aquí hay una Adriana, pero no recuerdo donde se sienta exactamente. Tendrás que buscarla.",3000],
											["¿Adriana? Si, por aquí hay una Adriana, pero no recuerdo donde se sienta exactamente. Tendrás que buscarla.",3000],
											["¿Adriana? Si, por aquí hay una Adriana, pero no recuerdo donde se sienta exactamente. Tendrás que buscarla.",3000]
										   ];
						var idxToMsg : Number = Math.floor(Math.random()*workerMessages.length); 
						Talk(workerMessages[idxToMsg], null);
						
						if (idxToMsg == 0)
							AtlasManager.CallToUrl("http://clk.atdmt.com/MSA/go/236033931/direct/01/");
						else if (idxToMsg == 1)
							AtlasManager.CallToUrl("http://clk.atdmt.com/MSA/go/236033932/direct/01/");
						else if (idxToMsg == 2)
							AtlasManager.CallToUrl("http://clk.atdmt.com/MSA/go/236033933/direct/01/");
						else if (idxToMsg == 3)
							AtlasManager.CallToUrl("http://clk.atdmt.com/MSA/go/236033934/direct/01/");
						else if (idxToMsg == 5)
							AtlasManager.CallToUrl("http://clk.atdmt.com/MSA/go/236033935/direct/01/");
						else if (idxToMsg == 6)
							AtlasManager.CallToUrl("http://clk.atdmt.com/MSA/go/236033936/direct/01/");
						else if (idxToMsg == 7)
							AtlasManager.CallToUrl("http://clk.atdmt.com/MSA/go/236033937/direct/01/");
						
					}
				break;
				case Checkpoints.TM02_START:
					Talk(["¿No te has enterado? Hay un lío increíble con los servidores. Deberías ocuparte de ello.",3000], null);
				break;
				case Checkpoints.INTER02:
					var workerMessages2 : Array= [["Con el Windows 7 este que nos has puesto funciona mucho mejor los programas antiguos ¡gracias!",3500],
										["Desde que nos pusiste Windows 7 no he vuelto a tener virus ni cosas así.",3000],
										["Parece magia, la batería de mi portátil dura mucho más que antes ¿sólo por haber puesto Windows 7?",3500],
										["Windows 7 está muy bien; puedo trabajar desde cualquier sitio mucho más cómodamente que antes sin tener que usar una VPN.",3500],
										["Eres un Crack, ahora si que va bien el ordenador.",2000],
										["¿Me habéis cambiado el ordenador? Desde que habéis puesto Windows 7 va mucho más deprisa.",3000],
										["Tenías razón, con Windows 7 y BitLocker no he vuelto a perder ni un solo dato.",3000],
										["Desde que has puesto Windows 7 han dejado de salir unas ventanitas raras que salían antes.",3000]
									   ];
					var idxToMsg2 : Number = Math.floor(Math.random()*workerMessages2.length);
					Talk(workerMessages2[idxToMsg2], null);
					
					if (idxToMsg2 == 0)
						AtlasManager.CallToUrl("http://clk.atdmt.com/MSA/go/236033931/direct/01/");
					else if (idxToMsg2 == 1)
						AtlasManager.CallToUrl("http://clk.atdmt.com/MSA/go/236033932/direct/01/");
					else if (idxToMsg2 == 2)
						AtlasManager.CallToUrl("http://clk.atdmt.com/MSA/go/236033933/direct/01/");
					else if (idxToMsg2 == 3)
						AtlasManager.CallToUrl("http://clk.atdmt.com/MSA/go/236033934/direct/01/");
					else if (idxToMsg2 == 5)
						AtlasManager.CallToUrl("http://clk.atdmt.com/MSA/go/236033935/direct/01/");
					else if (idxToMsg2 == 6)
						AtlasManager.CallToUrl("http://clk.atdmt.com/MSA/go/236033936/direct/01/");
					else if (idxToMsg2 == 7)
						AtlasManager.CallToUrl("http://clk.atdmt.com/MSA/go/236033937/direct/01/");

				break;
				case Checkpoints.TM03_START:
					Talk(["¿No te has enterado? Te requieren urgentemente en la sala de reuniones.",3000], null);
				break;				
			}
		}
		
		private function LaunchGuessPasswordGame():void
		{
			TheGameModel.FindGameComponentByShortName("MiniGameManager").PlayMiniGame("GuessPassword", OnGuessPasswordEnd);
		}
		
		private function OnGuessPasswordEnd(score : Number):void
		{
			if (score == -1)
			{
				Talk(["¿Y tu eres el gurú?. Seguiré intentándolo por mi cuenta.", 3000, "Como me llamo ADRIANA que lo conseguiré", 2500], UnFreezeCharacter);
			}
			else
			{
				Talk(["¡Perfecto, muchas gracias! Acabas de ganar 1000 Puntos Geek.", 3000], ShowLogro);
			}
		}
		
		private function ShowLogro():void
		{	
			mStatus.AddLogro("Hacker");
			TweenLite.delayedCall(5, UnFreezeCharacter);
		}
		
		private function UnFreezeCharacter():void
		{
			mCharacter.MouseControlled = true;	
		}
		
		private var mStatus : GameStatus;
		private var mBalloon : Balloon;
		private var mMainSalaTrabajo : MainSalaTrabajo;
		private var mCharacter : Character;
	}
}
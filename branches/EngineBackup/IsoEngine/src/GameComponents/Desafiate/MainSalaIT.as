package GameComponents.Desafiate
{
	import GameComponents.Bso;
	import GameComponents.Character;
	import GameComponents.GameComponent;
	
	import Model.SceneObject;
	
	import flash.geom.Point;
	
	import gs.TweenLite;
	
	import utils.Delegate;
	import utils.Point3;

	/**
	 * Componente ...
	 */
	public final class MainSalaIT extends GameComponent
	{

		override public function OnStartComplete():void
		{
			mInterface = TheGameModel.FindGameComponentByShortName("DesafiateInterface") as DesafiateInterface;
			mStatus = TheGameModel.FindGameComponentByShortName("GameStatus") as GameStatus;
			mWindowsPhone = TheGameModel.FindGameComponentByShortName("WindowsPhone") as WindowsPhone;
			mCharacter = TheGameModel.FindGameComponentByShortName("Character") as Character;
			mDesafiateCharacter = TheGameModel.FindGameComponentByShortName("DesafiateCharacter") as DesafiateCharacter;
			mJefeIT = TheGameModel.FindGameComponentByShortName("JefeIT") as JefeIT;
			mJefazoIT = TheGameModel.FindGameComponentByShortName("JefazoIT") as JefazoIT;
			mMesaOrdenador = TheGameModel.FindGameComponentByShortName("TimeManagementNPC") as TimeManagementNPC;
			mTimeManagement = TheGameModel.FindGameComponentByShortName("TimeManagementMaster") as TimeManagementMaster;
			mPuertaAscensor = TheGameModel.FindGameComponentByShortName("PuertaAscensor") as PuertaAscensor;

			InitMapa();
		}

		override public function OnStop():void
		{
			TweenLite.killDelayedCallsTo(OnQuizLoaded);
		}

		private function InitMapa():void
		{
			var characterPos : Point3 = new Point3(-3.5,0,5);
			mCharacter.TheAssetObject.TheIsoComponent.WorldPos = characterPos;
			mCharacter.OrientToHeadingString("SE");
			mPuertaAscensor.TheVisualObject.gotoAndPlay("close");
			
			(TheGameModel.FindGameComponentByShortName("Bso") as Bso).CrossFadeTo("Assets/Desafiate/Music/General.mp3");

			switch (mStatus.Checkpoint)
			{
				case Checkpoints.INTRO:
					mInterface.ShowPhone(false, true);
					// Los mensajes por defecto en el phone, los dejamos ahi para q sean los que hay cuando el JefeIT nos da el phone
					TheGameModel.FindGameComponentByShortName("WindowsPhone").EnableMessage(Checkpoints.INTRO, 0, false);
					TheGameModel.FindGameComponentByShortName("WindowsPhone").EnableMessage(Checkpoints.INTRO, 1, false);					
					var lines : Array = ["Bonito lugar",1500,
										 "Ese debe ser el responsable de IT", 3000,
										 "Será mejor que hable con él",3000];
					mDesafiateCharacter.Talk(lines, null);
				break;
				case Checkpoints.TM02_START:
					mDesafiateCharacter.Talk(["¡Uff! Ahí está el jefe, debe ser algo serio.",2500], null);
				break;
				case Checkpoints.INTER02:
				case Checkpoints.TM03_START:
					TheGameModel.FindSceneObjectByName("Rack01").TheVisualObject.visible = false;
					TheGameModel.FindSceneObjectByName("Rack02").TheVisualObject.visible = false;
				break;
			}
			
		}

		public function OnCharacterInteraction(target:SceneObject):void
		{
			if (target.Name == "JefeIT" && mStatus.Checkpoint == Checkpoints.INTRO)
			{
				SecuenciaTest(0);
			}
			else
			if (target.Name == "JefazoIT" && mStatus.Checkpoint == Checkpoints.TM02_START && !mTimeManagementStarted)
			{
				mCharacter.MouseControlled = false;
				mJefazoIT.SetBalloon(300, new Point(-325, -175));
				mJefazoIT.Talk(["¿Porqué ha tardado tanto? No me gusta que me hagan esperar. Hablaremos de eso luego.",3500,
								"Como sabe, el negocio de nuestra empresa depende del centro de datos.",3000,
								"Así que todos esos servidores están para dar servicio a nuestros clientes.", 3000,
								"El problema es que ahora tenemos un pico en la demanda y los servidores no dan a basto.",3500,
								"Necesitamos que se ocupe de ello inmediatamente ¡no podemos dejar de dar servicio!", 3500,
								"Nuestro futuro está en sus manos. Confiamos en usted.", 2500,
								"¿Está preparado para comenzar?", 2500],
									Delegate.create(SecuenciaTimeManagement,0));
			}
		}

		public function SecuenciaTimeManagement(step:Number):void
		{
			switch (step)
			{
				case 0:
					mPuertaAscensor.Deactivate();
					mTimeManagementStarted = true;
					mCharacter.CamFollow = false;
					mInterface.ShowPhone(false, false);
					TheGameModel.TheIsoCamera.CheckLimits = false;
					TweenLite.to(TheGameModel.TheIsoCamera, 1, {TargetPosX: 1, TargetPosY: 1, onComplete: Delegate.create(SecuenciaTimeManagement, 1)});
				break;
				case 1:
					TheGameModel.TheIsoCamera.CheckLimits = true;
					mCharacter.MouseControlled = true;
					mInterface.ShowTime(true);
					mTimeManagement.TimeManagementStart("SalaIT", true);
				break;
				case 2:
					mCharacter.MouseControlled = false;
					if (mPuntosTM > 0)
					{
						mInterface.ShowTime(false);
						mStatus.AddGeekPoints("TM02_END", mPuntosTM);
						mStatus.Checkpoint = Checkpoints.INTER02;

						(TheGameModel.FindGameComponentByShortName("MiniGameManager") as MiniGameManager).PlayIntro("Animacion03", Delegate.create(SecuenciaTimeManagement, 3), true);
						
						//smJefeComercial.SetBalloon(250, new Point(-270, -120));
						mCharacter.TheAssetObject.TheIsoComponent.WorldPos = new Point3(-5,0,-2);
						mCharacter.CamFollow = true;
						mCharacter.OrientToHeadingString("SW");
					}
					else
					{
						mJefazoIT.SetBalloon(250, new Point(50, -120));
						mJefazoIT.Talk(["Confiábamos en usted y ha fallado, pero la vida siempre da segundas oportunidades.", 3500], Delegate.create(SecuenciaTimeManagement, 4));
					}
				break;
				case 3:
					mStatus.AddLogro("Consejo");
					
					mJefazoIT.SetBalloon(300, new Point(-325, -175));
					mJefazoIT.Talk(["Ah, lo olvidaba: ha ganado " + mPuntosTM + " Puntos Geek.", 3500], Delegate.create(SecuenciaTimeManagement, 4));
				break;
				case 4:
					mTimeManagementStarted = false;
					mCharacter.CamFollow = true;
					mInterface.ShowPhone(true, false);
					mCharacter.MouseControlled = true;
					mPuertaAscensor.Activate();
				break;
			}
		}

		public function OnTimeManagementEnd(points : int) : void
		{
			mPuntosTM = points;
			SecuenciaTimeManagement(2);
		}

		private function OnQuizLoaded() : void
		{
			mCharacter.CamFollow = true;
			mCharacter.TheAssetObject.TheIsoComponent.WorldPos = new Point3(-4.5,0,-2);
			mCharacter.OrientToHeadingString("NW");
			mJefeIT.StandUp();
		}

		public function SecuenciaTest(step : Number):void
		{
			var lines : Array;
			switch (step)
			{
				case 0:
					mCharacter.MouseControlled = false;
					mDesafiateCharacter.Talk(["Hola ¿es usted el responsable técnico?",1500], Delegate.create(SecuenciaTest,1));
					mJefeIT.SeatDown();
				break;
				case 1:
					var lines1 : Array = ["Hola muchacho, tu debes ser %NOMBRE%... ¡ya era hora de que llegaras!",3000,
							 "Así que quieres unirte a nuestro equipo... no te será fácil",3000,
							 "Antes de nada tendrás que demostrar de qué estás hecho...", 3000,
							 "respondiendo estas sencillas preguntas...",3000];
					mJefeIT.Talk(lines1, Delegate.create(SecuenciaTest,2));
				break;
				case 2:
					TheGameModel.FindGameComponentByShortName("MiniGameManager").PlayMiniGame("GeekQuiz", OnGeekQuizEnd);

					mCharacter.CamFollow = false;
					TweenLite.delayedCall(10, OnQuizLoaded);
				break;
				case 3:
					SecuenciaTest(4);
				break;
				case 4:
					var resultado : String = "";
					if (mPuntosQuiz <= 300)
					{
						resultado = "Bueno, no es que seas Turing pero puede valer.";
					}
					else if (mPuntosQuiz > 300 && mPuntosQuiz <= 700)
					{
						resultado = "Muy bien, parece que sabes de esto.";
					}
					else
					{
						resultado = "¡Increíble, eres un gurú!.";
					}
					var lines2 : Array = [resultado,3000,
							 "Además estoy de buen humor ¡me voy de vacaciones!",3000,
							 "Así que ¡estás contratado! empezarás a trabajar hoy mismo.", 3000,
							 "Ah! lo olvidaba...",1000,
							 "Aquí tienes el Windows Phone de la compañía.",2500,
							 "En el recibirás todos los avisos que tendrás que atender.", 3000];
					mJefeIT.Talk(lines2, Delegate.create(SecuenciaTest,5));
				break;
				case 5:
					mJefeIT.GiveWindowsPhone(Delegate.create(SecuenciaTest,6));
				break;
				case 6:
					mWindowsPhone.Show(Delegate.create(SecuenciaTest,7));
				break;
				case 7:
					mJefeIT.Talk(["Lo dicho, a partir de ahora estás solo. ¡Atento a tu Windows Phone!",3500], Delegate.create(SecuenciaTest,8));
				break;
				case 8:
					mJefeIT.Leave(Delegate.create(SecuenciaTest, 9));
				break;
				case 9:
					var lines3 : Array = ["¡Vaya encerrona!",3000,
								"Pero al menos he conseguido el trabajo...", 3000];
					mCharacter.OrientToHeadingString("S");

					mDesafiateCharacter.Talk(lines3, Delegate.create(SecuenciaTest, 10));
				break;
				case 10:
					/*
					 * BUG, pero lo dejamos así: Si nos recargan despues del Quiz pero antes de aqui, el phone se queda con los
					 * mensajes mal
					 */
					mWindowsPhone.DisableMessage(Checkpoints.INTRO, 0);
					mWindowsPhone.DisableMessage(Checkpoints.INTRO, 1);
					mWindowsPhone.EnableAllMessagesFor(Checkpoints.TM01_START, true);
				
					// Grabamos el logro a Facebook y al servidor
					mStatus.AddLogro("Contratado");
					
					/*
					 * BUG BUG BUG
					 *
					// Hemos alcanzado el primer hito
					mStatus.Checkpoint = Checkpoints.TM01_START;
					*/
					
					// Esperamos unos segundos mientras el usuario acepta o cancela el logro
					TweenLite.delayedCall(5, Delegate.create(SecuenciaTest, 11));
				break;
				case 11:
					mCharacter.MouseControlled = true;
					mInterface.ShowPhone(true, false);
				break;				
			}
		}

		private function OnGeekQuizEnd(score:int):void
		{
			mPuntosQuiz = score;
			
			/*
			 * Cambiamos checkpoint nada mas volver del minijuego para no permitir recargas 
			 */
			mStatus.Checkpoint = Checkpoints.TM01_START;
			
			SecuenciaTest(3);			
		}

		public function get PlayingTM() : Boolean
		{
			return mTimeManagementStarted;
		}
		

		private var mCharacter : Character;
		private var mDesafiateCharacter : DesafiateCharacter;
		private var mJefeIT : JefeIT;
		private var mJefazoIT : JefazoIT;
		private var mWindowsPhone : WindowsPhone;
		private var mStatus : GameStatus;
		private var mInterface : DesafiateInterface;
		private var mTimeManagement : TimeManagementMaster;
		private var mMesaOrdenador : TimeManagementNPC;
		private var mTimeManagementStarted : Boolean = false;
		private var mPuntosTM : int;
		private var mPuntosQuiz : int = 0;
		private var mPuertaAscensor : PuertaAscensor;
	}
}





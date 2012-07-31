package GameComponents.Desafiate
{
	import GameComponents.Bso;
	import GameComponents.Character;
	import GameComponents.GameComponent;
	
	import Model.SceneObject;
	
	import gs.TweenLite;
	
	import utils.Delegate;
	import utils.Point3;

	/**
	 * Componente ...
	 */
	public final class MainConferencias extends GameComponent
	{

		override public function OnStartComplete():void
		{
			mInterface = TheGameModel.FindGameComponentByShortName("DesafiateInterface") as DesafiateInterface;
			mStatus = TheGameModel.FindGameComponentByShortName("GameStatus") as GameStatus;
			mWindowsPhone = TheGameModel.FindGameComponentByShortName("WindowsPhone") as WindowsPhone;
			mCharacter = TheGameModel.FindGameComponentByShortName("Character") as Character;
			mDesafiateCharacter = TheGameModel.FindGameComponentByShortName("DesafiateCharacter") as DesafiateCharacter;
			mTimeManagement = TheGameModel.FindGameComponentByShortName("TimeManagementMaster") as TimeManagementMaster;
			mJefazoConferencias = TheGameModel.FindGameComponentByShortName("JefazoConferencias") as JefazoConferencias;
			mPuertaAscensor = TheGameModel.FindGameComponentByShortName("PuertaAscensor") as PuertaAscensor;

			InitMapa();
		}
		
		public function OnCharacterInteraction(target : SceneObject) : void
		{
			if (target.Name == "JefazoConferencias")
			{
				if (mStatus.Checkpoint == Checkpoints.TM03_START && !mTimeManagementStarted)
				{
					mCharacter.MouseControlled = false;
					mJefazoConferencias.Talk(["Usted siempre tarde...",100,
									"Estamos ultimando la oferta de Argae Inc. Se trata de un negocio clave para nosotros.",3000,
									"Necesitamos incluir algunos datos que hay en nuestra plataforma de colaboración, pero no podemos acceder a ellos.", 3000,
									"Necesitamos que instales la plataforma en nuestros portátiles.", 3500,
									"Además, necesitamos que nos digas cómo conectar con el sistema y transferir la información.", 3500,
									"Y también nos vendría bien que nos indicaras cómo buscar los datos en el sistema.", 3500,
									"Casi no nos queda tiempo, será mejor que nos demos prisa.", 2500,
									"¿Está preparado para comenzar?", 2500],
										Delegate.create(SecuenciaTimeManagement,0));
				}
				else if (mStatus.Checkpoint != Checkpoints.TM03_START)
				{
					mJefazoConferencias.Talk(["¡Muchas gracias por ayudarnos! Con la nueva plataforma de colaboración todo es mucho más sencillo.",3000], null);
				}
			}
		}		

		private function InitMapa():void
		{
			(TheGameModel.FindGameComponentByShortName("Bso") as Bso).CrossFadeTo("Assets/Desafiate/Music/General.mp3");
			
			var characterPos : Point3 = new Point3(-4.5,0,4.5);
			mCharacter.TheAssetObject.TheIsoComponent.WorldPos = characterPos;
			mCharacter.OrientToHeadingString("SE");
			mPuertaAscensor.TheVisualObject.gotoAndPlay("close");
			
			switch (mStatus.Checkpoint)
			{
				case Checkpoints.TM03_START:
					TheGameModel.FindSceneObjectByName("Mesa").TheAssetObject.TheSceneObject.TheVisualObject.gotoAndStop("laptops");
					mDesafiateCharacter.Talk(["Están todos los ejecutivos de la compañía, debe pasar algo gordo.",3000], null);
				break;
				case Checkpoints.END:
					TheGameModel.FindSceneObjectByName("Mesa").TheAssetObject.TheSceneObject.TheVisualObject.gotoAndStop("laptops");
					mDesafiateCharacter.Talk(["Pero ¿dónde ha ido todo el mundo?.",3000], null);				
				break;
				default:
					TheGameModel.FindSceneObjectByName("Mesa").TheAssetObject.TheSceneObject.TheVisualObject.gotoAndStop("empty");
					mDesafiateCharacter.Talk(["Aquí no hay nadie todavía.",2000], null);
				break;
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
					TweenLite.to(TheGameModel.TheIsoCamera, 1, {TargetPosX: 0.5, TargetPosY: 1, onComplete: Delegate.create(SecuenciaTimeManagement, 1)});
				break;
				case 1:
					TheGameModel.TheIsoCamera.CheckLimits = true;
					mCharacter.MouseControlled = true;
					mInterface.ShowTime(true);
					mTimeManagement.TimeManagementStart("Conferencias", true);
				break;
				case 2:
					mCharacter.MouseControlled = false;
					if (mPuntosTM > 0)
					{
						mInterface.ShowTime(false);
						mStatus.AddGeekPoints("TM03_END", mPuntosTM);
						mStatus.Checkpoint = Checkpoints.END;

						(TheGameModel.FindGameComponentByShortName("MiniGameManager") as MiniGameManager).PlayIntro("Animacion04", Delegate.create(SecuenciaTimeManagement, 3), true);
						OnAnimLoaded();
					}
					else
					{
						mJefazoConferencias.Talk(["Confiábamos en usted y ha fallado, pero la vida siempre da segundas oportunidades.", 3500], Delegate.create(SecuenciaTimeManagement, 4));
					}
				break;
				case 3:
					mStatus.AddLogro("Heroe");
					
					mDesafiateCharacter.Talk(["¿Dónde ha ido todo el mundo? bueno, al menos he ganado " + mPuntosTM + " Puntos Geek.", 3500], Delegate.create(SecuenciaTimeManagement, 4));
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
		
		public function get PlayingTM() : Boolean
		{
			return mTimeManagementStarted;
		}	
		
		private function OnAnimLoaded():void
		{
			//smJefeComercial.SetBalloon(250, new Point(-270, -120));
			//mCharacter.TheAssetObject.TheIsoComponent.WorldPos = new Point3(-3.5,0,-0.5);
			mCharacter.CamFollow = true;
			mCharacter.OrientToHeadingString("SW");
			// Ocultamos a todos los ejecutivos y al jefazo
			// Ocultamos a todos los ejecutivos y al jefazo
			var ret : Array = TheGameModel.FindAllGameComponentsByShortName("Executive");
			
			for (var i:int=0; i<ret.length; i++)
			{
				ret[i].Hide();
			}
			mJefazoConferencias.Hide();
		}					

		private var mCharacter : Character;
		private var mDesafiateCharacter : DesafiateCharacter;
		private var mWindowsPhone : WindowsPhone;
		private var mStatus : GameStatus;
		private var mInterface : DesafiateInterface;
		private var mTimeManagement : TimeManagementMaster;
		//private var mMesaOrdenador : TimeManagementNPC;
		private var mTimeManagementStarted : Boolean = false;		
		private var mJefazoConferencias : JefazoConferencias;
		private var mPuntosTM : int;
		private var mPuertaAscensor : PuertaAscensor;
	}
}

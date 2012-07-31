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

	public class MainSalaTrabajo extends GameComponent
	{
		override public function OnStartComplete():void
		{
			mStatus = TheGameModel.FindGameComponentByShortName("GameStatus") as GameStatus;
			mCharacter = TheGameModel.FindGameComponentByShortName("Character") as Character;
			mDesafiateCharacter = TheGameModel.FindGameComponentByShortName("DesafiateCharacter") as DesafiateCharacter;
			mTimeManagement = TheGameModel.FindGameComponentByShortName("TimeManagementMaster") as TimeManagementMaster;
			mJefeComercial = TheGameModel.FindGameComponentByShortName("TimeManagementNPC") as TimeManagementNPC;
			mInterface = TheGameModel.FindGameComponentByShortName("DesafiateInterface") as DesafiateInterface;
			mPuertaAscensor = TheGameModel.FindGameComponentByShortName("PuertaAscensor") as PuertaAscensor;

			InitMapa();
		}

		private function InitMapa():void
		{
			(TheGameModel.FindGameComponentByShortName("Bso") as Bso).CrossFadeTo("Assets/Desafiate/Music/General.mp3");
			
			var characterPos : Point3 = new Point3(4.0, 0, 14.5);
			mCharacter.TheAssetObject.TheIsoComponent.WorldPos = characterPos;
			mCharacter.OrientToHeadingString("SE");
			mPuertaAscensor.TheVisualObject.gotoAndPlay("close");
 
			if (mStatus.Checkpoint == Checkpoints.END)
			{
				mJefeComercial.TheVisualObject.visible = false;
			}
		}

		public function OnCharacterInteraction(target : SceneObject) : void
		{
			if (target.Name == "JefeComercial")
			{
				if (mStatus.Checkpoint == Checkpoints.TM01_START && !mTimeManagementStarted)
				{
					SecuenciaTimeManagement(0);
				}
				else if (mStatus.Checkpoint == Checkpoints.INTER01 || mStatus.Checkpoint == Checkpoints.INTER02)
				{
					mJefeComercial.SetBalloon(250, new Point(-270, -120));
					mJefeComercial.Talk(["Tenías razón, gracias a Windows 7 somos mucho más productivos. ¡Buen trabajo!",3000], null);
					
					AtlasManager.CallToUrl("http://clk.atdmt.com/MSA/go/236033930/direct/01/");
				}
				else if (mStatus.Checkpoint == Checkpoints.TM02_START)
				{
					mJefeComercial.SetBalloon(250, new Point(-270, -150));
					mJefeComercial.Talk(["¿No has visto el mensaje? Tenemos un problema grave con los servidores. Ve a la sala de IT.",3000], null);
				}
				else if (mStatus.Checkpoint == Checkpoints.TM03_START)
				{
					mJefeComercial.SetBalloon(250, new Point(-270, -150));
					mJefeComercial.Talk(["¿No has visto el mensaje? Tienen un problema en la sala de reuniones. Deberías ir urgentemente.",3000], null);
				}
			}
		}

		public function SecuenciaTimeManagement(step : Number):void
		{
			switch (step)
			{
				case 0:
					mPuertaAscensor.Deactivate();
				
					mTimeManagementStarted = true;
					mInterface.ShowPhone(false, false);
					mCharacter.MouseControlled = false;
					
					mJefeComercial.Talk(["¡Ya era hora de que llegaras!", 1500,
										 "Hoy todo son problemas", 3000,
										 "¡Necesitamos que los soluciones lo antes posible o perderemos todo el día!",2500,
										 "¿Estás preparado para comenzar?",2500],
										 Delegate.create(SecuenciaTimeManagement, 1));
				break;
				case 1:
					mCharacter.CamFollow = false;
					TweenLite.to(TheGameModel.TheIsoCamera, 1, {TargetPosX:4, TargetPosY: 5.5, onComplete: Delegate.create(SecuenciaTimeManagement, 2)});			
				break;
				case 2:
  					mJefeComercial.SetBalloon(250, new Point(30, -100));
					mJefeComercial.TheVisualObject.mcIconoTMTutorial.gotoAndStop("bug");
					mJefeComercial.Talk(["Los problemas más comunes son los fallos de seguridad", 2500,
										 "este icono significa que un usuario tiene uno de estos problemas", 3500,
										 "dirígete a él para solucionarlo antes de que se acabe el tiempo", 3000,
										 "inténtalo ahora...",1500],
										 Delegate.create(SecuenciaTimeManagement, 3));
				break;
				case 3:
					mJefeComercial.TheVisualObject.mcIconoTMTutorial.gotoAndStop("empty");
					mCharacter.MouseControlled = true;
					mSecuenciaNextStep = 4;
					mDesafiateCharacter.SetBalloon(250, new Point(-100, -220)); 
					mTimeManagement.TimeManagementStart("SalaTrabajoTutorial01", false);
				break;
				case 4:
					mCharacter.MouseControlled = false;
					mJefeComercial.TheVisualObject.mcIconoTMTutorial.gotoAndStop("disk");
					mJefeComercial.Talk(["Algunos usuarios necesitan actualizar el software de sus equipos", 3500,
										 "te lo indicarán con este icono", 1500,
										 "cuando llegues te mostrará qué es lo que necesita exactamente", 3000,
										 "tendrás que recogerlo en la estantería y volver para instalarlo", 3000,
										 "pruébalo ahora...",1500],
										 Delegate.create(SecuenciaTimeManagement, 5));
				break;
				case 5:
					mJefeComercial.TheVisualObject.mcIconoTMTutorial.gotoAndStop("empty");
					mCharacter.MouseControlled = true;
					mSecuenciaNextStep = 6;
					mTimeManagement.TimeManagementStart("SalaTrabajoTutorial02", false);
				break;
				case 6:
					mCharacter.MouseControlled = false;
					mJefeComercial.TheVisualObject.mcIconoTMTutorial.gotoAndStop("admiracion");
					mJefeComercial.Talk(["Cuando veas este icono sobe mi cabeza significa que tengo un encargo para ti", 3000,
										 "alguien ha reportado un fallo en su equipo y tendrás que solucionarlo", 3000,
										 "ven a verme antes de que se acabe el tiempo y te indicaré quién es", 2500],
										 Delegate.create(SecuenciaTimeManagement, 7));
				break;
				case 7:
					mCharacter.MouseControlled = true;
					mSecuenciaNextStep = 8;
					mTimeManagement.TimeManagementStart("SalaTrabajoTutorial03", false);
				break;
				case 8:
					mInterface.SetTime(mTimeManagement.TotalSeconds*1000);
					mInterface.ShowTime(true);
					mJefeComercial.TheVisualObject.mcIconoTMTutorial.gotoAndStop("empty");
					mJefeComercial.Talk(["Como ves es fácil", 2500,
										 "¿Listo para comenzar?", 3000],
										 Delegate.create(SecuenciaTimeManagement, 9));
				break;
				case 9:
					mCharacter.MouseControlled = true;
					mSecuenciaNextStep = 10;
					mTimeManagement.TimeManagementStart("SalaTrabajoFase01", true);
				break;
				case 10:
					mCharacter.MouseControlled = false;
										
					if (mPuntosTM > 0)
					{
						mInterface.ShowTime(false);
						mStatus.AddGeekPoints("TM01_END", mPuntosTM);
						mStatus.Checkpoint = Checkpoints.INTER01;
						
						(TheGameModel.FindGameComponentByShortName("MiniGameManager") as MiniGameManager).PlayIntro("Animacion02", Delegate.create(SecuenciaTimeManagement, 11), true);
						
						mJefeComercial.SetBalloon(250, new Point(-270, -120));
						mCharacter.TheAssetObject.TheIsoComponent.WorldPos = new Point3(2.5,0,10);
						mCharacter.CamFollow = true;
						mCharacter.OrientToHeadingString("W");
					}
					else
					{
						mJefeComercial.Talk(["¿Y tú eres el nuevo de IT? Menuda decepción.", 3500], Delegate.create(SecuenciaTimeManagement, 12));
					}
				break;
				case 11:
					mStatus.AddLogro("Empleado");
				
					mJefeComercial.Talk(["Ah, lo olvidaba: has ganado " + mPuntosTM + " Puntos Geek.", 3500], Delegate.create(SecuenciaTimeManagement, 12));
				break;
				case 12:
						mTimeManagementStarted = false;
						mCharacter.CamFollow = true;
						mInterface.ShowPhone(true, false);
						mCharacter.MouseControlled = true;
						mPuertaAscensor.Activate();
				break;
			}
		}

		public function OnTaskFailed(slave : TimeManagementSlave):void
		{
			if (mSecuenciaNextStep <=8)
			{
				mJefeComercial.Talk(["Parece que no lo has pillado", 2500,
									 "será mejor que lo intentemos de nuevo", 2500],
									 Delegate.create(SecuenciaTimeManagement, mSecuenciaNextStep-2));
			} 
		}

		public function OnTaskSuccess(params : Object):void
		{
			if (mSecuenciaNextStep <=8)
			{
				mJefeComercial.Talk(["¡Muy bien!", 2500],
									 Delegate.create(SecuenciaTimeManagement, mSecuenciaNextStep));
			}
		}

		public function OnTimeManagementEnd(points : int) : void
		{
			if (mSecuenciaNextStep > 8)
			{
				mPuntosTM = points;
				SecuenciaTimeManagement(mSecuenciaNextStep);
			}
		}
		
		public function get PlayingTM() : Boolean
		{
			return mTimeManagementStarted;
		}
		

		private var mCharacter : Character;
		private var mDesafiateCharacter : DesafiateCharacter;
		private var mTimeManagement : TimeManagementMaster;
		private var mJefeComercial : TimeManagementNPC;
		private var mStatus : GameStatus;
		private var mInterface : DesafiateInterface;
		private var mTimeManagementStarted : Boolean = false;
		private var mSecuenciaNextStep : Number = 0;
		private var mPlayingTM : Boolean = false;
		private var mPuntosTM : int = 0;
		private var mPuertaAscensor : PuertaAscensor;
	}
}
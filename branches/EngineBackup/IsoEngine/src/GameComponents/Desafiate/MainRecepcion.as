package GameComponents.Desafiate
{
	import GameComponents.Character;
	import GameComponents.GameComponent;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import utils.Delegate;
	import utils.Point3;
	import GameComponents.Bso;

	/**
	 * Componente ...
	 */
	public final class MainRecepcion extends GameComponent
	{
		override public function OnStartComplete():void
		{
			mStatus = TheGameModel.FindGameComponentByShortName("GameStatus") as GameStatus;
			mInterface = TheGameModel.FindGameComponentByShortName("DesafiateInterface") as DesafiateInterface;
			mCharacter = TheGameModel.FindGameComponentByShortName("Character") as Character;
			mDesafiateCharacter = TheGameModel.FindGameComponentByShortName("DesafiateCharacter") as DesafiateCharacter;
			mRecepcionista = TheGameModel.FindGameComponentByShortName("Recepcionista") as Recepcionista;
			mPuertaAscensor = TheGameModel.FindGameComponentByShortName("PuertaAscensor") as PuertaAscensor;

			InitMapa();
		}

		private function InitMapa():void
		{			
			if (mStatus.Checkpoint == Checkpoints.INTRO)
			{
				// Durante la cutscene inicial, ocultamos el interface para que no nos cancele la navegación (por pausa)
				mInterface.ShowAll(false);
				// Como no somos ordenados con ENTER_FRAME, la camara tiene que estar bien situada a la vuelta de la pausa
				var characterPos : Point3 = new Point3(-5,0,-5.5);
				mCharacter.TheAssetObject.TheIsoComponent.WorldPos = characterPos;
				TheGameModel.TheIsoCamera.TargetPos = new Point(characterPos.x, characterPos.z);
				mCharacter.MouseControlled = false;
				(TheGameModel.FindGameComponentByShortName("MiniGameManager") as MiniGameManager).PlayIntro("Animacion01", OnIntroEnd, true);
			}
			else
			{
				(TheGameModel.FindGameComponentByShortName("Bso") as Bso).CrossFadeTo("Assets/Desafiate/Music/General.mp3");
				
				mCharacter.TheAssetObject.TheIsoComponent.WorldPos = new Point3(-3.5,0,4.5);
				mCharacter.OrientToHeadingString("SE");
				mPuertaAscensor.TheVisualObject.gotoAndPlay("close");
				if (mStatus.Checkpoint == Checkpoints.END)
				{
					mDesafiateCharacter.Talk(["¡Tambien ha desaparecido la chica de recepción!",3000], null);
				}
			}
		}
		
		private function OnIntroEnd():void
		{
			// Lanzamos la animación de la intro
			mCharacter.addEventListener("NavigationEnd", OnNavigateToRecepcionistaEnd);
			mCharacter.NavigateTo(new Point3(-0.5,0,-6.5));	
		}

		private function OnNavigateToRecepcionistaEnd(e:Event):void
		{
			mCharacter.removeEventListener("NavigationEnd", OnNavigateToRecepcionistaEnd);
			var puntoDestino : Point3 = new Point3(0,0,-6);
			mCharacter.OrientTo(puntoDestino);

			DialogoTutorial(0);
		}

		public function DialogoTutorial(step : Number):void
		{
			var lines : Array;
			switch (step)
			{
				case 0:
					lines = ["Buenos días",1500];
					mDesafiateCharacter.Talk(lines, Delegate.create(DialogoTutorial, 1));
				break;
				case 1:
					lines = ["Bienvenido a Contoso Inc ¿en qué puedo ayudarle?",3000];
					mRecepcionista.Talk(lines, Delegate.create(DialogoTutorial, 2));
				break;
				case 2:
					lines = ["Mi nombre es %NOMBRE% %APELLIDO%, tengo una cita con el responsable técnico",3000];
					mDesafiateCharacter.Talk(lines, Delegate.create(DialogoTutorial, 3));
				break;
				case 3:
					lines = ["Muy bien, le están esperando en la Sala de IT",2500,
							 "Déjeme explicarle cómo puede moverse por el juego", 3000,
							 "Simplemente haga clic sobre el lugar al que quiere dirigirse y su personaje irá hacia allí",3500,
							 "Para interactuar con personas y objetos sólo tiene que hacer clic sobre ellos",3500,
							 "Pruébelo, estas oficinas están llenas de secretos, minijuegos y personajes interesantes.", 3500,
							 "Para usar el ascensor haga clic sobre la puerta y elija la planta a la que desea ir ",3500,
							 "Que tenga un buen día. El señor González le está esperando en la Sala de IT", 3500];
					mRecepcionista.Talk(lines, Delegate.create(DialogoTutorial, 4));
				break;
				case 4:
					mCharacter.OrientTo(new Point3(-1,0,-7));
					lines = ["Será mejor que vaya a la sala de IT. No me gustaría llegar tarde a la entrevista",3500];
					mDesafiateCharacter.Talk(lines, Delegate.create(DialogoTutorial, 5));
				break;
				case 5:
					mCharacter.MouseControlled = true;
					
					// Ocultamos el phone, en la intro no esta todavia disponible
					mInterface.ShowPhone(false, true);
					
					// Y ya podemos mostrar el resto de interface...
					mInterface.ShowAll(true);
				break;
			}
		}

		private var mCharacter : Character;
		private var mDesafiateCharacter : DesafiateCharacter;
		private var mInterface : DesafiateInterface;
		private var mRecepcionista : Recepcionista;
		private var mStatus : GameStatus;
		private var mPuertaAscensor : PuertaAscensor;

	}
}

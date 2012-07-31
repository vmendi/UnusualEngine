package GameComponents.Desafiate
{
	import GameComponents.Bso;
	import GameComponents.Character;
	import GameComponents.GameComponent;
	
	import utils.Point3;

	/**
	 * Componente ...
	 */
	public final class MainDireccion extends GameComponent
	{

		override public function OnStartComplete():void
		{
			mInterface = TheGameModel.FindGameComponentByShortName("DesafiateInterface") as DesafiateInterface;
			mStatus = TheGameModel.FindGameComponentByShortName("GameStatus") as GameStatus;
			mWindowsPhone = TheGameModel.FindGameComponentByShortName("WindowsPhone") as WindowsPhone;
			mCharacter = TheGameModel.FindGameComponentByShortName("Character") as Character;
			mDesafiateCharacter = TheGameModel.FindGameComponentByShortName("DesafiateCharacter") as DesafiateCharacter;
			mPuertaAscensor = TheGameModel.FindGameComponentByShortName("PuertaAscensor") as PuertaAscensor;

			InitMapa();
		}

		private function InitMapa():void
		{
			(TheGameModel.FindGameComponentByShortName("Bso") as Bso).CrossFadeTo("Assets/Desafiate/Music/General.mp3");
			
			var characterPos : Point3 = new Point3(-3,0,3.5);
			mCharacter.TheAssetObject.TheIsoComponent.WorldPos = characterPos;
			mCharacter.OrientToHeadingString("SE");
			mPuertaAscensor.TheVisualObject.gotoAndPlay("close");
			
			switch (mStatus.Checkpoint)
			{
				case Checkpoints.INTER02:
					mDesafiateCharacter.Talk(["Gulp, ahí está el jefazo.",2000], null);
				break;
				case Checkpoints.END:
					mDesafiateCharacter.Talk(["Aquí tampoco hay nadie...",2000], null);
					TheGameModel.FindSceneObjectByName("DireccionSillon").TheAssetObject.TheSceneObject.TheVisualObject.gotoAndStop("empty");
				break;
			}
		}

		private var mCharacter : Character;
		private var mDesafiateCharacter : DesafiateCharacter;
		private var mWindowsPhone : WindowsPhone;
		private var mStatus : GameStatus;
		private var mInterface : DesafiateInterface;
		private var mPuertaAscensor: PuertaAscensor;
	}
}

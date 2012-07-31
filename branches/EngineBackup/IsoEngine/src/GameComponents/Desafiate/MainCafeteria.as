package GameComponents.Desafiate
{
	import GameComponents.Bso;
	import GameComponents.Character;
	import GameComponents.GameComponent;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import utils.Delegate;
	import utils.Point3;

	/**
	 * Componente ...
	 */
	public final class MainCafeteria extends GameComponent
	{

		override public function OnStartComplete():void
		{
			mInterface = TheGameModel.FindGameComponentByShortName("DesafiateInterface") as DesafiateInterface;
			mStatus = TheGameModel.FindGameComponentByShortName("GameStatus") as GameStatus;
			mWindowsPhone = TheGameModel.FindGameComponentByShortName("WindowsPhone") as WindowsPhone;
			mCharacter = TheGameModel.FindGameComponentByShortName("Character") as Character;
			mDesafiateCharacter = TheGameModel.FindGameComponentByShortName("DesafiateCharacter") as DesafiateCharacter;
			mJefazo = TheGameModel.FindGameComponentByShortName("JefazoCafeteria") as JefazoCafeteria;
			mPuertaAscensor = TheGameModel.FindGameComponentByShortName("PuertaAscensor") as PuertaAscensor;

			InitMapa();
		}

		private function InitMapa():void
		{
			(TheGameModel.FindGameComponentByShortName("Bso") as Bso).CrossFadeTo("Assets/Desafiate/Music/General.mp3");
			
			var characterPos : Point3 = new Point3(-3.5,0,5);
			mCharacter.TheAssetObject.TheIsoComponent.WorldPos = characterPos;
			mCharacter.OrientToHeadingString("SE");
			mPuertaAscensor.TheVisualObject.gotoAndPlay("close");
			
			if (mStatus.Checkpoint != Checkpoints.END)
			{
				var ret : Array = TheGameModel.FindAllSceneObjectsByName("Fellow");
				for (var i:int=0; i<ret.length; i++)
				{
					ret[i].TheAssetObject.TheSceneObject.TheVisualObject.visible = false;
					ret[i].TheAssetObject.TheSceneObject.TheAssetObject.TheIsoComponent.Walkable = true;
				}					
			}
			
			switch (mStatus.Checkpoint)
			{
				case Checkpoints.INTER01:
					mDesafiateCharacter.Talk(["Vaya, qué animado está esto.",2000], null);
				break;
				case Checkpoints.INTER02:
					mDesafiateCharacter.Talk(["¿Dónde estará todo el mundo?",2000], null);
				break;
				case Checkpoints.END:
					mCharacter.MouseControlled = false;
					mDesafiateCharacter.Talk(["Anda, todo el mundo está aquí reunido.",2000], Delegate.create(DialogoFinal, 0));
				break;
			}
		}

		public function DialogoFinal(step : Number):void
		{
			var lines : Array;
			switch (step)
			{
				case 0:
					mCharacter.addEventListener("NavigationEnd", OnNavigateToJefazoEnd);
					mCharacter.NavigateTo(new Point3(-2,0,-3));					
				break;
				case 1:
					mDesafiateCharacter.SetBalloon(250, new Point(-130,-100));
					lines = ["¿Jefe?",1500];
					
					mDesafiateCharacter.Talk(lines, Delegate.create(DialogoFinal, 2));
				break;
				case 2:
					lines = ["%NOMBRE% %APELLIDO%, ¡ENHORABUENA!",3000,
							 "Has llegado al final de \"Desafíate\".", 3000,
							 "A lo largo del juego has descubierto las características de los productos Microsoft..", 4000,
							 "... y has aprendido cómo pueden ayudarte en tu trabajo.", 3500,
							 "Esperamos que te hayas divertido con nosotros.", 3000,
							 "¡GRACIAS POR JUGAR!", 3000
							 ];
					mJefazo.Talk(lines, Delegate.create(DialogoFinal, 3));
				break;
				case 3:
					(TheGameModel.FindGameComponentByShortName("MiniGameManager") as MiniGameManager).PlayIntro("Credits", Delegate.create(DialogoFinal, 6), true);
				break;
				case 6:
				
				break;
				case 7:
					mCharacter.MouseControlled = true;
					
					// Ocultamos el phone, en la intro no esta todavia disponible
					mInterface.ShowPhone(false, true);
					
					// Y ya podemos mostrar el resto de interface...
					mInterface.ShowAll(true);
				break;
			}
		}
		
		private function OnNavigateToJefazoEnd(e:Event):void
		{
			mCharacter.removeEventListener("NavigationEnd", OnNavigateToJefazoEnd);
			var puntoDestino : Point3 = new Point3(0,0,-6);
			mCharacter.OrientToHeadingString("SE");

			DialogoFinal(1);
		}

		private var mCharacter : Character;
		private var mDesafiateCharacter : DesafiateCharacter;
		private var mWindowsPhone : WindowsPhone;
		private var mStatus : GameStatus;
		private var mInterface : DesafiateInterface;
		private var mJefazo : JefazoCafeteria;
		private var mPuertaAscensor : PuertaAscensor;
	}
}

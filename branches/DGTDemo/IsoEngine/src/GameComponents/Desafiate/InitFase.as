package GameComponents.Desafiate
{
	import GameComponents.Character;
	import GameComponents.GameComponent;
	
	import flash.display.Sprite;
	
	import gs.TweenLite;
	
	import utils.Delegate;

	/**
	 * Componente ...
	 */
	public final class InitFase extends GameComponent
	{

		override public function OnPreStart():void
		{
			mCharacter = TheGameModel.CreateSceneObjectFromMovieClip("AvatarChico", "Character") as Character;
			mBike = TheGameModel.CreateSceneObjectFromMovieClip("Bicicleta", "Character") as Character;
			
			TheGameModel.CreateSceneObjectFromMovieClip("mcInterface", "DesafiateInterface");
			//TheGameModel.CreateSceneObjectFromMovieClip("mcWindowsPhone", "WindowsPhone");
			//TheGameModel.CreateSceneObjectFromMovieClip("mcElevatorConsole", "ElevatorConsole");
			//TheGameModel.CreateSceneObjectFromMovieClip("mcMiniGame", "MiniGameManager");
		}

		override public function OnStartComplete():void
		{
			mDesafiateCharacter = TheGameModel.FindGameComponentByShortName("DesafiateCharacter") as DesafiateCharacter;
			mDesafiateBike = TheGameModel.FindGameComponentByShortName("DesafiateBike") as DesafiateBike;
			//mDesafiateBike.Freeze();
			
			mBlackScreen = new Sprite();
			mBlackScreen.graphics.beginFill(0);
			mBlackScreen.graphics.drawRect(0, 0, 915,508);
			mBlackScreen.graphics.endFill();

			mBlackScreen.x = -915/2;
			mBlackScreen.y = -508/2;

			TheGameModel.TheRender2DCamera.addChild(mBlackScreen);

			mCharacter.MouseControlled = false;
			TweenLite.to(mBlackScreen, 1.0, { alpha:0, onComplete: OnAlphaComplete });
		}

		override public function OnStop():void
		{
			if (mBlackScreen != null)
				TweenLite.killTweensOf(mBlackScreen);
		}
		
		public function SwitchToBike():void
		{
			//delete mCharacter;
			//mCharacter  = TheGameModel.CreateSceneObjectFromMovieClip("Bicicleta", "Character") as Character;
		}

		private function OnAlphaComplete():void
		{
			TheGameModel.TheRender2DCamera.removeChild(mBlackScreen);
			mBlackScreen = null;
			IntroStart();
		}

		private function IntroStart():void
		{
			mDesafiateCharacter.Talk(["Bienvenido a la demo de \"Traffic SIM\", el primer juego serio sobre seguridad vial.", 3000,
									  "Para controlarme, simplemente tienes que hacer clic sobre el lugar al que quieres que me dirija.",3500,
									  "El objetivo es sencillo: mi amiga Adriana me está esperando al sur de aquí y ya llego tarde.",3000,
									  "Necesito que me ayudes a encontrarla y a llegar hasta ella antes de que se acabe el tiempo.",3000,
									  "¿Estás listo?", 2000,
									  "Ah, lo olvidaba: esta demo está diseñada para mostrar la tecnología que se usará para hacer el juego.", 3500,
									  "Pero no refleja la calidad final del producto :-)", 2500], Delegate.create(DemoStart));
		}

		private function DemoStart():void
		{
			mCharacter.MouseControlled = true;
		}


		private var mBlackScreen : Sprite;
		private var mCharacter : Character;
		private var mBike : Character;
		private var mDesafiateCharacter : DesafiateCharacter;
		private var mDesafiateBike : DesafiateBike;
	}
}

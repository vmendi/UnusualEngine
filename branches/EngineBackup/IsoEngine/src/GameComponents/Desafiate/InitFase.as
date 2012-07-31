package GameComponents.Desafiate
{
	import GameComponents.GameComponent;

	import Model.UpdateEvent;

	import flash.display.Sprite;

	import gs.TweenLite;

	/**
	 * Componente ...
	 */
	public final class InitFase extends GameComponent
	{

		override public function OnPreStart():void
		{
			TheGameModel.CreateSceneObjectFromMovieClip("AvatarChico", "Character");
			TheGameModel.CreateSceneObjectFromMovieClip("mcInterface", "DesafiateInterface");
			TheGameModel.CreateSceneObjectFromMovieClip("mcWindowsPhone", "WindowsPhone");
			TheGameModel.CreateSceneObjectFromMovieClip("mcElevatorConsole", "ElevatorConsole");
			TheGameModel.CreateSceneObjectFromMovieClip("mcMiniGame", "MiniGameManager");
		}

		override public function OnStartComplete():void
		{
			mBlackScreen = new Sprite();
			mBlackScreen.graphics.beginFill(0);
			mBlackScreen.graphics.drawRect(0, 0, 915,508);
			mBlackScreen.graphics.endFill();

			mBlackScreen.x = -915/2;
			mBlackScreen.y = -508/2;

			TheGameModel.TheRender2DCamera.addChild(mBlackScreen);

			TweenLite.to(mBlackScreen, 1.0, { alpha:0, onComplete: OnAlphaComplete });
		}

		override public function OnStop():void
		{
			if (mBlackScreen != null)
				TweenLite.killTweensOf(mBlackScreen);
		}

		private function OnAlphaComplete():void
		{
			TheGameModel.TheRender2DCamera.removeChild(mBlackScreen);
			mBlackScreen = null;
		}


		private var mBlackScreen : Sprite;
	}
}

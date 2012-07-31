package GameComponents.PlanetWars
{
	import GameComponents.GameComponent;

	public class PlanetWarsMain extends GameComponent
	{
		public override function OnStart():void
		{
		}

		// Aquí ahora mismo se está llamando desde el planeta, que es el que sabe cuándo el servidor le dice que ya está OK.
		public function StartGame() : void
		{
			mController = new PlanetWarsController(TheGameModel);

			var mainInterface : MainInterface = new MainInterface();
			mainInterface.Init(mController);

			var galaxyInterface : GalaxyInterface = new GalaxyInterface();
			galaxyInterface.Init(mController);

			//TheGameModel.TheRenderCanvas.addChild(mainInterface);
			TheGameModel.TheRenderCanvas.addChild(galaxyInterface);
		}

		private var mMainInterface : MainInterface;
		private var mController : PlanetWarsController;
	}
}
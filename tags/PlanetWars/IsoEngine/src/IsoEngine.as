package
{
	import GameComponents.GameComponentEnumerator;

	import Model.GameModel;

	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;

	import utils.CentralLoader;

	public class IsoEngine extends EventDispatcher
	{
		/**
		 *  Al cargar dentro de facebook nos encontramos con que la ruta tiene que ser absoluta, así
		 *  que todos lo assets que el motor cargue se compondran con este path
		 */
		public static var BaseUrl : String = "";

		/**
		 * Sistema de carga centralizado: el motor carga todos sus assets a traves de él, y el cliente
		 * o los componentes pueden cooperar.
		 */
		public function get TheCentralLoader() : CentralLoader { return mCentralLoader; }

		/** Access to the GameModel that we own. */
		public function get TheGameModel() : GameModel { return mGameModel; }

		/**
		 * Parent es dónde el motor hará su render. Un Canvas con el clipping activado por ejemplo.
		 */
		public function IsoEngine(parent : DisplayObjectContainer)
		{
			mParent = parent;
			mCentralLoader = new CentralLoader(BaseUrl);
			mGameComponentEnumerator = new GameComponentEnumerator();
		}

		/** Are we running under the editor? */
		virtual public function get IsEditor() : Boolean { return false; }

		/**
		 * Función de carga para que los componentes puedan cargar otro mapa.
		 * En Standalone llamaremos aquí directamente al iniciar el engine.
		 * Llames desde donde llames, las cargas siempre se producen en el primer AfterUpdate del GameModel.
		 */
		virtual public function Load(pathToMap:String):void
		{
			if (mGameModel == null)
				InternalRealLoad(pathToMap, null);
			else
				mUrlToLoad = pathToMap;
		}

		protected function OnGameModelLoaded(event:Event):void
		{
			mGameModel.AttachToRenderCanvas(mParent);
			mGameModel.StartGame();
		}

		private function AfterUpdate(event:Event) : void
		{
			if (mUrlToLoad != null)
			{
				AfterUpdateLoad(mUrlToLoad);
				mUrlToLoad = null;
			}
		}

		private function AfterUpdateLoad(pathToMap:String):void
		{
			var prevGlobalState : Object = null;

			// Limpiamos el anterior
			if (mGameModel != null)
			{
				prevGlobalState = mGameModel.GlobalGameState;
				mGameModel.StopGame();
				mGameModel.RemoveFromRenderCanvas();
				mGameModel = null;

				mCentralLoader.DiscardAllQueues();
			}

			InternalRealLoad(pathToMap, prevGlobalState);
		}

		private function InternalRealLoad(pathToMap:String, prevGlobalState : Object):void
		{
			mGameModel = new GameModel(this, prevGlobalState);

			mGameModel.addEventListener("GameModelLoaded", OnGameModelLoaded);
			mGameModel.addEventListener("AfterUpdate", AfterUpdate, false, int.MAX_VALUE);

			mGameModel.Load(pathToMap);
		}

		private var mParent : DisplayObjectContainer = null;
		private var mGameComponentEnumerator : GameComponentEnumerator = null;
		private var mCentralLoader : CentralLoader = null;
		private var mGameModel :  GameModel = null;
		private var mUrlToLoad : String = null;
	}
}
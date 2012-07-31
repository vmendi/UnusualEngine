package Editor
{
	import Model.GameModel;

	import flash.events.Event;
	import flash.events.EventDispatcher;

	import utils.GenericEvent;

	public class LoadSaveController extends EventDispatcher
	{
		public function get TheGameModel() : GameModel { return mGameModel; }
		public function get TheLoadSaveHelper() : ILoadSaveHelper { return mHelper; }
		
		
		public function LoadSaveController(helper : ILoadSaveHelper)
		{
			mHelper = helper;
			CreateNewGameModel();
		}
		
        public function New() : void
        {
        	CreateNewGameModel();
        	dispatchEvent(new Event("GameModelNew"));
        }

		private function CreateNewGameModel() : void
		{
			// Si el juego estuviera corriendo, lo paramos
			if (mGameModel != null)
				mGameModel.StopGame();

			mGameModel = new GameModel(new EditorIsoEngine(this));

			// Retrasmitimos hacia arriba todo lo que el modelo nos dice
			mGameModel.addEventListener("GameModelLoaded", Redispatcher, false, 0, true);

			// Cazamos los errores de carga
			mGameModel.TheIsoEngine.TheCentralLoader.addEventListener("LoadError", Redispatcher, false, 0, true);
		}

		private function Redispatcher(event:Event):void
		{
			dispatchEvent(event);
		}

		public function LoadProjectUrl(url : String, xmlToLoad:XML=null) : void
		{
			CreateNewGameModel();

		    mGameModel.Load(url, xmlToLoad);
		}

        public function OpenProject() : void
        {
        	mHelper.addEventListener("FileUrlForOpenSelected", OnProjectLoad, false, 0, true);
        	mHelper.GetFileURLForOpen();
        }

        public function SaveProject() : void
        {
        	if (mGameModel.GameModelUrl == "Nuevo")
        		SaveAsProject();
        	else
				mHelper.SaveStringToFile(mGameModel.GetXML().toXMLString(), mGameModel.GameModelUrl);
        }

        public function SaveAsProject() : void
        {
        	mHelper.addEventListener("FileUrlSaved", OnProjectSave, false, 0, true);
        	mHelper.SaveStringToFile(mGameModel.GetXML().toXMLString(), null);
        }

		private function OnProjectLoad(event:GenericEvent) : void
		{
			mHelper.removeEventListener("FileUrlForOpenSelected", OnProjectLoad);

			if (event.Data != null)
				LoadProjectUrl(event.Data as String);
		}

        private function OnProjectSave(event:GenericEvent):void
        {
        	mHelper.removeEventListener("FileUrlSaved", OnProjectSave);

        	if (event.Data != null)
        		mGameModel.GameModelUrl = event.Data as String;
        }

        public function SelectBackgroundSWF() : void
        {
        	mHelper.addEventListener("FileUrlForOpenSelected", OnBackgroundSWFToLoadSelected, false, 0, true);
        	mHelper.GetFileURLForOpen();
        }

        public function OnBackgroundSWFToLoadSelected(event:GenericEvent) : void
        {
        	mHelper.removeEventListener("FileUrlForOpenSelected", OnBackgroundSWFToLoadSelected);

        	if (event.Data != null)
        	{
        		mGameModel.TheIsoCamera.TheIsoBackground.SelectSWF(event.Data as String);
        	}
        }

        private var mHelper : ILoadSaveHelper;
        private var mGameModel : GameModel;
	}
}
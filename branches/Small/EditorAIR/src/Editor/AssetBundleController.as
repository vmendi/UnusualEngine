package Editor
{
	import Model.AssetBundle;
	import Model.GameModel;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import utils.GenericEvent;

	public class AssetBundleController
	{
		public const EMBEDDED : String = "Embedded in map";
		public const ALL : String = "All";

		public function AssetBundleController(gameModel : GameModel, loadSaveHelper : ILoadSaveHelper)
		{
			mGameModel = gameModel;
			mHelper = loadSaveHelper;
			mSelectedBundleGroup = ALL;
			
			mGameModel.TheAssetLibrary.addEventListener("AssetBundleAdded", OnAssetBundleAdded);
			mGameModel.TheAssetLibrary.addEventListener("AssetBundleRemoved", OnAssetBundleRemoved);

			for each(var b : AssetBundle in mGameModel.TheAssetLibrary.AssetBundles)
				mFilteredBundles.addItem(b);

			mFilteredBundles.filterFunction = TheFilterFunction;
			mFilteredBundles.refresh();

			FillBundleGroupNames();
		}

		public function get FilteredAssetBundles() : ArrayCollection { return mFilteredBundles; }
		public function get BundleGroupNames() : ArrayCollection { return mBundleGroupNames; }

		public function get SelectedBundleGroupName() : String
		{
			return mSelectedBundleGroup;
		}

		public function set SelectedBundleGroupName(sel : String):void
		{
			mSelectedBundleGroup = sel;

			// Cada vez que se selecciona un elemento de la lista, basta con volver a invocar el filtro
			mFilteredBundles.refresh();
		}
		
		public function get SelectedAssetBundle() : AssetBundle { return mSelectedAssetBundle; }
		public function set SelectedAssetBundle(b : AssetBundle) : void { mSelectedAssetBundle = b; }


		private function FillBundleGroupNames():void
		{
			mBundleGroupNames.addItem(ALL);
			mBundleGroupNames.addItem(EMBEDDED);

			for each(var bundle : AssetBundle in mGameModel.TheAssetLibrary.AssetBundles)
			{
				if (bundle.ImportURL != "")
					mBundleGroupNames.addItem(bundle.ImportURL);
			}
		}

		private function TheFilterFunction(item:Object):Boolean
		{
			var bRet : Boolean = false;
			var bundle : AssetBundle = item as AssetBundle;

			if (mSelectedBundleGroup == ALL)
				bRet = true;
			else
			if (mSelectedBundleGroup == EMBEDDED)
			{
				if (bundle.ImportURL == "")
					bRet = true;
			}
			else
			{
				if (bundle.ImportURL == mSelectedBundleGroup)
					bRet = true;
			}

 			return bRet;
		}

		private function OnGameModelLoaded(event:Event):void
		{
			FillBundleGroupNames();
		}

		private function OnAssetBundleAdded(event:GenericEvent):void
		{		
			var bundle : AssetBundle = event.Data as AssetBundle;

			if (bundle.ImportURL != "")
				mBundleGroupNames.addItem(bundle.ImportURL);

			mFilteredBundles.addItem(bundle);
		}
		
		private function OnAssetBundleRemoved(event:GenericEvent):void
		{
			var bundle : AssetBundle = event.Data as AssetBundle;
			
			// Si está filtrado quizá no esté?
			mFilteredBundles.removeItemAt(mFilteredBundles.getItemIndex(bundle));

			if (bundle.ImportURL != "")
				mBundleGroupNames.removeItemAt(mBundleGroupNames.getItemIndex(bundle.ImportURL));	
		} 
		
		public function RemoveAssetBundleFromLibrary(bundle : AssetBundle) : void
		{
			mGameModel.TheAssetLibrary.RemoveAssetBundle(bundle);
		}		
		
        public function AddAssetBundleToLibrary() : void
        {
        	mHelper.addEventListener("FileUrlForOpenSelected", OnSWFToLoadSelected);
        	mHelper.GetFileURLForOpen();
        }

        private function OnSWFToLoadSelected(event:GenericEvent):void
        {
        	mHelper.removeEventListener("FileUrlForOpenSelected", OnSWFToLoadSelected);

        	if (event.Data != null)
         		mGameModel.TheAssetLibrary.AddAssetBundle(event.Data as String);
        }
        
        public function ImportAssetBundle() : void
        {
        	mHelper.addEventListener("FileUrlForOpenSelected", OnImportAssetBundleSelected);
        	mHelper.GetFileURLForOpen();
        }

        private function OnImportAssetBundleSelected(event:GenericEvent):void
		{
			mHelper.removeEventListener("FileUrlForOpenSelected", OnImportAssetBundleSelected);

			if (event.Data != null)
				mGameModel.TheAssetLibrary.ImportAssetBundle(event.Data as String);
        }

        public function ExportAssetBundle() : void
        {
        	if (mSelectedAssetBundle != null)
        	{
        		mHelper.addEventListener("FileUrlSaved", OnExportAssetBundleSelected);
        		mHelper.SaveStringToFile(mSelectedAssetBundle.GetXML().toXMLString(), null);
        	}
        }

        private function OnExportAssetBundleSelected(event:GenericEvent):void
        {
        	mHelper.removeEventListener("FileUrlSaved", OnExportAssetBundleSelected);
        }

		private var mGameModel : GameModel;
		private var mHelper : ILoadSaveHelper;

		private var mSelectedAssetBundle : AssetBundle;
		private var mSelectedBundleGroup : String = "";

		private var mBundleGroupNames : ArrayCollection = new ArrayCollection();
		private var mFilteredBundles : ArrayCollection = new ArrayCollection();
	}
}
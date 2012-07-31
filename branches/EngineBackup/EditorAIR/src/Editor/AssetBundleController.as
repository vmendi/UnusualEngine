package Editor
{
	import Model.AssetBundle;
	import Model.GameModel;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
	import utils.GenericEvent;

	public class AssetBundleController extends EventDispatcher
	{
		public const ALL : String = "All";
		public const INTERNAL : String = "Embedded in map";
		public const EXTERNAL : String = "External in disk";		

		public function AssetBundleController(gameModel : GameModel, loadSaveHelper : ILoadSaveHelper)
		{
			mGameModel = gameModel;
			mHelper = loadSaveHelper;
			mSelectedBundleGroup = ALL;

			mGameModel.TheAssetLibrary.addEventListener("AssetBundleAdded", OnAssetBundleAdded);
			mGameModel.TheAssetLibrary.addEventListener("AssetBundleRemoved", OnAssetBundleRemoved);

			for each(var b : AssetBundle in mGameModel.TheAssetLibrary.AssetBundles)
				mFilteredBundles.addItem(b);

			mFilteredBundles.addEventListener(CollectionEvent.COLLECTION_CHANGE, OnFilteredBundlesChanged);
			mFilteredBundles.filterFunction = TheFilterFunction;
			mFilteredBundles.sort = GetAssetBundleDisplayNameSort();
			mFilteredBundles.refresh();
			
			if (mFilteredBundles.length != 0)
				SelectedAssetBundle = mFilteredBundles[0];

			FillBundleGroupNames();
		}
		
		private function GetAssetBundleDisplayNameSort() : Sort
		{
			var ret : Sort = new Sort();
			ret.compareFunction = AssetBundleCompare;
			ret.unique = true;
			
			return ret;
		}
		
		private function AssetBundleCompare(a:Object, b:Object, fields:Array=null) : int
		{
			var aBundle : AssetBundle = a as AssetBundle;
			var bBundle : AssetBundle = b as AssetBundle;
			
			if (aBundle == null && bBundle == null)
				return 0;
			if (aBundle == null)
				return -1;
			if (bBundle == null)
				return 1;
			
			if (aBundle.ImportURL == "")
			{
				if (bBundle.ImportURL == "")
				{
					var comp : int = aBundle.SWFURL.localeCompare(bBundle.SWFURL);
				
					// Un bug extrañisimo en el flex SDK fuerza a una comparacion con -1 y 1, no vale un numbero cualquiera
					if (comp < 0) 	   return -1;
					else if (comp > 0) return 1;
				}
				else
					return -1;
			}
			else
			{
				if (bBundle.ImportURL == "")
					return 1;
				else
				{
					comp = aBundle.ImportURL.localeCompare(bBundle.ImportURL);
					
					if (comp < 0) 	   return -1;
					else if (comp > 0) return 1;
				}
			}
			
			return 0;			
		}
		
		private function OnFilteredBundlesChanged(event:CollectionEvent):void
		{
			// Al acabar el refresco, podemos recalcular los DisplayNames
			if (event.kind == CollectionEventKind.REFRESH)
				RefreshAssetBundlesDisplayNames();
		}

		public function get BundleGroupNames() : ArrayCollection { return mBundleGroupNames; }
		
		public function get FilteredAssetBundles() : ArrayCollection { return mFilteredBundles; }
		public function get FilteredAssetBundlesDisplayNames() : ArrayCollection { return mFilteredAssetBundlesDisplayNames; }
		
		private function RefreshAssetBundlesDisplayNames():void
		{
			mFilteredAssetBundlesDisplayNames.disableAutoUpdate();
			mFilteredAssetBundlesDisplayNames.removeAll();
			
			for each(var bundle : AssetBundle in mFilteredBundles)
			{
				if (bundle.ImportURL == "")
					mFilteredAssetBundlesDisplayNames.addItem(RemoveURLPathAndExtension(bundle.SWFURL));
				else
					mFilteredAssetBundlesDisplayNames.addItem(bundle.ImportURL);
			}
			
			mFilteredAssetBundlesDisplayNames.enableAutoUpdate();
		}
		
		static public function RemoveURLPathAndExtension(url : String) : String
		{
			//var onlyFilename : String = bundle.SWFURL.match(/(\w+)[.]/)[1];
			var noPath : String = url.substring(url.lastIndexOf("/")+1);
			return noPath.substring(0, noPath.indexOf("."));
		}

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

		[Bindable]
		public function get SelectedAssetBundle() : AssetBundle { return mSelectedAssetBundle; }
		public function set SelectedAssetBundle(b : AssetBundle) : void { mSelectedAssetBundle = b; }


		private function FillBundleGroupNames():void
		{
			mBundleGroupNames.addItem(ALL);
			mBundleGroupNames.addItem(INTERNAL);
			mBundleGroupNames.addItem(EXTERNAL);
		}

		private function TheFilterFunction(item:Object):Boolean
		{
			var bRet : Boolean = false;
			var bundle : AssetBundle = item as AssetBundle;

			if (mSelectedBundleGroup == ALL)
				bRet = true;
			else
			if (mSelectedBundleGroup == INTERNAL)
			{
				if (bundle.ImportURL == "")
					bRet = true;
			}
			else
			{
				if (bundle.ImportURL != "")
					bRet = true;
			}

 			return bRet;
		}

		private function OnAssetBundleAdded(event:GenericEvent):void
		{
			var bundle : AssetBundle = event.Data as AssetBundle;

			mFilteredBundles.addItem(bundle);
			
			// Queremos provocar el CollectionEventKind.REFRESH siempre, para que se refresquen los DisplayNames
			mFilteredBundles.refresh();
		}

		private function OnAssetBundleRemoved(event:GenericEvent):void
		{
			var bundle : AssetBundle = event.Data as AssetBundle;

			var removedIdx : int = mFilteredBundles.getItemIndex(bundle);
			mFilteredBundles.removeItemAt(removedIdx);
			
			// CollectionEventKind.REFRESH siempre...
			mFilteredBundles.refresh();
			
			if (removedIdx > 0 && removedIdx >= mFilteredBundles.length)
				removedIdx--;
			
			if (removedIdx >= 0 && removedIdx < mFilteredBundles.length)
				SelectedAssetBundle = mFilteredBundles[removedIdx];
			else
				SelectedAssetBundle = null;
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

        public function ExportSelectedAssetBundle() : void
        {
        	if (mSelectedAssetBundle != null)
        	{
        		mHelper.addEventListener("FileUrlSaved", OnExportAssetBundleSelected);
        		mHelper.SaveStringToFile(mSelectedAssetBundle.GetExportXML().toXMLString(), null);
        	}
        }
		
		public function SaveSelectedAssetBundle() : void
		{
			if (mSelectedAssetBundle != null)
			{
				if (mSelectedAssetBundle.ImportURL == "")
					throw "The selected asset bundle was not imported";
				
				mHelper.SaveStringToFile(mSelectedAssetBundle.GetExportXML().toXMLString(), mSelectedAssetBundle.ImportURL);
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
		private var mFilteredAssetBundlesDisplayNames : ArrayCollection = new ArrayCollection();
	}
}
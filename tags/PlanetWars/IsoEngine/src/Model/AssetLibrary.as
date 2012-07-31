package Model
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.system.ApplicationDomain;

	import mx.collections.ArrayCollection;

	import utils.CentralLoader;
	import utils.Delegate;
	import utils.GenericEvent;


	/**
	 * Librería de AssetObjs. Gestiona los SWFs disponibles, manteniendo un AssetObj por cada MovieClip en estos
	 * SWFs.
	 *
	 * Cada vez que se añade un SWF a la librería, ésta se ocupa de enumerar los MovieClip <b>exportados</b>,
	 * sólo los exportados. Crea un nuevo AssetObject por cada MovieClip que antes no existiera.
	 *
	 * Cuando se carga una librería y por lo tanto se cargan todos los SWFs a los que referencia,
	 * también se borran todos los AssetObjects que se hayan quedado sin su correspondiente MovieClip porque
	 * se hayan borrado del SWF.
	 */
	public class AssetLibrary extends EventDispatcher
	{
		[Bindable(event="AssetBundleAdded")]
		[Bindable(event="AssetBundleRemoved")]
		public function get AssetBundles() : ArrayCollection { return mBundles; }

		public function AssetLibrary(isoEngine : IsoEngine) : void
		{
			mCentralLoader = isoEngine.TheCentralLoader;
		}

		/**
		 * Crea y devuelve un MovieClip, que tiene que estar exportando en cualquiera de los SWFs cargados con
		 * el nombre pasado como parámetro "mcName".
		 */
		public function CreateMovieClip(mcName : String) : MovieClip
		{
			var mcClass : Class = null;

			try
			{
				mcClass = mLoadedAppDomain.getDefinition(mcName) as Class;
			}
			catch(e:Error)
			{
			}

			var ret : MovieClip = null;

			if (mcClass != null)
			{
				ret = new mcClass as MovieClip;
				ret.cacheAsBitmap = true;
			}

			return ret;
		}

		/**
		 * Devuelve el AssetObject cuyo MovieClip asociado es "mcName"
		 */
		public function FindAssetObjectByMovieClipName(mcName : String) : AssetObject
		{
			for each(var obj : AssetObject in mAssetObjects)
				if (obj.TheDefaultGameComponent.MovieClipName == mcName)
					return obj;
			return null;
		}

		public function GetXML() : XML
		{
			var libraryXML : XML = <AssetLibrary></AssetLibrary>

			for (var c : int = 0; c < mBundles.length; c++)
			{
				libraryXML.appendChild(mBundles[c].GetXML());
			}

			return libraryXML;
		}


		/**
		 * Carga una librería desde un XML
		 */
		public function LoadFromXML(myXML:XML) : void
		{
			if (mLoadedAppDomain != null)
				throw "Loading again after first load not supported yet";

			mLoadedAppDomain = mCentralLoader.GetAppDomainOfQueue("SWF");

			for each(var assetBundleXML : XML in myXML.child("AssetBundle"))
			{
				var newBundle : AssetBundle = AssetBundle.CreateFromXML(assetBundleXML, mCentralLoader);
				mBundles.addItem(newBundle);
			}

			mCentralLoader.addEventListener("LoadCompleteSWF", OnSWFsLoadComplete);
		}

		private function OnSWFsLoadComplete(event:Event) : void
		{
			// Nos tenemos que desuscribir puesto que el CentralLoader sirve para multiples cargas
			mCentralLoader.removeEventListener("LoadCompleteSWF", OnSWFsLoadComplete);

			for each(var bundle : AssetBundle in mBundles)
			{
				mAssetObjects = mAssetObjects.concat(bundle.AssetObjects);
			}

			dispatchEvent(new Event("AssetBundlesChanged"));
		}

		public function ImportAssetBundle(url : String) : void
		{
			if (mLoadedAppDomain == null)
				mLoadedAppDomain = new ApplicationDomain();

			// Tenemos que repetir el proceso que hace el GameModel
			mCentralLoader.CreateQueue("SWF", mLoadedAppDomain);
			mCentralLoader.CreateQueue("ImportXML");
			var newBundle : AssetBundle = AssetBundle.CreateFromURL(url, mCentralLoader);

			// Hasta que no esté OK no lo ponemos entre los nuestros
			mCentralLoader.LoadQueue("ImportXML", Delegate.create(OnAssetBundleImportXMLComplete, newBundle));
		}

		private function OnAssetBundleImportXMLComplete(event:Event, newBundle:AssetBundle):void
		{
			mCentralLoader.DiscardQueue("ImportXML");
			mCentralLoader.LoadQueue("SWF", Delegate.create(OnAssetBundleImportComplete, newBundle));
		}

		private function OnAssetBundleImportComplete(event:Event, newBundle:AssetBundle) : void
		{
			mCentralLoader.DiscardQueue("SWF");
			mBundles.addItem(newBundle);
			mAssetObjects = mAssetObjects.concat(newBundle.AssetObjects);

			dispatchEvent(new GenericEvent("AssetBundleAdded", newBundle));
		}


		/**
		 * Añade un AssetBundle, generando sus AssetObjs correspondientes.
		 */
		public function AddAssetBundle(url : String) : void
		{
			if (mLoadedAppDomain == null)
				mLoadedAppDomain = new ApplicationDomain();

			mCentralLoader.Load(url, true, swfLoaded, mLoadedAppDomain);

			function swfLoaded(loader:Loader):void
			{
				var newBundle : AssetBundle = AssetBundle.CreateFromLoader(loader);
				mBundles.addItem(newBundle);

				mAssetObjects = mAssetObjects.concat(newBundle.AssetObjects);

				dispatchEvent(new GenericEvent("AssetBundleAdded", newBundle));
			}
		}

		public function RemoveAssetBundle(bundle : AssetBundle) : void
		{
			var idxToRemove : int = mBundles.getItemIndex(bundle);

			// Quitamos los AssetObjects de nuestra lista global
			for each(var assetObj : AssetObject in bundle.AssetObjects)
			{
				mAssetObjects.splice(mAssetObjects.indexOf(assetObj), 1);
			}

			mBundles.removeItemAt(idxToRemove);

			dispatchEvent(new GenericEvent("AssetBundleRemoved", bundle));
		}

		public function CopyAssetObjectToLibrary(assetObj : AssetObject) : void
		{
			var assetObjName : String = assetObj.TheDefaultGameComponent.MovieClipName;

			var targetAssetObj : AssetObject = FindAssetObjectByMovieClipName(assetObjName);

			if (targetAssetObj == null)
				throw "AssetObj not found";

			targetAssetObj.Overwrite(assetObj);
		}

		private var mBundles : ArrayCollection = new ArrayCollection();

		// Global con todos los AssetObjets, para no tener que acceder a través de las AssetBundles
		private var mAssetObjects : Array = new Array();

		// Num total de bytes que hemos cargado la última vez que cargamos todos los SWFs
		private var mTotalBytesInSWFs : int = -1;

		private var mCentralLoader : CentralLoader = null;
		private var mLoadedAppDomain : ApplicationDomain;
	}
}
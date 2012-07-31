package Model
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.system.ApplicationDomain;
	import flash.utils.getQualifiedClassName;

	import utils.CentralLoader;

	public class AssetBundle extends EventDispatcher
	{
		public function AssetBundle()
		{
		}

		static public function CreateFromXML(myXML:XML, central:CentralLoader) : AssetBundle
		{
			var ret : AssetBundle = new AssetBundle();
			ret.mCentralLoader = central;
			ret.LoadFromXML(myXML);
			return ret;
		}

		static public function CreateFromLoader(loader:Loader) : AssetBundle
		{
			var ret : AssetBundle = new AssetBundle();
			ret.CreateFromLoader(loader);
			return ret;
		}

		static public function CreateFromURL(url:String, central:CentralLoader) : AssetBundle
		{
			var ret : AssetBundle = new AssetBundle;
			ret.mCentralLoader = central;
			ret.ImportFromURL(url);
			return ret;
		}


		public function FindAssetObjectByMovieClipName(mcName : String) : AssetObject
		{
			for each(var obj : AssetObject in mAssetObjects)
				if (obj.TheDefaultGameComponent.MovieClipName == mcName)
					return obj;
			return null;
		}

		public function GetXML() : XML
		{
			var myXML : XML = <AssetBundle></AssetBundle>

			myXML.appendChild(<ImportURL>{mImportURL}</ImportURL>);

			// Si fue importado desde un XML en disco, grabamos sólo la referencia anterior (<ImportURL>)
			if (mImportURL == "")
			{
				myXML.appendChild(<SWFURL>{mSWFURL}</SWFURL>);

				for each(var assetObj : AssetObject in mAssetObjects)
				{
					myXML.appendChild(assetObj.GetXML());
				}
			}

			return myXML;
		}

		public function GetExportXML() : XML
		{
			// Aquí, en contraste con GetXML, siempre devolvemos el InnerXML, el contenido de verdad, independientemente
			// de que fueramos importados o no
			var myXML : XML = <AssetBundle></AssetBundle>

			// ImportURL vacio siempre...
			myXML.appendChild(<ImportURL></ImportURL>);

			// Y lo demás, igual que en GetXML
			myXML.appendChild(<SWFURL>{mSWFURL}</SWFURL>);

			for each(var assetObj : AssetObject in mAssetObjects)
			{
				myXML.appendChild(assetObj.GetXML());
			}

			return myXML;
		}

		private function CreateFromLoader(loader:Loader):void
		{
			mSWFURL = loader.contentLoaderInfo.url;
			mSWFURL = mSWFURL.replace("app:/", "");

			GatherMovieClipNames(loader.contentLoaderInfo);
			SyncAssetObjects();
		}

		private function LoadFromXML(myXML:XML):void
		{
			mImportURL = myXML.ImportURL.toString();

			if (mImportURL != "")
				mCentralLoader.AddToQueue(mImportURL, false, "ImportXML", OnXMLLoaded);
			else
				InnerLoadFromXML(myXML);
		}

		private function ImportFromURL(url : String):void
		{
			mImportURL = url;
			mCentralLoader.AddToQueue(mImportURL, false, "ImportXML", OnXMLLoaded);
		}

		private function OnXMLLoaded(loader : URLLoader):void
		{
			var xml : XML = XML(loader.data);
			InnerLoadFromXML(xml);
		}

		private function InnerLoadFromXML(myXML:XML):void
		{
			mSWFURL = myXML.SWFURL.toString();

			for each(var nodeXML : XML in myXML.child("AssetObject"))
			{
				var assetObj : AssetObject = new AssetObject();
				assetObj.LoadFromXML(nodeXML);
				mAssetObjects.push(assetObj);
			}

			mCentralLoader.AddToQueue(mSWFURL, true, "SWF", OnSWFLoaded);
		}


		private function OnSWFLoaded(loader : Loader):void
		{
			GatherMovieClipNames(loader.contentLoaderInfo);
			SyncAssetObjects();
		}

		private function GatherMovieClipNames(loaderInfo:LoaderInfo):void
		{
			var appDomain : ApplicationDomain = loaderInfo.applicationDomain;

			// Generamos la lista de nombres de los movieclips disponibles usando la libreria enumeradora
			var defNames : Array = utils.getDefinitionNames(loaderInfo);

			for (var c:int=0; c < defNames.length; c++)
			{
				// Quitamos los no exportados (asumimos que llevan un ::)
				if (defNames[c].indexOf("::") == -1)
				{
					if (mMovieClipNames.indexOf(defNames[c]) != -1)
					{
            			trace("Duplicated MovieClip name: " + defNames[c] + " <---> SWF: " + mSWFURL);
            			continue;
					}

					// Quitamos también todo lo que no sea movieclip, por ejemplo sonidos
					var theClass : Class = appDomain.getDefinition(defNames[c]) as Class;

					if (utils.Type.IsSubclassOf(theClass, getQualifiedClassName(MovieClip)))
						mMovieClipNames.push(defNames[c]);
				}
			}
		}

		/** Se encarga de borrar los AssetObjs que ya no están entre los movieclips y de crear los nuevos.
		 * */
		private function SyncAssetObjects():void
		{
			// Borramos los AssetObjects obsoletos (ha desaparecido su MovieClip dentro del SWF)
			for (var c : int = 0; c < mAssetObjects.length; c++)
			{
				if (mMovieClipNames.indexOf(mAssetObjects[c].TheDefaultGameComponent.MovieClipName) == -1)
				{
					mAssetObjects.splice(c, 1);
					c--;
				}
			}

			// Creamos los nuevos (están en el SWF y no hay AssetOject)
			for (c=0; c < mMovieClipNames.length; c++)
			{
				var assetObj : Object = FindAssetObjectByMovieClipName(mMovieClipNames[c]);

				if (assetObj == null)
				{
					assetObj = new AssetObject();
					assetObj.TheDefaultGameComponent.MovieClipName = mMovieClipNames[c];

					mAssetObjects.push(assetObj);
				}
			}
		}


		/** La del XML, si existe */
		public function get ImportURL() : String { return mImportURL; }

		/** La del swf */
		public function get SWFURL() : String { return mSWFURL; }

		public function get AssetObjects() : Array { return mAssetObjects; }
		public function get MovieClipNames() : Array { return mMovieClipNames; }


		private var mCentralLoader : CentralLoader;

		private var mImportURL : String = "";
		private var mSWFURL : String = "";

		private var mMovieClipNames : Array = new Array();
		private var mAssetObjects : Array = new Array();
	}
}
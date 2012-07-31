package utils
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.system.ApplicationDomain;
	import flash.system.Security;
	import flash.utils.Dictionary;
	
	import mx.core.Application;


	public class CentralLoader extends EventDispatcher
	{
		static public function BaseURL() : String
		{
			var ret : String = "";

			if (Security.sandboxType == Security.REMOTE)
			{
				var noSWFUrl : String = Application.application.url;

				// Si tiene parametros, es posible q dentro de ellos haya contrabarras, asi que tenemos q quitar los parametros
				if (noSWFUrl.indexOf("?") != -1)
					noSWFUrl = noSWFUrl.substr(0, noSWFUrl.indexOf("?"));

				ret = noSWFUrl.substr(0, noSWFUrl.lastIndexOf("/")+1);
			}

			return ret;
		}

		public function CentralLoader(baseUrl:String):void
		{
			mBaseUrl = baseUrl;

			mQueues[""] = new QueueLoader("", null, this);
		}

		public function Load(url:String, isDisplayObject:Boolean, onSuccess:Function, appDom:ApplicationDomain=null, appendBase:Boolean=true) : void
		{
			var loadMe : String = url;
			if (appendBase)
				loadMe = mBaseUrl + url;
			var newLoader : LoadHelper = new LoadHelper(loadMe, isDisplayObject, OnImmediateLoaded, null, appDom);
			newLoader.OnSuccess = onSuccess;
			newLoader.Load(CacheItem.SearchInCache(loadMe, mCacheItems));

			mImmediates.push(newLoader);
		}

		private function OnImmediateLoaded(loaded : LoadHelper):void
		{
			ArrayUtils.removeValueFromArray(mImmediates, loaded);

			if (loaded.TheLoader != null)
			{
				if (loaded.OnSuccess != null)
				{
					loaded.OnSuccess(loaded.TheLoader);
				}
			}
			else
			{
				dispatchEvent(new ErrorEvent("LoadError", false, false, "CentralLoader Error: " + loaded.URL));
			}
		}


		public function CreateQueue(name:String, appDom:ApplicationDomain=null):void
		{
			if (mQueues.hasOwnProperty(name))
				throw "Already existent queue";

			mQueues[name] = new QueueLoader(name, appDom, this);
		}

		public function AddToQueue(url:String, isDisplayObject:Boolean, queueName:String="", onQueueuComplete:Function=null) : void
		{
			var composedURL : String = mBaseUrl + url;

			if (!mQueues.hasOwnProperty(queueName))
				throw "You must call to CreateQueue. What if no AddToQueue is done?";

			mQueues[queueName].Add(composedURL, isDisplayObject, onQueueuComplete);
		}

		public function LoadQueue(queueName:String="", onQueueComplete:Function=null) : void
		{
			mQueues[queueName].OnQueueComplete = onQueueComplete;
			mQueues[queueName].Load(mCacheItems);
		}

		public function GetContentOfQueue(url:String, queueName:String="") : Object
		{
			return mQueues[queueName].GetLoadedContent(url);
		}

		public function DiscardQueue(queueName:String="") : void
		{
			delete mQueues[queueName];
		}

		public function DiscardAllQueues() : void
		{
			mQueues = new Dictionary();
			mQueues[""] = new QueueLoader("", null, this);
		}

		public function GetAppDomainOfQueue(queueName:String=""):ApplicationDomain
		{
			return mQueues[queueName].AppDomain;
		}

		public function SetTotalBytesOfQueue(bytes : int, q:String="") : void
		{
			mQueues[q].TotalBytes = bytes;
		}
		public function GetTotalBytesOfQueue(q:String="") : int
		{
			return mQueues[q].TotalBytes;
		}

		public function GetLoadedBytesOfQueue(q:String="") : int
		{
			return mQueues[q].LoadedBytes;
		}
		
		public function AddToCache(url : String):void
		{
			if (CacheItem.SearchInCache(url, mCacheItems) == null)
			{
				var cacheItem : CacheItem = new CacheItem(mBaseUrl + url);
				mCacheItems.push(cacheItem);
			}
		}

		private var mBaseUrl : String = "";

		private var mQueues : Dictionary = new Dictionary;
		private var mImmediates : Array = new Array();
		private var mCacheItems : Array = new Array();
	}
}

	import flash.errors.IOError;
	import flash.events.IOErrorEvent;
	import flash.profiler.showRedrawRegions;
	import mx.controls.Alert;
	import flash.net.URLStream;
	

internal class CacheItem
{
	public function CacheItem(url : String):void
	{
		mURL = url;
		mStream = new URLStream();
		mStream.addEventListener(Event.COMPLETE, OnComplete);
		mStream.addEventListener(ErrorEvent.ERROR, OnError);
		mStream.load(new URLRequest(url));		
	}
	
	public function get IsLoaded() : Boolean { return mCompleted; }
	public function get URL() : String { return mURL; }
	public function get TheByteArray() : ByteArray { return mBytes; }
	public function get TotalBytes() : int { return mBytes.length; }
	public function get TheURLStream() : URLStream { return mStream; }
	
	private function OnError(event:Event):void
	{
		Alert.show("Cache error", "Error", Alert.OK);
	}
	
	private function OnComplete(event:Event):void
	{
		mCompleted = true;
		mBytes = new ByteArray();
		mStream.readBytes(mBytes, 0, mStream.bytesAvailable);
		mStream.close();
	}
	
	static public function SearchInCache(url : String, cacheItems : Array) : CacheItem
	{
		for each(var c : CacheItem in cacheItems)
			if (c.URL == url)
				return c;
		return null;
	}

	
	private var mCompleted : Boolean = false;
	private var mStream : URLStream;
	private var mURL : String;
	private var mBytes : ByteArray = null;
}

import flash.events.EventDispatcher;
import flash.events.ErrorEvent;

internal class QueueLoader
{
	public var LoadedBytes : int = 0;
	public var TotalBytes : int = 0;
	public var RemainingToLoad : int = 0;
	public var LoadHelpers : Array = new Array();
	public var OnQueueComplete : Function = null;

	public function QueueLoader(name:String, appDomain:ApplicationDomain, centralLoader : EventDispatcher)
	{
		mCentralLoader = centralLoader;
		mName = name;
		mAppAdomain = appDomain;
	}

	public function get AppDomain() : ApplicationDomain { return mAppAdomain; }
	public function set AppDomain(appDom:ApplicationDomain):void { mAppAdomain=appDom; }


	public function Add(url : String, isDisplayObject:Boolean, onQueueuComplete:Function) : void
	{
		// Evitamos duplicados, tenemos que avisar del error porque no vamos a llamar a onQueueuComplete
		for each(var loadHelper : LoadHelper in LoadHelpers)
			if (url == loadHelper.URL)
				throw "Duplicated file";

		var newLoadHelper : LoadHelper = new LoadHelper(url, isDisplayObject, OnQueueElementLoaded, OnProgress, mAppAdomain);
		newLoadHelper.OnQueueComplete = onQueueuComplete;
		LoadHelpers.push(newLoadHelper);
	}

	public function Load(cacheItems : Array):void
	{
		// Por ejemplo: LoadStartSWF
		mCentralLoader.dispatchEvent(new Event("LoadStart" + mName));

		LoadedBytes = 0;
		RemainingToLoad = LoadHelpers.length;

		if (RemainingToLoad == 0)
			DispatchComplete();
		
		for each (var unique : LoadHelper in LoadHelpers)
			unique.Load(CacheItem.SearchInCache(unique.URL, cacheItems));
	}

	public function GetLoadedContent(url : String):Object
	{
		for each (var unique : LoadHelper in LoadHelpers)
			if (unique.URL.indexOf(url) != -1)
				return unique.TheLoader;
		return null;
	}
	
	private function DispatchComplete() : void
	{
		// Llamamos primero a las funcs individuales, después a la global y por último a los listeners
		for each(var loadHelper : LoadHelper in LoadHelpers)
		{
			if (loadHelper.OnQueueComplete != null)
				loadHelper.OnQueueComplete(loadHelper.TheLoader);
		}
		
		if (this.OnQueueComplete != null)
			this.OnQueueComplete(new Event("LoadComplete" + mName));

		mCentralLoader.dispatchEvent(new Event("LoadComplete" + mName));
	}

	private function OnQueueElementLoaded(loaded : LoadHelper) : void
	{
		if (loaded.TheLoader != null)
		{
			RemainingToLoad--;

			if (RemainingToLoad == 0)
				DispatchComplete();
		}
		else mCentralLoader.dispatchEvent(new ErrorEvent("LoadError", false, false,  "CentralLoader Error: " + loaded.URL));
	}

	private function OnProgress(loading : LoadHelper, loadedBytes : int, event:ProgressEvent) : void
	{
		// En el parametro nos pasan el diferencial respecto a la ultima vez
		LoadedBytes += loadedBytes;

		var progressEvent : ProgressEvent = new ProgressEvent("LoadProgress" + mName, false, false, LoadedBytes, TotalBytes);
		mCentralLoader.dispatchEvent(progressEvent);
	}

	private var mCentralLoader : EventDispatcher;
	private var mName : String;
	private var mAppAdomain : ApplicationDomain;
}


import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.display.Loader;
import flash.system.LoaderContext;
import flash.events.ProgressEvent;
import flash.display.MovieClip;
import flash.utils.ByteArray;
import flash.events.SecurityErrorEvent;
import utils.Delegate;

internal dynamic class LoadHelper
{
	public function get IsDisplayObject() : Boolean { return mIsDisplayObject; }
	public function get TheLoader() : Object { return mLoader; }
	public function get URL() : String { return mUrl; }
	public function get AppDomain() : ApplicationDomain { return mAppDomain; }

	public function LoadHelper(url : String, isDisplayObject:Boolean,
							  onLoaded : Function, onProgress : Function,
							  appDomain:ApplicationDomain)
	{
		mOnLoaded = onLoaded;
		mOnProgress = onProgress;
		mUrl = url;
		mIsDisplayObject = isDisplayObject;
		mLoader = null;
		mAppDomain = appDomain;
		mLastBytesLoaded = 0;
	}

	public function Load(cacheItem : CacheItem) : void
	{
		if (mLoader != null)
			throw "Ya cargados...";

		if (mUrl == null)
		{
			// Siempre que hay un fallo notificamos con TheLoader a null
			if (mOnLoaded != null)
				mOnLoaded(this);
		}
		else
		if (mIsDisplayObject)
		{			
			if (cacheItem != null)
			{
				if (!cacheItem.IsLoaded)
				{
					trace("Hooking to a loading URLStream");
					cacheItem.TheURLStream.addEventListener(Event.COMPLETE, Delegate.create(OnURLStreamComplete, cacheItem));
					cacheItem.TheURLStream.addEventListener(ProgressEvent.PROGRESS, OnProgress);
					cacheItem.TheURLStream.addEventListener(IOErrorEvent.IO_ERROR, OnError);
					cacheItem.TheURLStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, OnError);					
				}
				else
				{
					trace("Creating the Loader from an already loaded URLStream");
					
					/* Como ya está cargada y no nos hemos hookeado nunca a su PROGRESS, tenemos que radiar
					   ahora el 100% */
					OnProgress(new ProgressEvent(ProgressEvent.PROGRESS, false, false, 
												 cacheItem.TotalBytes, cacheItem.TotalBytes));
					CreateLoaderFromByteArray(cacheItem.TheByteArray);
				}
			}
			else
			{
				var swfLoader : Loader = new Loader();
				mLoader = swfLoader;
	
				swfLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, OnLoaded);
				swfLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, OnProgress);
				swfLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, OnError);
				swfLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, OnError);		
	
				var context : LoaderContext = null;
				if (mAppDomain != null)
					context = new LoaderContext(false, mAppDomain);

				swfLoader.load(new URLRequest(mUrl), context);
			}
		}
		else
		{
			var loader : URLLoader = new URLLoader();
			mLoader = loader;

			loader.addEventListener(Event.COMPLETE, OnLoaded);
			loader.addEventListener(ProgressEvent.PROGRESS, OnProgress);
			loader.addEventListener(IOErrorEvent.IO_ERROR, OnError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, OnError);

			loader.load(new URLRequest(mUrl));
		}
	}
	
	private function OnURLStreamComplete(e:Event, cacheItem : CacheItem):void
	{
		CreateLoaderFromByteArray(cacheItem.TheByteArray);
	}
	
	private function CreateLoaderFromByteArray(byteArray:ByteArray):void
	{
		var swfLoader : Loader = new Loader();
		mLoader = swfLoader;

		swfLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, OnLoaded);
		swfLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, OnError);
		swfLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, OnError);
		
		var context : LoaderContext = null;
		if (mAppDomain != null)
			context = new LoaderContext(false, mAppDomain);
		
		swfLoader.loadBytes(byteArray, context);
	}

	private function OnProgress(event:ProgressEvent):void
	{
		if (event.bytesLoaded == mLastBytesLoaded)
			return;

		if (mOnProgress != null)
			mOnProgress(this, event.bytesLoaded-mLastBytesLoaded, event);

		mLastBytesLoaded = event.bytesLoaded;
	}

	private function OnLoaded(event:Event):void
	{
		if (mOnLoaded != null)
			mOnLoaded(this);
	}

	private function OnError(event:Event):void
	{
		trace("LoadHelper: Error loading: " + mUrl);

		mLoader = null;

		if (mOnLoaded != null)
			mOnLoaded(this);
	}

	private var mIsDisplayObject : Boolean = false;
 	private var mUrl : String = "";
 	private var mLoader : Object;
 	private var mOnLoaded : Function = null;
 	private var mOnProgress : Function = null;
 	private var mAppDomain : ApplicationDomain = null;
 	private var mLastBytesLoaded : int = 0;
}
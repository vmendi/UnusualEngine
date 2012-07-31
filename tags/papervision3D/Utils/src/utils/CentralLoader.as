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

			mQueues["Default"] = new QueueLoader("Default", null, this);
		}

		public function Load(url:String, isDisplayObject:Boolean, onSuccess:Function, appDom:ApplicationDomain=null) : void
		{
			var newLoader : LoadHelper = new LoadHelper(mBaseUrl+url, isDisplayObject, OnImmediateLoaded, null, appDom);
			newLoader.OnSuccess = onSuccess;
			newLoader.Load();

			mImmediates.push(newLoader);
		}

		private function OnImmediateLoaded(loaded : LoadHelper):void
		{
			ArrayUtils.removeValueFromArray(mImmediates, loaded);

			if (loaded.TheLoader != null)
				loaded.OnSuccess(loaded.TheLoader);
			else
				dispatchEvent(new ErrorEvent("LoadError", false, false, "CentralLoader Error: " + loaded.URL));
		}


		public function CreateQueue(name:String, appDom:ApplicationDomain=null):void
		{
			if (mQueues.hasOwnProperty(name))
				throw "Already existent queue";

			mQueues[name] = new QueueLoader(name, appDom, this);
		}

		public function AddToQueue(url:String, isDisplayObject:Boolean, queueName:String="Default", onQueueuComplete:Function=null) : void
		{
			var composedURL : String = mBaseUrl + url;

			if (!mQueues.hasOwnProperty(queueName))
				throw "You must call to CreateQueue. What if no AddToQueue is done?";

			mQueues[queueName].Add(composedURL, isDisplayObject, onQueueuComplete);
		}

		public function LoadQueue(queueName:String="Default", onQueueComplete:Function=null) : void
		{
			mQueues[queueName].OnQueueComplete = onQueueComplete;
			mQueues[queueName].Load();
		}

		public function GetContentOfQueue(url:String, queueName:String="Default") : Object
		{
			return mQueues[queueName].GetLoadedContent(url);
		}

		public function DiscardQueue(queueName:String="Default") : void
		{
			delete mQueues[queueName];
		}

		public function DiscardAllQueues() : void
		{
			mQueues = new Dictionary();
			mQueues["Default"] = new QueueLoader("Default", null, this);
		}

		public function GetAppDomainOfQueue(queueName:String="Default"):ApplicationDomain
		{
			return mQueues[queueName].AppDomain;
		}

		public function SetTotalBytesOfQueue(bytes : int, q:String="Default") : void
		{
			mQueues[q].TotalBytes = bytes;
		}
		public function GetTotalBytesOfQueue(q:String="Default") : int
		{
			return mQueues[q].TotalBytes;
		}

		public function GetLoadedBytesOfQueue(q:String="Default") : int
		{
			return mQueues[q].LoadedBytes;
		}


		private var mBaseUrl : String = "";

		private var mQueues : Dictionary = new Dictionary;
		private var mImmediates : Array = new Array();
	}
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
		// Evitamos duplicados
		for each(var loadHelper : LoadHelper in LoadHelpers)
			if (url == loadHelper.URL)
				return;

		var newLoadHelper : LoadHelper = new LoadHelper(url, isDisplayObject, OnQueueElementLoaded, OnProgress, mAppAdomain);
		newLoadHelper.OnQueueComplete = onQueueuComplete;
		LoadHelpers.push(newLoadHelper);
	}

	public function Load():void
	{
		// Por ejemplo: LoadStart-Default
		mCentralLoader.dispatchEvent(new Event("LoadStart-" + mName));

		LoadedBytes = 0;
		RemainingToLoad = LoadHelpers.length;

		if (RemainingToLoad == 0)
			DispatchComplete();

		for each (var unique : LoadHelper in LoadHelpers)
			unique.Load();
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
			this.OnQueueComplete(new Event("LoadComplete-" + mName));

		mCentralLoader.dispatchEvent(new Event("LoadComplete-" + mName));
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

		var progressEvent : ProgressEvent = new ProgressEvent("LoadProgress-" + mName, false, false, LoadedBytes, TotalBytes);
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

	public function Load() : void
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
			var swfLoader : Loader = new Loader();
			mLoader = swfLoader;

			swfLoader.contentLoaderInfo.addEventListener("complete", OnLoaded);
			swfLoader.contentLoaderInfo.addEventListener("ioError", OnError);
			swfLoader.contentLoaderInfo.addEventListener("securityError", OnError);
			swfLoader.contentLoaderInfo.addEventListener("progress", OnProgress);

			var context : LoaderContext = null;
			if (mAppDomain != null)
				context = new LoaderContext(false, mAppDomain);

			swfLoader.load(new URLRequest(mUrl), context);
		}
		else
		{
			var loader : URLLoader = new URLLoader();
			mLoader = loader;

			loader.addEventListener("complete", OnLoaded);
			loader.addEventListener("ioError", OnError);
			loader.addEventListener("securityError", OnError);
			loader.addEventListener("progress", OnProgress);

			loader.load(new URLRequest(mUrl));
		}
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
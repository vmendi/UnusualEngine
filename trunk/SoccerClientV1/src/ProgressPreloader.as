package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.utils.getTimer;
	
	import mx.events.RSLEvent;
	import mx.preloaders.SparkDownloadProgressBar;
	

	/**
	 * http://www.leavethatthingalone.com/blog/index.cfm/2009/11/11/Flex4CustomPreloader
	 * http://help.adobe.com/en_US/flex/using/WS2db454920e96a9e51e63e3d11c0bf69084-7e3c.html#WS2db454920e96a9e51e63e3d11c0bf62d75-7fef
	 */
	public class ProgressPreloader extends SparkDownloadProgressBar
	{
		private var mPreloaderMovieclip : mcLoading;
		
		override protected function showDisplayForDownloading(elapsedTime:int, event:ProgressEvent):Boolean
		{
			return true;
		}
		
		override protected function showDisplayForInit(elapsedTime:int, count:int):Boolean
		{
			return true;
		}
		
		private function show() : void
		{
			// swfobject reports 0 sometimes at startup
			// if we get zero, wait and try on next attempt
			if (stageWidth == 0 && stageHeight == 0)
			{
				try
				{
					stageWidth = stage.stageWidth;
					stageHeight = stage.stageHeight
				}
				catch (e:Error)
				{
					stageWidth = loaderInfo.width;
					stageHeight = loaderInfo.height;
				}
				if (stageWidth == 0 && stageHeight == 0)
					return;
			}
			
			createChildren();
		}
		
		override protected function createChildren():void
		{    
			if (mPreloaderMovieclip == null)
			{
				mPreloaderMovieclip = new mcLoading();
				mPreloaderMovieclip.gotoAndStop(1);
				
				mPreloaderMovieclip.x = 0;
				mPreloaderMovieclip.y = 0;
				
				addChild(mPreloaderMovieclip);
			}
		}
		
		override protected function initCompleteHandler(event:Event):void
		{
			dispatchEvent(new Event(Event.COMPLETE)); 
		}
		
		override protected function rslProgressHandler(evt:RSLEvent):void
		{
			/*
			if (evt.rslIndex && evt.rslTotal)
			{
				mRslBaseText = "loading RSL " + evt.rslIndex + " of " + evt.rslTotal + ": ";
			}
			*/
		}
		
		override protected function setDownloadProgress(completed:Number, total:Number):void 
		{
			if (mPreloaderMovieclip == null)
				show();
			
			/*
			if (mPreloaderMovieclip != null)
			{
				mPreloaderMovieclip.gotoAndStop(100*completed/total);
			}
			*/
		}
		
		override protected function setInitProgress(completed:Number, total:Number):void
		{
			/*
			if (mPreloaderMovieclip)
			{
				setDownloadProgress(100, 100);
			}
			*/
		}
		
		override protected function initProgressHandler(event:Event):void
		{
		}
	}
}
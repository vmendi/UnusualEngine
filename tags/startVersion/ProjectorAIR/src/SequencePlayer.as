package
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.system.ApplicationDomain;
	import flash.ui.Keyboard;

	import gs.TweenMax;

	import mx.core.UIComponent;

	import utils.CentralLoader;

	public final class SequencePlayer extends UIComponent
	{
		public function SequencePlayer(xml : XML, centralLoader : CentralLoader, netConnection : NetConnection)
		{
			mCentralLoader = centralLoader;
			mNetConnection = netConnection;

			mSteps = new Array();

			for each(var stepXML : XML in xml.child("step"))
			{
				var kind : String = stepXML.attribute("kind").toString();
				var url : String = stepXML.url.toString();

				if (kind == "swf" || kind == "pict")
				{
					var showTime : Number = parseFloat(stepXML.showTime.toString());
					mCentralLoader.AddToQueue(url, true);

					mSteps.push( { Kind:kind, URL:url, ShowTime:showTime } );
				}
				else
				if (kind == "video")
				{
					var swf:String = stepXML.overlaySWF.toString();

					if (swf != "")
						mCentralLoader.AddToQueue(swf, true);

					mSteps.push( { Kind:kind, URL:url, OverlaySWF:swf } );
				}
				else
					throw "Unrecognized sequence step kind";
			}
		}

		public function Start(parent:UIComponent, continuousMode : Boolean, visibleTextsMode : Boolean):void
		{
			parent.addChild(this);

			mContinuousMode = continuousMode;
			mVisibleTextsMode = visibleTextsMode;

			this.width = parent.width;
			this.height = parent.height;

			stage.addEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);

			ExecuteNextStep();
		}

		public function Stop():void
		{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);

			StopVideoIfPlaying();
			StopTweenings();
			DeleteAllChildren();

			mCurrentStep = -1;

			parent.removeChild(this);
		}

		private function DeleteAllChildren() : void
		{
			while(numChildren > 0)
				removeChildAt(numChildren-1);

			mPrevious = null;
			mCurrent = null;
		}

		private function StopTweenings():void
		{
			for (var c:int=0; c < numChildren; c++)
				TweenMax.killTweensOf(getChildAt(c));
		}

		private function ExecuteNextStep() : void
		{
			mCurrentStep++;

			if (mCurrentStep < mSteps.length)
			{
				var currStep : Object = mSteps[mCurrentStep];

				if (currStep.Kind == "video")
					PlayVideo(currStep.URL, currStep.OverlaySWF);
				else
				if (currStep.Kind == "pict" || currStep.Kind == "swf")
					PlayPicture(currStep.URL, currStep.ShowTime);
			}
			else
			if (mContinuousMode)
			{
				mCurrentStep = -1;
				ExecuteNextStep();
			}
			else
			{
				Stop();
				dispatchEvent(new Event("SequenceEnd"));
			}
		}

		private function PlayPicture(url:String, showTime:Number):void
		{
			mPrevious = mCurrent;

			mCurrent = (mCentralLoader.GetContentOfQueue(url) as Loader).content;
			addChild(mCurrent);

			PrepareMovieClip(mCurrent as MovieClip);

			if (IsPreviousNotVideo())
			{
				mCurrent.alpha = 0.0;
				TweenMax.to(mCurrent, 1, { alpha:1.1, onComplete:OnPictAlphaCompleted, onCompleteParams:[showTime] });
			}
			else
				OnPictAlphaCompleted(showTime);
		}

		private function IsPreviousNotVideo() : Boolean { return mPrevious != null && (mVideo == null); }

		private function PrepareMovieClip(mc:MovieClip):void
		{
			if (mc != null)
			{
				mc.mcContenido.gotoAndStop(1);
				mc.mcContenido.mcTexto.visible = true;
			}
		}

		private function OnPictAlphaCompleted(showTime:Number):void
		{
			RemovePreviousInSequence();
			StopVideoIfPlaying();

			if (mCurrent is MovieClip)
				(mCurrent as MovieClip).mcContenido.gotoAndPlay(1);

			if (mContinuousMode)
				TweenMax.to(mCurrent, showTime, { onComplete:OnPictureCompleted } );
		}

		private function OnPictureCompleted():void
		{
			ExecuteNextStep();
		}

		private function PlayVideo(url:String, overlaySWF:String):void
		{
			StopVideoIfPlaying();

			// No removemos el anterior hasta que el video no notifique que está playeando
			mVideo = new Video(this.width, this.height);

			// Parent comun, para componer con el overlay
			mCurrent = new UIComponent();
			mCurrent.width = this.width;
			mCurrent.height = this.height;

			(mCurrent as UIComponent).addChild(mVideo);
			addChild(mCurrent);

			if (overlaySWF != "")
			{
				var theLoader : Loader = (mCentralLoader.GetContentOfQueue(overlaySWF) as Loader);
				var appDomain : ApplicationDomain = theLoader.contentLoaderInfo.applicationDomain;
				var theClass : Class = appDomain.getDefinition("mcContenido") as Class;
				var overlay : MovieClip = new theClass;
				(mCurrent as UIComponent).addChild(overlay);
			}

 			var nsClient : Object = new Object();
			nsClient.onMetaData = OnMetaData;
            nsClient.onCuePoint = OnCuePoint;
            nsClient.onPlayStatus = OnPlayStatus;

			mNetStream = new NetStream(mNetConnection);
			mNetStream.addEventListener(NetStatusEvent.NET_STATUS, OnNetStreamStatusHandler);
			mNetStream.client = nsClient;
			mVideo.attachNetStream(mNetStream);
			mNetStream.play(url);
		}

		private function RemovePreviousInSequence():void
		{
			if (mPrevious != null)
			{
				removeChild(mPrevious);
				mPrevious = null;
			}
		}

		private function StopVideoIfPlaying():void
		{
			if (mVideo != null)
			{
				mNetStream.close();

				mVideo = null;
				mNetStream = null;
			}
		}

		private function OnMetaData(item:Object):void   { /*trace("OnMetadata");*/ }
		private function OnCuePoint(item:Object):void   { /*trace("OnCuePoint");*/ }
		private function OnPlayStatus(item:Object):void { /*trace("OnPlayStatus");*/ }

		private function OnNetStreamStatusHandler(event:NetStatusEvent):void
		{
			if (event.info.code == "NetStream.Play.Stop")
				ExecuteNextStep();
			else
			if (event.info.code == "NetStream.Play.Start")
				RemovePreviousInSequence();
		}

		private function OnKeyDown(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.SPACE)
			{
				StopTweenings();
				ExecuteNextStep();
			}
			else
			if (String.fromCharCode(event.charCode) == 's')
			{
				Stop();
				dispatchEvent(new Event("SequenceEnd"));
			}
		}


		private var mSteps : Array = null;
		private var mCurrentStep : int = -1;

		private var mPrevious : DisplayObject = null;
		private var mCurrent : DisplayObject = null;

		private var mCentralLoader : CentralLoader;
		private var mNetConnection : NetConnection;
		private var mNetStream : NetStream;
		private var mVideo : Video;

		private var mContinuousMode : Boolean = true;
		private var mVisibleTextsMode : Boolean = true;
	}
}

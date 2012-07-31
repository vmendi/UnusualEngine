package
{
	import com.facebook.Facebook;
	import com.facebook.commands.users.GetInfo;
	import com.facebook.data.users.FacebookUser;
	import com.facebook.data.users.GetInfoData;
	import com.facebook.data.users.GetInfoFieldValues;
	import com.facebook.events.FacebookEvent;
	import com.facebook.net.FacebookCall;
	import com.facebook.utils.FacebookSessionUtil;
	
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.navigateToURL;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.messaging.Channel;
	import mx.messaging.ChannelSet;
	import mx.messaging.channels.AMFChannel;
	import mx.messaging.config.ServerConfig;

	public final class FacebookFacade extends EventDispatcher
	{		
		public function Init(callback:Function, requestedFakeSessionKey : String = null) : void
		{
			mSuccessCallback = callback;
			
			// Si no es la primera vez...
			if (SessionKey != null)
			{
				ResetFakeSessionKey(callback, requestedFakeSessionKey);
			}
			else
			{		
				var parameters : Object = FlexGlobals.topLevelApplication.parameters;
				var loaderInf : LoaderInfo = FlexGlobals.topLevelApplication.loaderInfo;
				
				if (IsFakeRequest() || requestedFakeSessionKey != null)
				{
					if (requestedFakeSessionKey == null)
					{
						if (parameters.hasOwnProperty("FakeSessionKey"))
							mFakeSessionKey = parameters.FakeSessionKey;
						else
							mFakeSessionKey = "0";
					}
					else
						mFakeSessionKey = requestedFakeSessionKey;
					
					SetWeborbSessionKey();
					
					mSuccessCallback();
				}
				else
				if (!parameters.hasOwnProperty("fb_sig_added"))
				{
					// No existe el parametro -> no accedidos desde facebook
					navigateToURL(new URLRequest("http://apps.facebook.com/mahoudev"), "_top");
				}
				else if (parameters.fb_sig_added == true)
				{
					mFBSession = new FacebookSessionUtil(parameters.fb_sig_api_key, null, loaderInf);
					mFB = mFBSession.facebook;
					mFBSession.addEventListener(FacebookEvent.CONNECT, OnFacebookConnect);
					mFBSession.verifySession();
				}
				else if (parameters.fb_sig_added == false)
				{
					navigateToURL(new URLRequest("http://www.facebook.com/login.php?api_key="+parameters.fb_sig_api_key),"_top");
				}
			}
		}
		
		private function ResetFakeSessionKey(callback:Function, requestedFakeSessionKey : String) : void
		{
			if (requestedFakeSessionKey == null)
				throw "Invalid requested fake session key";
			
			mFakeSessionKey = requestedFakeSessionKey;
			SetWeborbSessionKey();
			
			// Tenemos que asegurar que la SessionKey está insertada en la BDD en el server
			EnsureSessionIsCreatedOnServer(mFakeSessionKey, callback);
		}
		
		public function SetWeborbSessionKey() : void
		{
			var current : String = ServerConfig.xml[0].channels.channel.(@id=='my-amf').endpoint.@uri;
			ServerConfig.xml[0].channels.channel.(@id=='my-amf').endpoint.@uri = current + "?SessionKey=" + SessionKey;
		}		
		
		private function EnsureSessionIsCreatedOnServer(sessionKey : String, onCompleted:Function) : void
		{
			var domainBase : String = new RegExp(".*(?=SoccerClientV1\/.*\.swf)", "g").exec(FlexGlobals.topLevelApplication.url);
			
			var request : URLRequest = new URLRequest(domainBase + "TestCreateSession.aspx?FakeSessionKey="+sessionKey);
			request.method = URLRequestMethod.POST;
			
			mSessionKeyURLLoader = new URLLoader();
			mSessionKeyURLLoader.addEventListener("complete", onLoaded);
			mSessionKeyURLLoader.load(request);
			
			function onLoaded(e:Event) : void
			{
				onCompleted();	
			}
		}
		
		private function IsFakeRequest() : Boolean
		{
			return FlexGlobals.topLevelApplication.parameters.hasOwnProperty("FakeSessionKey") || IsRequestFromFile();
		}
		
		private function IsRequestFromFile() : Boolean
		{
			return FlexGlobals.topLevelApplication.url.indexOf("file:") != -1;
		}
		
		public function get SessionKey() : String
		{
			if (mFakeSessionKey != null)
				return mFakeSessionKey;
			
			if (mFB != null)
				return mFB.session_key;
			
			return null;
		}
		
		public function get FacebookID() : String
		{
			if (mFakeSessionKey != null)
				return mFakeSessionKey;
			
			if (mFB != null)
				return mFB.uid;
			
			return null;
		}
		
		protected function OnFacebookConnect(event:FacebookEvent):void
		{
			mFBSession.removeEventListener(FacebookEvent.CONNECT, OnFacebookConnect);
						
			if(event.success)
			{
				// La sesión esta OK => Ya tenemos SessionKey
				SetWeborbSessionKey();
				
				mSuccessCallback();
			}
			else
			{
				ErrorMessages.FacebookConnectionError();
			}
		}			

				
		private var mFakeSessionKey : String;
		
		private var mSuccessCallback : Function;
		private var mFB:Facebook;
		private var mFBSession:FacebookSessionUtil;
						
		private var mSessionKeyURLLoader : URLLoader;
	}
}
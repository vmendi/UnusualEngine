package GameComponents.Desafiate
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;

	public final class AtlasManager
	{
		static public function CallToUrl(url : String):void
		{
			var ebRand : Number = Math.random();
			ebRand = ebRand * 1000000;

			var theRequest : URLRequest = new URLRequest(url + '&rnd='+ ebRand);

			mLoader = new URLLoader();
			theRequest.method = URLRequestMethod.GET;
			mLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, Unsuscribe);
			mLoader.addEventListener(IOErrorEvent.IO_ERROR, Unsuscribe);
			mLoader.addEventListener(Event.COMPLETE, Unsuscribe);
			mLoader.load(theRequest);
		}

		static private function Unsuscribe(e:Event):void
		{
			(e.target as URLLoader).removeEventListener(IOErrorEvent.IO_ERROR, Unsuscribe);
			(e.target as URLLoader).removeEventListener(SecurityErrorEvent.SECURITY_ERROR, Unsuscribe);
			(e.target as URLLoader).removeEventListener(Event.COMPLETE, Unsuscribe);
		}

		static private var mLoader : URLLoader;
	}
}
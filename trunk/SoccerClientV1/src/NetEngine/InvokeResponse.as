package NetEngine
{
	public final class InvokeResponse
	{
		public var Client : Object;
		public var Callback : Function;
		
		// The client is owner othe callback. When the client is removed from the netplug, the response is discarded.
		public function InvokeResponse(cl : Object, callback : Function)
		{
			Client = cl;
			Callback = callback;
		}
	}
}
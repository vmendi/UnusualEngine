package NetEngine
{
	internal final class NetInvokeMessage
	{
		public var InvokationID : int;
		public var ReturnID : int;
		public var WantsReturn : Boolean;
		public var MethodName : String;
		public var Params : Array;
	}
}
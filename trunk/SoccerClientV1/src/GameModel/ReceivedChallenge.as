package GameModel
{
	import flash.events.EventDispatcher;

	[Bindable]
	public final class ReceivedChallenge extends EventDispatcher
	{
		public var SourcePlayer : RealtimePlayer;
		
		public var Message : String;
		public var MatchLengthSeconds : int;
		public var TurnLengthSeconds : int;
		
		public function ReceivedChallenge(fromServer : Object)
		{
			Message = fromServer.Message;
			MatchLengthSeconds = fromServer.MatchLengthSeconds;
			TurnLengthSeconds = fromServer.TurnLengthSeconds;
		}
	}
}
package GameModel
{
	import SoccerServerV1.TransferModel.vo.TeamDetails;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	public final class RealtimePlayer extends EventDispatcher
	{
		public var ClientID : int;
		public var FacebookID : String;
		public var Name : String;
		public var PredefinedTeamName : String;
		public var TrueSkill : Number;
		
		public var TheTeamDetails : TeamDetails;
		
		public var IsChallengeTarget : Boolean = false; 
		public var IsChallengeSource : Boolean = false;
		
		public function RealtimePlayer(fromServer : Object)
		{
			if (fromServer != null)
				for (var val : String in fromServer)
					this[val]= fromServer[val];
		}
	}
}
package GameComponents.PlanetWars
{
	import GameComponents.GameComponent;

	public class NetworkSync extends GameComponent
	{
		public var AttachTo : String = "";

		public function InitFromServer(uuid : int):void
		{
			mUUID = uuid;
			mAttachedTo = TheAssetObject.FindGameComponentByShortName(AttachTo);
		}

		public function get AttachedTo() : GameComponent { return mAttachedTo; }
		public function get UUID() : int { return mUUID; }

		private var mAttachedTo : GameComponent;
		private var mUUID : int;
	}
}
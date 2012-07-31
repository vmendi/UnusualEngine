package GameComponents.PlanetWars
{
	import GameComponents.GameComponent;

	public class Player extends GameComponent
	{
		public function InitFromServer(playerStatusFromServer : Object):void
		{
			mUserID = playerStatusFromServer.UserID;
			mIsLocalPlayer = TheGameModel.FindGameComponentByShortName("PlanetWarsServerConnect").IsSelfUserID(mUserID);

			ReadDynamicVarsFromServer(playerStatusFromServer);

			mPlanet = TheGameModel.FindGameComponentByShortName("Planet") as Planet;
			mPlanet.AddPlayer(this);
		}

		public function FromServerTurnUpdate(command:Object):void
		{
			ReadDynamicVarsFromServer(command);
		}

		private function ReadDynamicVarsFromServer(fromServer : Object):void
		{
			mGold = fromServer.Gold;
			mScience = fromServer.Science;
			mGoldPerTurn = fromServer.GoldPerTurn;
			mSciencePerTurn = fromServer.SciencePerTurn;
			mLaborPerTurn = fromServer.LaborPerTurn;
		}

		public function get UUID() : int { return TheAssetObject.FindGameComponentByShortName("NetworkSync").UUID; }

		public function get IsLocalPlayer() : Boolean { return mIsLocalPlayer; }
		public function get Gold() : int { return mGold; }
		public function get Science() : int { return mScience; }
		public function get GoldPerTurn() : int { return mGoldPerTurn; }
		public function get SciencePerTurn() : int { return mSciencePerTurn; }
		public function get LaborPerTurn() : int { return mLaborPerTurn; }

		private var mUserID : int = -1;
		private var mGold : int = -1;
		private var mScience : int = -1;
		private var mGoldPerTurn : int = -1;
		private var mSciencePerTurn : int = -1;
		private var mLaborPerTurn : int = -1;
		private var mIsLocalPlayer : Boolean = false;

		private var mPlanet : Planet;
	}
}
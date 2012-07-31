package GameComponents.PlanetWars
{
	import GameComponents.GameComponent;

	import flash.events.Event;

	public class Planet extends GameComponent
	{
		public override function OnStart():void
		{
			// Está garantizado que el servidor lo manda antes que el Planeta
			mTerrain = TheGameModel.FindGameComponentByShortName("Terrain") as Terrain;
		}

		public function InitFromServer(planetFromServer : Object) : void
		{
		}

		// El servidor llama aquí para indicar que ha terminado la primera transmisión completa del planeta
		public function FromServerPlanetReady(params : Object) : void
		{
			TheGameModel.FindGameComponentByShortName("PlanetWarsMain").StartGame();
		}

		public function FromServerTurnUpdateEnd(params : Object) : void
		{
			// Nos llaman desde el servidor a acabar el turno -> Dispachamos a quien escuche (PlanetWarsController...)
			dispatchEvent(new Event("ServerTurnUpdateEnd"));
		}

		public function AddPlayer(player : Player):void
		{
			mPlayers.push(player);

			if (player.IsLocalPlayer)
				mLocalPlayer = player;
		}

		public function get TheLocalPlayer() : Player { return mLocalPlayer; }

		private var mLocalPlayer : Player;
		private var mPlayers : Array = new Array;
		private var mTerrain : Terrain;
	}
}
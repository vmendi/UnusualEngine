package GameComponents.PlanetWars
{
	import GameComponents.GameComponent;

	import com.adobe.serialization.json.JSON;

	import it.gotoandplay.smartfoxserver.SFSEvent;

	public class NetworkSyncManager extends GameComponent
	{
		public override function OnStart() : void
		{
			mNetworkSyncs = new Object();

			mServerConnect = TheGameModel.FindGameComponentByShortName("PlanetWarsServerConnect") as PlanetWarsServerConnect;
			SubscribeListeners();
		}

		private function SubscribeListeners() : void
		{
			mServerConnect.addEventListener(SFSEvent.onExtensionResponse, OnExtensionResponse);
		}

		private function OnExtensionResponse(evt:SFSEvent) : void
		{
			var type:String = evt.params.type;
		    var data:Object = evt.params.dataObj;

    		var command:String = data._cmd;

			if (command == "BatchUpdate")
				CommandBatchUpdate(data);
		}

		private function CommandBatchUpdate(update : Object) : void
		{
			update.Commands = JSON.decode(update.Commands);

			for each(var command : Object in update.Commands)
			{
				if (command.data.Method == "New")
					CommandNew(command.data);
				else
					CommandMethodCall(command.data);
			}
		}

		private function CommandNew(newObjData : Object) : void
		{
			var mcName : String = newObjData.MovieClip;
			var type : String = newObjData.Type;

			var newlyCreated : GameComponent = TheGameModel.CreateSceneObjectFromMovieClip(mcName, type);

			// Creamos el NetworkSync que nos apoyará almacenando el UUID y el GameComponent al que delegamos commandos
			var ns : NetworkSync = newlyCreated.TheAssetObject.AddGameComponent("GameComponents.PlanetWars::NetworkSync") as NetworkSync;

			if (mNetworkSyncs[newObjData.UUID] != null)
				throw "Duplicated UUID received";

			mNetworkSyncs[newObjData.UUID] = ns;
			ns.AttachTo = type;
			ns.InitFromServer(newObjData.UUID);

			newlyCreated.InitFromServer(newObjData);
		}

		private function CommandMethodCall(command : Object) : void
		{
			var uuid : int = command.UUID;
			var found : NetworkSync = mNetworkSyncs[uuid];

			if (found == null)
				throw "NetworkSync not found";

			// Llamamos directamente a la función del mismo nombre para no tener que hacer el switch.
			found.AttachedTo[command.Method](command);
		}

		public function FindGameComponentByUUID(uuid : int) : GameComponent
		{
			return (mNetworkSyncs[uuid] as NetworkSync).AttachedTo;
		}

		private var mServerConnect : PlanetWarsServerConnect;
		private var mNetworkSyncs : Object;
	}
}
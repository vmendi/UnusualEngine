package GameComponents.PlanetWars
{
	import GameComponents.GameComponent;
	
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	
	import utils.Point3;

	public class City extends GameComponent
	{
		public function InitFromServer(cityFromServer : Object) : void
		{
			var nsManager : NetworkSyncManager = TheGameModel.FindGameComponentByShortName("NetworkSyncManager") as NetworkSyncManager;
			mPlayer = nsManager.FindGameComponentByUUID(cityFromServer.PlayerOwnerUUID) as Player;

			TheIsoComponent.WorldPos = new Point3(cityFromServer.PosX, 0, cityFromServer.PosY);
			mSize = cityFromServer.Size;
			mFoodOnStore = cityFromServer.FoodOnStore;
			mIsCapital = cityFromServer.IsCapital;

			if (mIsCapital && mPlayer.IsLocalPlayer)
				TheGameModel.TheIsoCamera.TargetPos = new Point(TheIsoComponent.WorldPos.x, TheIsoComponent.WorldPos.z);

			mProductionQueue = new ArrayCollection();

			mAvailableBuildings = new ArrayCollection(["Infantry Barracks", "Bank", "Air base", "Tank factory"]);
			mAvailableUnits = new ArrayCollection(["Marine division", "Tank", "Cannon", "F-36", "Battlestar"]);

			mUnits = new ArrayCollection();
			for each(var unit : Object in cityFromServer.Units)
			{
				mUnits.addItem(unit as String);
			}

			mBuildings = new ArrayCollection();
			for each(var building : Object in cityFromServer.Buildings)
			{
				mBuildings.addItem(building as String);
				if (mAvailableBuildings.contains(building))
					mAvailableBuildings.removeItemAt(mAvailableBuildings.getItemIndex(building));
			}

			UpdateVisuals();
		}

		public function FromServerTurnUpdate(command:Object):void
		{
			mSize = command.Size;
			mFoodOnStore = command.FoodOnStore;

			UpdateVisuals();
		}
		
		public function RemoveBuildingFromAvailable(name : String):void
		{
			mAvailableBuildings.removeItemAt(mAvailableBuildings.getItemIndex(name));			
		}

		public function FromServerNewBuilded(data:Object):void
		{
			var name : String = data.Name;

			if (mAvailableBuildings.contains(name))
				mBuildings.addItem(name);
			else
			if (mAvailableUnits.contains(name))
				ReplaceOrAddUnit(name, data.CountAndName);
			else
				throw "Unit or building not among the available";
		}

		public function FromServerProductionQueueUpdated(data:Object):void
		{
			mProductionQueue.removeAll();

			for (var c:int=0; c < data.Names.length; c++)
				mProductionQueue.addItem(data.Names[c]);

			mProductionPoints = data.Points;
		}

		private function ReplaceOrAddUnit(unitName : String, newCountAndName : String) : void
		{
			var indexAlreadyThere : int = GetIndexOfUnit(unitName);

			if (indexAlreadyThere != -1)
				mUnits.setItemAt(newCountAndName, indexAlreadyThere);
			else
				mUnits.addItem(newCountAndName);
		}

		private function GetIndexOfUnit(unitName : String) : int
		{
			for (var c:int=0; c < mUnits.length; c++)
				if (mUnits[c].indexOf(unitName) != -1)
					return c;
			return -1;
		}

		public function get UUID() : int { return TheAssetObject.FindGameComponentByShortName("NetworkSync").UUID; }

		public function get Size() : int { return mSize; }
		public function get FoodOnStore() : int { return mFoodOnStore; }

		public function get AvailableUnits() : ArrayCollection { return mAvailableUnits; }
		public function get AvailableBuildings() : ArrayCollection { return mAvailableBuildings; }

		public function get Units() : ArrayCollection { return mUnits; }
		public function get Buildings() : ArrayCollection { return mBuildings; }

		public function get ProductionQueue() : ArrayCollection { return mProductionQueue; }
		public function get ProductionPoints() : int { return mProductionPoints; }

		private function UpdateVisuals() : void
		{
			TheVisualObject.mcSize.ctSize.text = mSize.toString();
		}

		private var mPlayer : Player;
		private var mSize : int = -1;
		private var mFoodOnStore : int = -1;
		private var mIsCapital : Boolean = false;

		private var mAvailableUnits : ArrayCollection;
		private var mAvailableBuildings : ArrayCollection;
		private var mUnits : ArrayCollection;
		private var mBuildings : ArrayCollection;
		private var mProductionQueue : ArrayCollection;
		private var mProductionPoints:int=-1;
	}
}
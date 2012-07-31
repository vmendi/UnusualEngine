package GameComponents.PlanetWars
{
	import Model.GameModel;

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import utils.GenericEvent;
	import utils.Point3;

	public class PlanetWarsController extends EventDispatcher
	{
		[Bindable]
		public function get TheSelectedCity() : City { return mSelectedCity; }
		public function set TheSelectedCity(city : City) : void { mSelectedCity = city; }

		public function PlanetWarsController(model : GameModel)
		{
  			mModel = model;

			mServerConnect = mModel.FindGameComponentByShortName("PlanetWarsServerConnect") as PlanetWarsServerConnect;
			mPlanet = mModel.FindGameComponentByShortName("Planet") as Planet;

			SubscribeListeners();
		}

		private function SubscribeListeners() : void
		{
			mPlanet.addEventListener("ServerTurnUpdateEnd", ServerTurnUpdateEnd);
			mPlanet.addEventListener("CityClick", OnCityClicked);
		}

		private function ServerTurnUpdateEnd(event:Event):void
		{
			dispatchEvent(event);
		}

		private function OnCityClicked(event:GenericEvent):void
		{
			TheSelectedCity = event.Data as City;
		}

		public function AddBuildableToQueue(name:String):void
		{
			if (TheSelectedCity != null)
			{
				if (TheSelectedCity.AvailableBuildings.contains(name))
					TheSelectedCity.RemoveBuildingFromAvailable(name);

				var params : Object = new Object();
				params.Method = "AddBuildableToQueue";
				params.UUID = TheSelectedCity.UUID;
				params.Name = name;

				mServerConnect.SendCommand("MethodCall", params);
			}
		}

		public function BeginCityCreation() : void
		{
			mMode = "CITY_CREATION";
		}

		public function OnRenderCanvasClick(event:MouseEvent):void
		{
			if (mMode == "CITY_CREATION")
			{
				var stageMouse : Point = new Point(event.stageX, event.stageY);
				var onRenderCanvasPos : Point = mModel.TheRenderCanvas.globalToLocal(stageMouse);
				var worldPos : Point3 = mModel.TheIsoCamera.IsoScreenToWorld(onRenderCanvasPos);
				worldPos = GameModel.GetSnappedWorldPos(worldPos);

				var params : Object = new Object();
				params.Method = "CreateCity";
				params.UUID = mPlanet.TheLocalPlayer.UUID;
				params.WorldPosX = worldPos.x as int;
				params.WorldPosY = worldPos.z as int;

				mServerConnect.SendCommand("MethodCall", params);

				mMode = "";
			}
		}

		public function Cancel() : void
		{
			mMode = "";
		}

		// La vista necesitará subscribirse y acceder a datos del modelo
		public function get ThePlanet() : Planet { return mPlanet; }

		// Temp para GalaxyInterace
		public function get TheGameModel() : GameModel { return mModel; }

		private var mServerConnect : PlanetWarsServerConnect;
		private var mModel : GameModel;
		private var mPlanet : Planet;

		private var mMode : String = "NONE";
		private var mSelectedCity : City;
	}
}
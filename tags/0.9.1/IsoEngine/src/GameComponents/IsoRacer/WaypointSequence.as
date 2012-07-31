package GameComponents.IsoRacer
{
	import GameComponents.GameComponent;
	import GameComponents.Vehicle;
	
	import Model.UpdateEvent;
	
	import flash.geom.Point;
	
	import utils.Point3;

	public class WaypointSequence extends GameComponent
	{
		public function IsSequenceCompleted() : Boolean { return mRemainingWaypoints <= 0; }
		
		override public function OnStart() : void
		{
			mVehicle = TheGameModel.FindGameComponentByShortName("Vehicle") as Vehicle;
			
			mWaypoints = TheGameModel.FindAllGameComponentsByShortName("Waypoint");
			mWaypoints.sortOn("Order", Array.NUMERIC);
			
			for each(var w : Waypoint in mWaypoints)
				w.SetVisible(false);
			
			if (mWaypoints.length > 0)
				(mWaypoints[0] as Waypoint).SetVisible(true);

			//mWaypoints.splice(1, 100);

			mRemainingWaypoints = mWaypoints.length;			
			TheVisualObject.ctGoals.text = mRemainingWaypoints.toString();
		}
		
		override public function OnUpdate(event:UpdateEvent):void
		{
			if (mRemainingWaypoints <= 0)
				return;
				
			var carPos : Point = new Point(mVehicle.TheIsoComponent.WorldPos.x, mVehicle.TheIsoComponent.WorldPos.z);
			
			if (mWaypoints[CurrentWaypointIndex].TestCollision(carPos))
			{
				mWaypoints[CurrentWaypointIndex].SetVisible(false);
				
				mRemainingWaypoints--;				
				TheVisualObject.ctGoals.text = mRemainingWaypoints.toString();
				
				if (mRemainingWaypoints > 0)
					mWaypoints[CurrentWaypointIndex].SetVisible(true);
			}
		}
		
		public function get CurrentWaypointPos() : Point3
		{
			if (mRemainingWaypoints > 0)
				return mWaypoints[CurrentWaypointIndex].TheIsoComponent.WorldPos;
			return null;
		}
				
		private function get CurrentWaypointIndex() : int { return mWaypoints.length - mRemainingWaypoints; }
		
		
		
		private var mWaypoints : Array;
		private var mRemainingWaypoints : int;
		private var mVehicle : Vehicle;
	}
}
package GameComponents.IsoRacer
{
	import GameComponents.GameComponent;
		
	import Model.GameModel;
	import Model.UpdateEvent;
	
	import utils.Point3;
	
	public final class Navigator extends GameComponent
	{
		override public function OnStart():void
		{
			mWaypointSequence = TheGameModel.FindGameComponentByShortName("WaypointSequence") as WaypointSequence;
			mVehicle = TheGameModel.FindGameComponentByShortName("Vehicle") as Vehicle;
			mCellSizeInMeters = GameModel.CellSizeMeters;
		}
		
		override public function OnUpdate(event:UpdateEvent):void
		{
			var PosWayPoint : Point3 = mWaypointSequence.CurrentWaypointPos;
			if (PosWayPoint)
			{
				TheVisualObject.visible = true;

				var DifX : Number = (PosWayPoint.x - mVehicle.TheIsoComponent.WorldPos.x);
				DifX = (Math.abs(DifX)<mCellSizeInMeters*2) ? 0 : -(DifX/Math.abs(DifX));
				var DifZ : Number = (PosWayPoint.z - mVehicle.TheIsoComponent.WorldPos.z);
				DifZ = (Math.abs(DifZ)<mCellSizeInMeters*2) ? 0 : -(DifZ/Math.abs(DifZ));

				if ((DifX==0) && (DifZ==0)){
					TheVisualObject.gotoAndStop("pto0");
				} else {
					TheVisualObject.gotoAndStop("pto"+DifZ+DifX);
				}
			}
			else
			{
				TheVisualObject.visible = false;
			} 
		}
		
		private var mWaypointSequence : WaypointSequence;
		private var mVehicle : Vehicle;
		private var mCellSizeInMeters : Number;
		
	}
}
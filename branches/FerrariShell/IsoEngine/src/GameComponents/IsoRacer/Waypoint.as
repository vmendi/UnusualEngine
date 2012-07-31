package GameComponents.IsoRacer
{
	import GameComponents.GameComponent;
	import flash.geom.Point;
	
	
	public final class Waypoint extends GameComponent
	{
		public var Order : Number = 0;
		
		override public function OnStart():void
		{
			//mCharacterBehavior = TheGameModel.FindGameComponentByShortName("CharacterBehavior") as CharacterBehavior;
		}
		
		public function TestCollision(pos : Point) : Boolean
		{
			return TheIsoComponent.Bounds.IsPointInside(pos);
		}
		
		public function SetVisible(visible:Boolean) : void
		{
			TheVisualObject.visible = visible;
		}
		
		//private var mVehicle : CharacterBehavior;		
	}
}
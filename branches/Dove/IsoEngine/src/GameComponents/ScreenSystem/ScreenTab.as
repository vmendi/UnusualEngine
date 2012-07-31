package GameComponents.ScreenSystem
{
	import GameComponents.GameComponent;
	
	public class ScreenTab extends GameComponent
	{				
		public function get TheScreenNavigator() : ScreenNavigator { return mScreenNavigator; }
		

		override public function OnStart():void
		{
			mScreenNavigator = TheAssetObject.FindGameComponentByShortName("ScreenNavigator") as ScreenNavigator;
		}
		
		virtual public function OnScreenTabStart() : void
		{
		}
		
		virtual public function OnScreenTabEnd() : void
		{			
		}
				
		virtual public function get ScreenTabName() : String
		{
			return mScreenTabName == null? this.ShortName : mScreenTabName;
		}
		
		virtual public function set ScreenTabName(val : String) : void
		{
			mScreenTabName = val;
		}
					 
		
		private var mScreenTabName : String;
		private var mScreenNavigator : ScreenNavigator		
	}
}
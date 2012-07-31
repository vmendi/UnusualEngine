	package GameComponents
	{
		public class Screen extends GameComponent
		{				
			public function get TheScreenManager() : ScreenManager { return mScreenManager; }
			

			override public function OnStart():void
			{
				mScreenManager = TheAssetObject.FindGameComponentByShortName("ScreenManager") as ScreenManager;
			}
			
			virtual public function OnScreenStart() : void
			{
			}
			
			virtual public function OnScreenEnd() : void
			{			
			}
					
			virtual public function get ScreenName() : String
			{
				return mScreenName == null? this.ShortName : mScreenName;
			}
			
			virtual public function set ScreenName(val : String) : void
			{
				mScreenName = val;
			}
			
			 
			
			private var mScreenName : String;
			private var mScreenManager : ScreenManager		
		}
	}
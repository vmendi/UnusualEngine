package GameComponents.FerrariShell
{
	import GameComponents.GameComponent;

	public class RaceMain extends GameComponent
	{
		public var DefaultCar : String = "F2008";
		
		override public function OnStart() : void
		{		
			if (!TheGameModel.GlobalGameState.hasOwnProperty("UserID"))
				TheGameModel.GlobalGameState.UserID = "AKkxYIno0CLTA";

			var selectedCar : String = DefaultCar;
			
			if (TheGameModel.GlobalGameState.hasOwnProperty("SelectedCar"))
			{				
				if (TheGameModel.GlobalGameState.SelectedCar == 0)
					selectedCar = "F430";
				if (TheGameModel.GlobalGameState.SelectedCar == 1)
					selectedCar = "F599";
				if (TheGameModel.GlobalGameState.SelectedCar == 2)
					selectedCar = "F2008";
			}
			
			TheGameModel.CreateSceneObjectFromMovieClip(selectedCar, "Vehicle");
		}	
	}
}
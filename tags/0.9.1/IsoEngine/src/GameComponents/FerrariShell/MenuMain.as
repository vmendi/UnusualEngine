package GameComponents.FerrariShell
{
	import GameComponents.GameComponent;

	import flash.net.SharedObject;

	import mx.controls.Alert;

	public class MenuMain extends GameComponent
	{
		override public function OnStart():void
		{
			//TheGameModel.GlobalGameState.WorkUnconnected = true;
			TheGameModel.GlobalGameState.WorkUnconnected = false;

			TheGameModel.GlobalGameState.BDDServerBaseURL = "http://www.hazlorealidadconshell.com";
			TheGameModel.GlobalGameState.SelectedTrackName = null;
			TheGameModel.GlobalGameState.SelectedTrack = null;
			TheGameModel.GlobalGameState.SelectedCar = null;
			TheGameModel.GlobalGameState.GlobalMaxTrackScore = null;
			TheGameModel.GlobalGameState.PlayerMaxTrackScore = null;

			// Lectura del SharedObject según S.Angel
			var theSharedObject : SharedObject = SharedObject.getLocal("velocitaIII", "/");
			if (theSharedObject.data.userID != undefined)
				TheGameModel.GlobalGameState.UserID = theSharedObject.data.userID;
			else
				TheGameModel.GlobalGameState.UserID = "AKkxYIno0CLTA";

			TheGameModel.CreateSceneObjectFromMovieClip("MainInterface", "ScreenManager");
		}

	}
}
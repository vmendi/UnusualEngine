package GameComponents.FerrariShell
{
	import GameComponents.Screen;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLVariables;

	import mx.controls.Alert;

	import utils.Delegate;
	import utils.GenericEvent;
	import utils.Server;

	public class TrackSelection extends Screen
	{
		override public function OnScreenStart():void
		{
			if (TheGameModel.GlobalGameState.WorkUnconnected)
			{
				OpenCircuito(0);
				OpenCircuito(1);
				OpenCircuito(2);
			}
			else
			{
				var vars : URLVariables = new URLVariables();
				vars.request = <GetPlayerStatus>
							       <PlayerID id={TheGameModel.GlobalGameState.UserID}/>
							   </GetPlayerStatus>

				mServer = new Server(TheGameModel.GlobalGameState.BDDServerBaseURL);
				mServer.addEventListener("RequestError", OnRequestError);
				mServer.addEventListener("RequestComplete", OnRequestComplete);
				mServer.Request(vars, "/velocitaIII/user_estado.php");
			}
		}

		override public function OnScreenEnd():void
		{
			if (mServer != null)
			{
				mServer.removeEventListener("RequestComplete", OnRequestComplete);
				mServer.removeEventListener("RequestError", OnRequestError);
			}
		}

		private function OnRequestComplete(event:GenericEvent) : void
		{
			trace(event.Data);

			var minScoresForTracks : Array = [0, 0];

			var resultXML : XML = XML(event.Data);

			if (resultXML.@result.toString() == "OK")
			{
				for (var c:int=0; c < 3; c++)
				{
					var playerMaxScoreStr : String = resultXML.Circuitos.Circuito.(@num==c.toString()).@playerMaxScore.toString();
					var globalMaxScoreStr : String = resultXML.Circuitos.Circuito.(@num==c.toString()).@globalMaxScore.toString();
					var playerBestTimeStr : String = resultXML.Circuitos.Circuito.(@num==c.toString()).@playerBestTime.toString();
					var globalBestTimeStr : String = resultXML.Circuitos.Circuito.(@num==c.toString()).@globalBestTime.toString();

					var scoreInt : Number = parseInt(playerMaxScoreStr);

					TheVisualObject[mCirNames[c]].ctRecord.text = globalMaxScoreStr;
					TheVisualObject[mCirNames[c]].ctPuntos.text = playerMaxScoreStr;

					if (TheGameModel.GlobalGameState.UserID == "AKkxYIno0CLTA")
					{
						TheVisualObject[mCirNames[c]].ctPuntos.text = "0";
					}
					else
					{
						if (scoreInt > 0 && (c < 2))
						{
							OpenCircuito(c+1);
						}
					}
				}

				OpenCircuito(0);
			}
		}

		private function OpenCircuito(nCircuito : int):void
		{
			var cirName : String = mCirNames[nCircuito];

			TheVisualObject[cirName].gotoAndStop(2);
			TheVisualObject[cirName].btJugar.addEventListener(MouseEvent.CLICK, Delegate.create(OnBotonJugar, nCircuito));
		}

		private function OnBotonJugar(e:Event, nCircuito:int):void
		{
			var cirFiles : Array = [ "Maps/IsoRacer/EscritorioFinal.xml",
									 "Maps/IsoRacer/Room.xml",
									 "Maps/IsoRacer/Cocina.xml" ];

			TheGameModel.GlobalGameState.SelectedTrack = nCircuito;
			TheGameModel.GlobalGameState.SelectedTrackName = cirFiles[nCircuito];
			TheGameModel.GlobalGameState.PlayerMaxTrackScore = parseInt(TheVisualObject[mCirNames[nCircuito]].ctPuntos.text);
			TheGameModel.GlobalGameState.GlobalMaxTrackScore = parseInt(TheVisualObject[mCirNames[nCircuito]].ctRecord.text);
			TheScreenManager.GotoScreen("CarSelection");
		}

		private function OnRequestError(event:Event) : void
		{
			Alert.show("Error de conexión con el servidor. Por favor, recargue la página", "Error", Alert.OK);
		}

		private var mServer : Server;
		private var mCirNames : Array = [ "mcCircuito1Hacko", "mcCircuito2", "mcCircuito3" ];
	}
}
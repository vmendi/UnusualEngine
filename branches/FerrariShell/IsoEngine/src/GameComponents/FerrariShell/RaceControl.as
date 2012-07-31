package GameComponents.FerrariShell
{
	import GameComponents.GameComponent;

	import Model.UpdateEvent;

	import flash.events.Event;
	import flash.net.URLVariables;

	import mx.controls.Alert;

	import utils.GenericEvent;
	import utils.Server;
	import utils.TimeUtils;

	public class RaceControl extends GameComponent
	{
		public var StandAloneSelectedTrack : int = 0;
		public var StandAloneSelectedCar : int = 0;

		public var TrackMaxTimeSeconds : Number = 120.99;


		override public function OnStart():void
		{
			mRemainingTime = TrackMaxTimeSeconds;
			TheVisualObject.ctTime.text = TimeUtils.ConvertMilisecsToString(mRemainingTime*1000);

			if (GetSelectedTrack() == 0 && TheGameModel.GlobalGameState.hasOwnProperty("PlayerMaxTrackScore") &&
				TheGameModel.GlobalGameState.PlayerMaxTrackScore == 0)
			{
				// Cuando es la primera vez que jugamos al primer circuito, ponemos las instrucciones
				TheGameModel.FindGameComponentByShortName("Vehicle").EnableMovement(false);
				TheGameModel.CreateSceneObjectFromMovieClip("mcPopupInstrucciones", "InstruccionesPopup");
			}
			else
			{
				StartRace();
			}
		}

		public function GetSelectedTrack() : int
		{
			return TheGameModel.GlobalGameState.hasOwnProperty("SelectedTrack")?
									  TheGameModel.GlobalGameState.SelectedTrack :
									  StandAloneSelectedTrack;
		}

		public function GetSelectedCar() : int
		{
			return TheGameModel.GlobalGameState.hasOwnProperty("SelectedCar")?
				   TheGameModel.GlobalGameState.SelectedCar :
				   StandAloneSelectedCar;
		}

		public function StartRace():void
		{
			if (!TheGameModel.GlobalGameState.WorkUnconnected)
			{
				if (!TheGameModel.GlobalGameState.hasOwnProperty("BDDServerBaseURL"))
					TheGameModel.GlobalGameState.BDDServerBaseURL = "http://www.hazlorealidadconshell.com"

				var vars : URLVariables = new URLVariables();
				vars.request = <StartCircuito>
									<PlayerID id={TheGameModel.GlobalGameState.UserID}/>
									<Circuito id={GetSelectedTrack()}/>
									<Coche id={GetSelectedCar()}/>
									<TimeIni>{GetUTCTime()}</TimeIni>
								</StartCircuito>

				mServer = new Server(TheGameModel.GlobalGameState.BDDServerBaseURL);
				mServer.addEventListener("RequestError", OnRequestError);
				mServer.addEventListener("RequestComplete", OnStartRequestComplete);
				mServer.Request(vars, "/velocitaIII/user_start_circuito.php");
			}

			TheGameModel.FindGameComponentByShortName("Vehicle").EnableMovement(true);
			mStarted = true;
		}

		private function GetUTCTime() : Number
		{
			var now:Date = new Date();
          	var nowUTCTimestamp:Number = Date.UTC(now.fullYear, now.month, now.date, now.hours, now.minutes, now.seconds, now.milliseconds);
          	return nowUTCTimestamp;
		}

		private function OnStartRequestComplete(event:GenericEvent) : void
		{
			var xml : XML = XML(event.Data);

			if (xml.@result == "OK")
				mPartidaID = xml.PartidaID.@id.toString();
			else
				FatalServerError();
		}

		private function OnRequestError(event:Event) : void
		{
			FatalServerError();
		}

		private function FatalServerError() : void
		{
			Alert.show("Error de conexión con el servidor. Por favor, recargue la página", "Error", Alert.OK);
		}

		private function OnEndRequestComplete(event:GenericEvent) : void
		{
			ProcessFinalScreen();
		}

		private function ProcessFinalScreen():void
		{
			var mode : int = 4;			// Coincide con el final del nombre de la label
			if (mCompletedWithSuccess)
			{
				if (GetScore() < TheGameModel.GlobalGameState.PlayerMaxTrackScore)
				{
					mode = 0;
				}
				else {

					TheGameModel.GlobalGameState.PlayerMaxTrackScore = GetScore();

					if (GetScore() > TheGameModel.GlobalGameState.PlayerMaxTrackScore &&
						GetScore() < TheGameModel.GlobalGameState.GlobalMaxTrackScore)
					{
						mode = 1;
					}
					else
					{
						TheGameModel.GlobalGameState.GlobalMaxTrackScore = GetScore();
						mode = 2;
					}
				}
			}

			var finalPopup : FinalPopup = TheGameModel.CreateSceneObjectFromMovieClip("mcFinal", "FinalPopup") as FinalPopup;
			finalPopup.GotoMode(mode, GetScore());
		}

		public function ObjectiveCompleted(bSuccess:Boolean) : void
		{
			if (TheGameModel.GlobalGameState.WorkUnconnected)
			{
				OnEndRequestComplete(null);
			}
			else
			{
				var vars : URLVariables = new URLVariables();
				vars.request =  <EndCircuito>
									<PlayerID id={TheGameModel.GlobalGameState.UserID}/>
									<PartidaID id={mPartidaID}/>
									<TimeTotal>{GetPlayerElapsedTime()}</TimeTotal>
									<TimeFin>{GetUTCTime()}</TimeFin>
									<Score>{GetScore().toString()}</Score>
								</EndCircuito>

				mServer = new Server(TheGameModel.GlobalGameState.BDDServerBaseURL);
				mServer.addEventListener("RequestError", OnRequestError);
				mServer.addEventListener("RequestComplete", OnEndRequestComplete);
				mServer.Request(vars, "/velocitaIII/user_end_circuito.php");
			}

			mCompleted = true;
			mCompletedWithSuccess = bSuccess;

			TheGameModel.FindGameComponentByShortName("Vehicle").EnableMovement(false);
		}

		/* Tiempo que lleva jugando la carrera */
		private function GetPlayerElapsedTime() : String
		{
			return TimeUtils.ConvertMilisecsToString((TrackMaxTimeSeconds - mRemainingTime)*1000);
		}

		private function GetScore() : int
		{
			return Math.round(mRemainingTime * 1000);
		}

		override public function OnUpdate(event:UpdateEvent):void
		{
			if (mCompleted || !mStarted)
				return;

			if (TheGameModel.FindGameComponentByShortName("WaypointSequence").IsSequenceCompleted())
			{
				ObjectiveCompleted(true);
			}
			else
			{
				mRemainingTime -= event.ElapsedTime/1000;

				if (mRemainingTime <= 0)
				{
					mRemainingTime = 0;
					ObjectiveCompleted(false);
				}
				TheVisualObject.ctTime.text = TimeUtils.ConvertMilisecsToString(mRemainingTime*1000);
			}
		}

		private var mStarted : Boolean = false;
		private var mCompleted : Boolean = false;
		private var mCompletedWithSuccess : Boolean = true;
		private var mPartidaID : String;
		private var mRemainingTime : Number;
		private var mServer : Server;
	}
}
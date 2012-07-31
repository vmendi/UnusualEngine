package GameComponents.Desafiate
{
	import GameComponents.GameComponent;
	
	import flash.external.ExternalInterface;
	
	import mx.core.Application;
	import mx.core.FlexGlobals;


	public final class GameStatus extends GameComponent
	{
		public const LOGROS : Array = [
										{ Name:"Contratado",
										  Title:"¡Contratado!",
										  Content:"Acaban de contratarme en Contoso Inc. No ha sido fácil, pero lo he conseguido. Si crees que puedes hacerlo mejor, entra en el juego Desafíate de Microsoft e inténtalo.",
										  Img:"/logros/logros_contratado.jpg" },
										{ Name:"Empollon",
										  Title:"¡Esquivados!",
										  Content:"He tenido una pesadilla horrible. Estaba jugando a Desafiate de Microsoft y soñé que me atacaba una horda de pingüinos ¡afortunadamente he conseguido esquivarlos a todos!.",
										  Img:"/logros/logros_empollon.jpg" },
										{ Name:"Hacker",
										  Title:"¡Hacker!",
										  Content:"He conseguido averiguar la contraseña de uno de  mis compañeros de trabajo en el juego Desafíate de Microsoft. Sólo un verdadero hacker puede hacerlo.",
										  Img:"/logros/logros_hacker.jpg" },
										{ Name:"Consejo",
										  Title:"¡Miembro del consejo!",
										  Content:"Demostrando un conocimiento admirable he conseguido superar una de las pruebas más difíciles del juego Desafía te de Microsoft. Nadie puede conmigo.",
										  Img:"/logros/logros_miembro_consejo.jpg" },
										{ Name:"Heroe",
										  Title:"¡Héroe de la compañía!",
										  Content:"Una vez más he demostrado quien es el verdadero Jefe en el juego Desafíate de Microsoft. Entra e intenta superarme.",
										  Img:"/logros/logros_heroe_consejo.jpg" },
										{ Name:"Codigo",
										  Title:"¡Dios del Código!",
										  Content:"No hay bug que se me resista. Soy el verdadero gurú para los demás participantes del juego Desafíate de Microsoft.",
										  Img:"/logros/logros_dios_codigo.jpg" },
										{ Name:"Empleado",
										  Title:"¡Empleado del mes!",
										  Content:"Acabo de demostrar quien es el que manda en Contoso Inc. Entra en el juego Desafíate de Microsoft e intenta superarme.",
										  Img:"/logros/logros_empleado_mes.jpg" }
									   ];

		override public function OnPreStart():void
		{
			mMapUrl = TheGameModel.GameModelUrl;
			mGameStatus = TheGameModel.GlobalGameState.GameStatus;

			// Si no venimos de un mapa anterior, cargamos del servidor
			if (mGameStatus == null)
			{
				TheGameModel.GlobalGameState.GameStatus = new Object();
				mGameStatus = TheGameModel.GlobalGameState.GameStatus;
				InitStatus();
			}
		}

		private function InitStatus() : void
		{
			if (!TheGameModel.TheIsoEngine.IsEditor)
			{
				mXMLStatus = new XML(FlexGlobals.topLevelApplication.GetLastStatusFromServer());

				mGameStatus.Checkpoint = mXMLStatus.Checkpoint.toString();
				mGameStatus.Bag = new XML(mXMLStatus.Bag);
			}
			else
			{
				// Fake status para el editor, hay que ponerlo a lo que se necesite en cada momento
				mGameStatus.Checkpoint = Checkpoints.TM01_START;
				mGameStatus.Bag = <Bag></Bag>;
			}

			if (mGameStatus.Bag.child("Geekpoints").length() == 0)
				mGameStatus.Bag.Geekpoints = "0";

			if (mGameStatus.Bag.child("Logros").length() == 0)
				mGameStatus.Bag.Logros = "";
		}

		public function IsPastCheckpoint(checkPointID : String):Boolean
		{
			if (Checkpoints.GetIndexOf(checkPointID) < Checkpoints.GetIndexOf(Checkpoint))
				return true;
			return false;
		}

		public function IsFutureCheckpoint(checkPointID : String):Boolean
		{
			if (Checkpoints.GetIndexOf(checkPointID) > Checkpoints.GetIndexOf(Checkpoint))
				return true;
			return false;
		}

		/** Pasado incluido, futuro no */
		public function AreWeBetweenCheckpoints(pastIncludedCheckpointID:String, futureNotIncludedCheckpointID:String):Boolean
		{
			if (Checkpoints.GetIndexOf(pastIncludedCheckpointID) <= Checkpoints.GetIndexOf(Checkpoint) &&
				Checkpoints.GetIndexOf(futureNotIncludedCheckpointID) > Checkpoints.GetIndexOf(Checkpoint))
				return true;
			return false;
		}

		[NonSerializable]
		public function get Checkpoint():String	{ return mGameStatus.Checkpoint; }
		public function set Checkpoint(chk : String) :void
		{
			mGameStatus.Checkpoint = chk;
			TheGameModel.BroadcastMessage("OnCheckpointChanged", chk);
			
			// Siempre que cambiamos de checkpoint, grabamos al servidor
			SaveToServer();
		}
		public function SaveToServer() : void
		{
			if (TheGameModel.TheIsoEngine.IsEditor)
				return;

			var gameStatus : XML =	<UserStatus>
										<MapPath>{mMapUrl}</MapPath>
										<Checkpoint>{mGameStatus.Checkpoint}</Checkpoint>
									</UserStatus>;

			gameStatus.appendChild(mGameStatus.Bag);

			FlexGlobals.topLevelApplication.SaveStatus(gameStatus.toXMLString());
		}

		public function get Bag() : XML { return mGameStatus.Bag; }

		public function AddLogro(whichOne : String) : void
		{
			if (TheGameModel.TheIsoEngine.IsEditor)
				return;

			var logroObj : Object = FindLogroObject(whichOne);
			var title : String = logroObj.Title;
			var content : String = logroObj.Content;
			var img : String = IsoEngine.BaseUrl + logroObj.Img;

			// Apuntamos el logro
			mGameStatus.Bag.Logros[whichOne] = parseInt(mGameStatus.Bag.Geekpoints);

			// Cuando conseguimos un logro se graba automaticamente el Status al servidor
			SaveToServer();

			ExternalInterface.call("publishStream", title, content, img);
			FlexGlobals.topLevelApplication.AddLogro(whichOne);
		}

		private function FindLogroObject(whichOne:String) : Object
		{
			for (var c:int = 0; c < LOGROS.length; c++)
				if (LOGROS[c].Name == whichOne)
					return LOGROS[c];
			return null;
		}

		public function IsLogroAchieved(whichOne : String) : Boolean
		{
			return mGameStatus.Bag.Logros.child(whichOne).length() != 0;
		}

		public function AddGeekPoints(eventName:String, points : int) : void
		{
			if (TheGameModel.TheIsoEngine.IsEditor)
				return;

			var totalPoints : int = parseInt(mGameStatus.Bag.Geekpoints) + points;

			if (points != -1)
			{
				mGameStatus.Bag.Geekpoints = totalPoints;
				TheGameModel.BroadcastMessage("OnScoreChanged",
										  	   { DeltaPoints:points, TotalPoints:totalPoints, EventName:eventName} );
				FlexGlobals.topLevelApplication.SavePuntuacion(eventName, points);
				FlexGlobals.topLevelApplication.SavePuntuacion("GlobalScore", totalPoints);
			}
			else
			{
				// Cuando el minigame cancela manda -1. Grabamos el evento en la BDD, aunque no queramos el resto de lógica
				FlexGlobals.topLevelApplication.SavePuntuacion(eventName, points);
			}
		}

		public function RestartGame():void
		{
			if (TheGameModel.TheIsoEngine.IsEditor)
				return;

			FlexGlobals.topLevelApplication.RestartGame(mGameStatus.Bag.Geekpoints);
		}

		private var mGameStatus : Object;
		private var mXMLStatus : XML;
		private var mMapUrl : String;
	}
}

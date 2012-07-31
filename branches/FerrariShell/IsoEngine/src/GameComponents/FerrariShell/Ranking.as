package GameComponents.FerrariShell
{
	import GameComponents.ScreenSystem.ScreenTab;
	
	import flash.events.Event;
	import flash.net.URLVariables;
	
	import mx.controls.Alert;
	
	import utils.GenericEvent;
	import utils.Server;
	
	public class Ranking extends ScreenTab
	{
		override public function OnScreenTabStart():void
		{
			var vars : URLVariables = new URLVariables();
			vars.request = <GetPlayerStatus>
						       <PlayerID id={TheGameModel.GlobalGameState.UserID}/>
						   </GetPlayerStatus>
						
			mServer = new Server(TheGameModel.GlobalGameState.BDDServerBaseURL);
			mServer.addEventListener("RequestError", OnRequestError);
			mServer.addEventListener("RequestComplete", OnRequestComplete);
			mServer.Request(vars, "/velocitaIII/ranking_shell.php");		
		}
		
		override public function OnScreenTabEnd():void
		{
			mServer.removeEventListener("RequestError", OnRequestError);
			mServer.removeEventListener("RequestComplete", OnRequestComplete);
		}
		
		private function OnRequestComplete(event:GenericEvent):void
		{
			trace(event.Data);
						
			var resultXML : XML = XML(event.Data);
			var count : int = 1;
			
			for each(var playerXML : XML in resultXML.Ranking.(@type=="global").child("Player"))
			{
				var nick : String = playerXML.@nick.toString();
				var puntos : String = playerXML.@puntos.toString();
				
				TheVisualObject.mcRanking["ctNombre"+count].text = nick;
				TheVisualObject.mcRanking["ctPuntos"+count].text = puntos;
				
				count++;
				if (count >= 11)
					break;
			}
			
			count = 11;
			
			for each(playerXML in resultXML.Ranking.(@type=="disa").child("Player"))
			{
				nick = playerXML.@nick.toString();
				puntos = playerXML.@puntos.toString();
				
				TheVisualObject.mcRanking["ctNombre"+count].text = nick;
				TheVisualObject.mcRanking["ctPuntos"+count].text = puntos;
				
				count++;
				if (count >= 21)
					break;
			}
		}
		
		private function OnRequestError(event:Event):void
		{
			Alert.show("Error de conexión con el servidor. Por favor, recargue la página", "Error", Alert.OK);
		}
		
		private var mServer : Server;
	}
}
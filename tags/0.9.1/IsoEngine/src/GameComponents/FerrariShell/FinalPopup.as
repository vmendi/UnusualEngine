package GameComponents.FerrariShell
{
	import GameComponents.GameComponent;
	
	import Model.UpdateEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class FinalPopup extends GameComponent
	{
		override public function OnStart():void
		{
			TheVisualObject.btJugar.addEventListener(MouseEvent.CLICK, OnJugar);
			TheVisualObject.btSalir.addEventListener(MouseEvent.CLICK, OnSalir);
			
			TheVisualObject.btJugar.buttonMode = true;
			TheVisualObject.btSalir.buttonMode = true;
		}
		
		public function GotoMode(mode:int, score:int):void
		{
			TheVisualObject.gotoAndStop("Final"+(mode+1).toString());
			mScore = score;
			
			if (TheVisualObject.ctPuntos != null)
				TheVisualObject.ctPuntos.text = mScore.toString();
		}
		
		override public function OnUpdate(event:UpdateEvent):void
		{
			if (TheVisualObject.ctPuntos != null)
				TheVisualObject.ctPuntos.text = mScore.toString();
		}
		
		private function OnJugar(event:Event):void
		{
			TheGameModel.TheIsoEngine.Load(TheGameModel.GlobalGameState.SelectedTrackName);
		}
		
		private function OnSalir(event:Event):void
		{
			TheGameModel.TheIsoEngine.Load("Maps/IsoRacer/FerrariShellMain.xml");
		}
		
		private var mScore : int;
	}
}
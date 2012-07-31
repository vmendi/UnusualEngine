package GameComponents.Desafiate
{
	import GameComponents.GameComponent;
	
	import flash.events.MouseEvent;
	
	/**
	 * Componente ...
	 */
	public final class InitFase extends GameComponent
	{
	
		override public function OnStart():void
		{
			
			// Elementos básicos del interface
			mInterface = new GameComponent();
			//mWindowsPhoneButton = new GameComponent();
			mInterface = TheGameModel.CreateSceneObjectFromMovieClip("mcInterface","InterfacePrimerPlano") as GameComponent;
			//mWindowsPhoneButton = TheGameModel.CreateSceneObjectFromMovieClip("mcWindowsPhone","InterfaceWindowsPhoneButton") as GameComponent;
		}
		
		override public function OnStop():void
		{
			//TheGameModel.DeleteSceneObject(Interface);
		}
		
		public function WindowsPhoneShow() : void
		{
			mInterface.TheVisualObject.gotoAndPlay("windows_phone");
		}
		
		private var mInterface : GameComponent;
		private var mWindowsPhoneButton : GameComponent;
		
	}
}
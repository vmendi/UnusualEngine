package GameComponents.Desafiate
{
	import GameComponents.GameComponent;
	
	import Model.SceneObject;
	
	import utils.MovieClipListener;

	/**
	 * Componente ...
	 */
	public final class PuertaAscensor extends GameComponent
	{
		override public function OnStartComplete():void
		{
			mElevatorConsole = TheGameModel.FindGameComponentByShortName("ElevatorConsole") as ElevatorConsole;
			MovieClipListener.AddFrameScript(TheVisualObject, "open_end", OnOpened);
		}

		public function OnCharacterInteraction(target:SceneObject):void
		{
			if (target == TheSceneObject)
				TheVisualObject.gotoAndPlay("open");
		}
		
		public function Activate():void
		{
			TheVisualObject.InteractiveArea.visible = true;
		}
		
		public function Deactivate():void
		{
			TheVisualObject.InteractiveArea.visible = false;
		}
		
		private function OnOpened():void
		{
			//TheVisualObject.stop();
			mElevatorConsole.Show();
		}

		private var mElevatorConsole : ElevatorConsole;

	}
}
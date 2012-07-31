package GameComponents.Desafiate
{
	import GameComponents.GameComponent;
	
	/**
	 * Componente ...
	 */
	public final class PuertaAscensor extends GameComponent
	{
		
		override public function OnStart():void
		{
			mInterface = TheGameModel.FindGameComponentByShortName("DesafiateInterface") as DesafiateInterface;
		}
		
		override public function OnCharacterInteraction():void
		{
			mInterface.ShowElevatorConsole();
		}

		private var mInterface : DesafiateInterface;
		
	}
}
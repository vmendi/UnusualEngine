package GameComponents.Desafiate
{
	import GameComponents.GameComponent;
	
	/**
	 * Componente ...
	 */
	public final class SalaITRack extends GameComponent
	{
		public var ToggleOnInteraction : Boolean = true;
		
		override public function OnStart():void
		{
			mCharacter = TheGameModel.FindGameComponentByShortName("SalaITCharacter") as SalaITCharacter;
		}
		
		override public function OnCharacterInteraction():void
		{
			
			mCharacter.OnRack();
		}
		
		private var mCharacter : SalaITCharacter;
		
	}
}
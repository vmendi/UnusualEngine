package GameComponents.Desafiate
{
	import GameComponents.GameComponent;
	
	/**
	 * Componente ...
	 */
	public final class SalaITPuerta02 extends GameComponent
	{
		public var ToggleOnInteraction : Boolean = true;
		
		override public function OnStart():void
		{
			mCharacter = TheGameModel.FindGameComponentByShortName("SalaITCharacter") as SalaITCharacter;
		}
		
		override public function OnCharacterInteraction():void
		{
			
			mCharacter.OnPuerta02();
		}
		
		private var mCharacter : SalaITCharacter;
		
	}
}
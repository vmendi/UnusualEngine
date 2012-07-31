package GameComponents.Desafiate
{
	import GameComponents.GameComponent;
	
	/**
	 * Componente ...
	 */
	public final class SalaITMesaOrdenador extends GameComponent
	{
		public var ToggleOnInteraction : Boolean = true;
		
		override public function OnStart():void
		{
			mCharacter = TheGameModel.FindGameComponentByShortName("SalaITCharacter") as SalaITCharacter;
			mPrimerPlano = TheGameModel.FindGameComponentByShortName("SalaITPrimerPlano") as SalaITPrimerPlano;
		}
		
		override public function OnCharacterInteraction():void
		{
			//TheVisualObject.gotoAndStop("panel");
			mPrimerPlano.TheVisualObject.gotoAndPlay("pantalla_ordenador");
			//mCharacter.OnPuerta01();
		}
		
		private var mCharacter : SalaITCharacter;
		private var mPrimerPlano : SalaITPrimerPlano;
		
	}
}
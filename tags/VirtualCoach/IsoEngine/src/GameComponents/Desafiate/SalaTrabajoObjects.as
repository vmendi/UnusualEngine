package GameComponents.Desafiate
{
	import GameComponents.GameComponent;
	
	/**
	 * Componente ...
	 */
	public final class SalaTrabajoObjects extends GameComponent
	{
		public var Object : String = "";
		
		override public function OnStart():void
		{
			mCharacter = TheGameModel.FindGameComponentByShortName("SalaTrabajoCharacter") as SalaTrabajoCharacter;
			//mPrimerPlano = TheGameModel.FindGameComponentByShortName("SalaITPrimerPlano") as SalaTrabajoPrimerPlano;
		}
		
		override public function OnCharacterInteraction():void
		{
			switch (Object)
			{
				case "Puerta01":
					mCharacter.OnPuerta01();
				break;
				case "Vending01":
					mCharacter.OnVending();
				break;
				case "Vending02":
					mCharacter.OnVending();
				break;
				case "Vending03":
					mCharacter.OnCoffee();
				break;
				case "WaterCooler":
					mCharacter.OnWaterCooler();
				break;
			}
		}
		
		private var mCharacter : SalaTrabajoCharacter;
		//private var mPrimerPlano : SalaITPrimerPlano;
		
	}
}
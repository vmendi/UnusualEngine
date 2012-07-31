package GameComponents.Desafiate
{
	import GameComponents.GameComponent;
	
	/**
	 * Componente ...
	 */
	public final class SalaITObjects extends GameComponent
	{
		public var Object : String = "";
		
		override public function OnStart():void
		{
			mCharacter = TheGameModel.FindGameComponentByShortName("SalaITCharacter") as SalaITCharacter;
			mPrimerPlano = TheGameModel.FindGameComponentByShortName("SalaITPrimerPlano") as SalaITPrimerPlano;
		}
		
		override public function OnCharacterInteraction():void
		{
			switch (Object)
			{
				case "Puerta01":
					mCharacter.OnPuerta01();
				break;
				case "Puerta02":
					mCharacter.OnPuerta02();
				break;
				case "Rack":
					mCharacter.OnRack();
				break;
				case "MesaOrdenador":
					mPrimerPlano.TheVisualObject.gotoAndPlay("pantalla_ordenador");
				break;
			}
		}
		
		private var mCharacter : SalaITCharacter;
		private var mPrimerPlano : SalaITPrimerPlano;
		
	}
}
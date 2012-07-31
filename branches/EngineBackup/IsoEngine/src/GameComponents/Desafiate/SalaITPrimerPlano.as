package GameComponents.Desafiate
{
	import GameComponents.GameComponent;
	
	import Model.SceneObject;

	/**
	 * Componente ...
	 */
	public final class SalaITPrimerPlano extends GameComponent
	{
		//public var ToggleOnInteraction : Boolean = true;

		override public function OnStart():void
		{
			TheVisualObject.gotoAndStop("empty");
			//mCharacter = TheGameModel.FindGameComponentByShortName("SalaITCharacter") as SalaITCharacter;
		}

		public function OnCharacterInteraction(target : SceneObject):void
		{
			//mCharacter.OnPuerta01();
		}

		//private var mCharacter : SalaITCharacter;

	}
}
package GameComponents.Desafiate
{
	import GameComponents.Character;
	import GameComponents.GameComponent;
	
	import flash.geom.Point;

	/**
	 * Componente ...
	 */
	public final class DesafiateInterface extends GameComponent
	{
		override public function OnStart():void
		{
			TheVisualObject.gotoAndStop("empty");
			mCharacter = TheGameModel.FindGameComponentByShortName("Character") as Character;
		}

		override public function OnStop():void
		{
			
		}

		private var mCharacter : Character;
	}

}
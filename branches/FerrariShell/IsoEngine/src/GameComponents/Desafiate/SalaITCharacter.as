package GameComponents.Desafiate
{
	import Model.IsoBounds;
	import GameComponents.GameComponent;
	
	/**
	 * Componente ...
	 */
	public final class SalaITCharacter extends GameComponent
	{
	
		override public function OnStart():void
		{
			
		}
		
		public function OnPuerta01():void
		{
			TheVisualObject.mcBocadillos.gotoAndPlay("puerta_salida_01");
		}

		public function OnPuerta02():void
		{
			TheVisualObject.mcBocadillos.gotoAndPlay("puerta_salida_02");
		}
		
		public function OnRack():void
		{
			TheVisualObject.mcBocadillos.gotoAndPlay("rack");
		}
		
		private var mEstado : String;
		
	}
}
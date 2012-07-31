package GameComponents.Desafiate
{
	import Model.IsoBounds;
	import GameComponents.GameComponent;
	
	/**
	 * Componente ...
	 */
	public final class SalaTrabajoCharacter extends GameComponent
	{
	
		override public function OnStart():void
		{
			
		}
		
		public function OnPuerta01():void
		{
			TheVisualObject.mcBocadillos.gotoAndPlay("puerta_salida_01");
		}
		
		public function OnVending():void
		{
			TheVisualObject.mcBocadillos.gotoAndPlay("vending");
		}

		public function OnCoffee():void
		{
			TheVisualObject.mcBocadillos.gotoAndPlay("coffee");
		}

		public function OnWaterCooler():void
		{
			TheVisualObject.mcBocadillos.gotoAndPlay("water_cooler");
		}
		
		private var mEstado : String;
		
	}
}
package GameComponents.PlanetWars
{
	import GameComponents.GameComponent;

	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;

	import utils.GenericEvent;

	public final class CityInteraction extends GameComponent
	{
		public var Highlight : Boolean = true;
		public var HighlightLevel : Number = 40;

		override public function OnStart():void
		{
			mCity = TheAssetObject.FindGameComponentByShortName("City") as City;
			mPlanet = TheGameModel.FindGameComponentByShortName("Planet") as Planet;

			var elementsArray:Array = [1, 0, 0, 0, HighlightLevel,
  								   	   0, 1, 0, 0, HighlightLevel,
   								   	   0, 0, 1, 0, HighlightLevel,
  								   	   0, 0, 0, 1, 0];

  			mColorMatrixFilter = new ColorMatrixFilter(elementsArray);

  			SubscribeListeners();
		}

		private function SubscribeListeners() : void
		{
			TheVisualObject.addEventListener(MouseEvent.CLICK, OnMouseClick);
			TheVisualObject.addEventListener(MouseEvent.MOUSE_OVER, OnMouseOver);
			TheVisualObject.addEventListener(MouseEvent.MOUSE_OUT, OnMouseOut);
		}

		private function OnMouseOver(event:MouseEvent):void
		{
			if (Highlight)
				TheVisualObject.filters = [mColorMatrixFilter];
		}

		private function OnMouseOut(event:MouseEvent):void
		{
			if (Highlight)
				TheVisualObject.filters = [];
		}

		private function OnMouseClick(event:MouseEvent):void
		{
			// Lo transmitimos desde el modelo (planeta) al resto del mundo
			mPlanet.dispatchEvent(new GenericEvent("CityClick", mCity));
		}

		private var mPlanet : Planet;
		private var mCity : City;

		private var mColorMatrixFilter : ColorMatrixFilter;
	}


}
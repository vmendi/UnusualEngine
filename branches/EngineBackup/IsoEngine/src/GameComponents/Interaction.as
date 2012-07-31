package GameComponents
{
	import Model.GameModel;
	import Model.IsoBounds;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;

	import mx.collections.ArrayCollection;

	import utils.Point3;

	/**
	 * Componente de interacción.
	 *
	 * Ilumina el VisualObject en el over del ratón. Lanza el mensaje OnClickInteraction a todo el mundo.
	 * 
	 */
	public final class Interaction extends GameComponent
	{
		public var Highlight : Boolean = false;
		public var HighlightLevel : Number = 40;

		public var NavigateOnClick : Boolean = true;

		public var InteractionX : int = 0;
		public var InteractionY : int = 0;

		public var HasInteractiveArea : Boolean = false;

		public var FinalOrientation : String = "Auto";

		public function get Enabled() : Boolean	{ return mEnabled; }
		public function set Enabled(val:Boolean):void
		{
			if (val != mEnabled)
			{
				mEnabled = val;
				RefreshListeners();
			}
		}
		
		private function RefreshListeners() : void
		{
			if (!mStarted)
				return;
			
			if (mEnabled)
				SubscribeListeners();
			else
				RemoveListeners();
		}

		override public function OnStart():void
		{
			var elementsArray:Array = [1, 0, 0, 0, HighlightLevel,
  								   	   0, 1, 0, 0, HighlightLevel,
   								   	   0, 0, 1, 0, HighlightLevel,
  								   	   0, 0, 0, 1, 0];

  			mColorMatrixFilter = new ColorMatrixFilter(elementsArray);

  			mStarted = true;
  			RefreshListeners();

  			// Si tiene InteractiveArea hacemos que sólo los hijos recojan los eventos, no todo el movieclip.
  			// Así posibilitamos que los movieclips que estén debajo sigan recogiendo los eventos de ratón.
  			if (HasInteractiveArea)
  			{
  				TheVisualObject.mouseEnabled = false;
  				TheVisualObject.mouseChildren = true;
  			}
		}

		override public function OnStop():void
		{
			RemoveListeners();
		}


		override public function OnPause():void
		{
			if (mEnabled)
				RemoveListeners();

			mPaused = true;
		}

		override public function OnResume():void
		{
			mPaused = false;

			if (mEnabled)
				SubscribeListeners();
		}

		public function EmulateMouseClick():void
		{
			OnMouseClick(null);
		}

		private function SubscribeListeners() : void
		{
			if (mPaused)
				return;

			if (HasInteractiveArea)
			{
				TheVisualObject.InteractiveArea.addEventListener(MouseEvent.CLICK, OnMouseClick, false, 0, true);
				TheVisualObject.InteractiveArea.addEventListener(MouseEvent.MOUSE_OVER, OnMouseOver, false, 0, true);
				TheVisualObject.InteractiveArea.addEventListener(MouseEvent.MOUSE_OUT, OnMouseOut, false, 0, true);
			}
			else
			{
				TheVisualObject.addEventListener(MouseEvent.CLICK, OnMouseClick, false, 0, true);
				TheVisualObject.addEventListener(MouseEvent.MOUSE_OVER, OnMouseOver, false, 0, true);
				TheVisualObject.addEventListener(MouseEvent.MOUSE_OUT, OnMouseOut, false, 0, true);
			}
		}

		private function RemoveListeners() : void
		{
			if (mPaused)
				return;

			if (HasInteractiveArea)
			{
				TheVisualObject.InteractiveArea.removeEventListener(MouseEvent.CLICK, OnMouseClick);
				TheVisualObject.InteractiveArea.removeEventListener(MouseEvent.MOUSE_OVER, OnMouseOver);
				TheVisualObject.InteractiveArea.removeEventListener(MouseEvent.MOUSE_OUT, OnMouseOut);
			}
			else
			{
				TheVisualObject.removeEventListener(MouseEvent.CLICK, OnMouseClick);
				TheVisualObject.removeEventListener(MouseEvent.MOUSE_OVER, OnMouseOver);
				TheVisualObject.removeEventListener(MouseEvent.MOUSE_OUT, OnMouseOut);
			}
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
			// Si han interactuado conmigo, el evento ya no va a ningun sitio mas. Esto previene por ejemplo que
			// se reciba el click tambien en la subscripcion del Character a la Stage
			event.stopPropagation();
			
			// Lo transmitimos al resto de componentes
			TheGameModel.BroadcastMessage("OnClickInteraction", this);
		}

		private var mStarted : Boolean = false;
		private var mEnabled : Boolean = true;
		private var mPaused : Boolean = false;

		private var mColorMatrixFilter : ColorMatrixFilter;
	}
}
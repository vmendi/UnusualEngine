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
	 * Ilumina al IsoObject en el over del ratón. Lanza el mensaje OnInteraction a todos los componentes "hermanos"
	 * que pertenecen también a su AssetObject. Se ocupa de hacer que el personaje navegue hasta la celda de
	 * interacción.
	 */
	public final class Interaction extends GameComponent
	{
		public var Highlight : Boolean = false;
		public var HighlightLevel : Number = 40;

		public var NavigateOnClick : Boolean = true;

		public var InteractionX : int = 0;
		public var InteractionY : int = 0;

		public function get Enabled() : Boolean	{ return mEnabled; }
		public function set Enabled(val:Boolean):void
		{
			if (val != mEnabled)
			{
				mEnabled = val;
				SyncEnabled();
			}
		}

		override public function OnStart():void
		{
			var elementsArray:Array = [1, 0, 0, 0, HighlightLevel,
  								   	   0, 1, 0, 0, HighlightLevel,
   								   	   0, 0, 1, 0, HighlightLevel,
  								   	   0, 0, 0, 1, 0];

  			mColorMatrixFilter = new ColorMatrixFilter(elementsArray);

  			mStarted = true;
  			SyncEnabled();
		}

		override public function OnStop():void
		{
			RemoveListeners();
		}

		private function SyncEnabled() : void
		{
			if (!mStarted)
				return;

			if (mEnabled)
			{
				mCharacter = TheGameModel.FindGameComponentByShortName("Character") as Character;

				if (mCharacter == null)
					throw "Character must exist if interaction component is enabled";

				if (!mCharacter.MouseControlled)
					throw "Character must be mouse-controllable";

				SubscribeListeners();
			}
			else
			if (mCharacter != null)
			{
				RemoveListeners();
				mCharacter = null;
			}
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

		private function SubscribeListeners() : void
		{
			if (mPaused)
				return;

			TheVisualObject.addEventListener(MouseEvent.CLICK, OnMouseClick, false, 0, true);
			TheVisualObject.addEventListener(MouseEvent.MOUSE_OVER, OnMouseOver, false, 0, true);
			TheVisualObject.addEventListener(MouseEvent.MOUSE_OUT, OnMouseOut, false, 0, true);
		}

		private function RemoveListeners() : void
		{
			if (mPaused)
				return;

			TheVisualObject.removeEventListener(MouseEvent.CLICK, OnMouseClick);
			TheVisualObject.removeEventListener(MouseEvent.MOUSE_OVER, OnMouseOver);
			TheVisualObject.removeEventListener(MouseEvent.MOUSE_OUT, OnMouseOut);
		}

		private function OnMouseOver(event:MouseEvent):void
		{
			if (mCharacter)
				mCharacter.SetNavigationEnabled(false);

			if (Highlight)
				TheVisualObject.filters = [mColorMatrixFilter];
		}

		private function OnMouseOut(event:MouseEvent):void
		{
			if (mCharacter)
				mCharacter.SetNavigationEnabled(true);

			if (Highlight)
				TheVisualObject.filters = [];
		}

		private function OnMouseClick(event:MouseEvent):void
		{
			// Lo transmitimos al resto de componentes
			var components : ArrayCollection = TheAssetObject.TheGameComponents;
			for each(var comp : GameComponent in components)
			{
				comp.OnClickInteraction();
			}

			// Mandamos al personaje al punto de interaction
			if (NavigateOnClick && mCharacter)
			{
				var cellSizeInMeters : Number = GameModel.CellSizeMeters;
				var worldPos : Point3 = TheIsoComponent.WorldPos;
				var globalPos : Point3 = new Point3(worldPos.x + InteractionX*cellSizeInMeters, 0,
												    worldPos.z + InteractionY*cellSizeInMeters);
				mCharacter.NavigateTo(globalPos);
				mCharacter.addEventListener("NavigationStart", OnNavigationStart);
				mCharacter.addEventListener("NavigationEnd", OnNavigationEnd);
			}
		}

		private function OnNavigationStart(event:Event) : void
		{
			// Se ha producido una nueva navegación mientras veníamos a la interación
			mCharacter.removeEventListener("NavigationStart", OnNavigationStart);
			mCharacter.removeEventListener("NavigationEnd", OnNavigationEnd);
		}

		private function OnNavigationEnd(event:Event) : void
		{
			mCharacter.removeEventListener("NavigationStart", OnNavigationStart);
			mCharacter.removeEventListener("NavigationEnd", OnNavigationEnd);

			// Hemos llegado, nos orientamos
			var characterBounds : IsoBounds = mCharacter.TheIsoComponent.Bounds;
			var myBounds : IsoBounds = TheIsoComponent.Bounds;
			var charPos : Point3 = mCharacter.TheIsoComponent.WorldPos;
			var cellSizeInMeters : Number = GameModel.CellSizeMeters;

			if (characterBounds.Right <= myBounds.Left)
			{
				if (characterBounds.Back >= myBounds.Front)
					mCharacter.OrientTo(new Point3(charPos.x+cellSizeInMeters, 0, charPos.z-cellSizeInMeters));
				else
				if (characterBounds.Front <= myBounds.Back)
					mCharacter.OrientTo(new Point3(charPos.x+cellSizeInMeters, 0, charPos.z+cellSizeInMeters));
				else
					mCharacter.OrientTo(new Point3(charPos.x+cellSizeInMeters, 0, charPos.z));
			}
			else
			if (characterBounds.Left >= myBounds.Right)
			{
				if (characterBounds.Back >= myBounds.Front)
					mCharacter.OrientTo(new Point3(charPos.x-cellSizeInMeters, 0, charPos.z-cellSizeInMeters));
				else
				if (characterBounds.Front <= myBounds.Back)
					mCharacter.OrientTo(new Point3(charPos.x-cellSizeInMeters, 0, charPos.z+cellSizeInMeters));
				else
					mCharacter.OrientTo(new Point3(charPos.x-cellSizeInMeters, 0, charPos.z));
			}
			else
			{
				if (characterBounds.Back >= myBounds.Front)
					mCharacter.OrientTo(new Point3(charPos.x, 0, charPos.z-cellSizeInMeters));
				else
				if (characterBounds.Front <= myBounds.Back)
					mCharacter.OrientTo(new Point3(charPos.x, 0, charPos.z+cellSizeInMeters));
			}

			// Lo transmitimos al resto de componentes
			var components : ArrayCollection = TheAssetObject.TheGameComponents;
			for each(var comp : GameComponent in components)
			{
				comp.OnCharacterInteraction();
			}

		}

		private var mStarted : Boolean = false;
		private var mEnabled : Boolean = true;
		private var mPaused : Boolean = false;

		private var mCharacter : Character;
		private var mColorMatrixFilter : ColorMatrixFilter;
	}
}
package GameComponents
{
	import Model.IsoBounds;
	import Model.SceneObject;

	/**
	 * Componente para emular el comportamiento de una puerta.
	 */
	public final class Door extends GameComponent
	{
		public var ToggleOnCharacterInteraction : Boolean = true;
		public var ToggleOnClickInteraction : Boolean = false;

		public function OnCharacterInteraction(target : SceneObject):void
		{
			if (target != TheSceneObject)
				return;
				
			if (ToggleOnCharacterInteraction)
				Toggle();
		}

		public function OnClickInteraction(interactedWith : Interaction) : void
		{
			if (interactedWith.TheSceneObject != TheSceneObject)
				return;
				
			if (ToggleOnClickInteraction)
				Toggle();
		}

		public function Toggle() : Boolean
		{
			var newWalkable : Boolean = !TheIsoComponent.Walkable;
			var bounds : IsoBounds = TheIsoComponent.Bounds;

			TheGameModel.(TheGameModel.FindGameComponentByShortName("AStarMapSpace") as AStarMapSpace).SetWalkable(bounds, newWalkable);

			if (newWalkable)
				TheVisualObject.gotoAndStop("abierta");
			else
				TheVisualObject.gotoAndStop("cerrada");

			TheIsoComponent.Walkable = newWalkable;

			return newWalkable;
		}
	}
}
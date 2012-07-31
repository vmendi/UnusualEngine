package GameComponents.Desafiate
{
	import GameComponents.Character;
	import GameComponents.GameComponent;
	
	import Model.SceneObject;
	
	import utils.MovieClipListener;

	public final class Television extends GameComponent
	{
		override public function OnPreStart():void
		{
			mOverlay = TheGameModel.CreateSceneObject(TheGameModel.TheAssetLibrary.FindAssetObjectByMovieClipName("mcTelevisorOverlay"));
			MovieClipListener.AddFrameScript(mOverlay.TheVisualObject, "tv_hide_end", OnTvHideEnd);
		}
		
		override public function OnStartComplete():void
		{
			mCharacter = TheGameModel.FindGameComponentByShortName("Character") as Character;
		}
		
		public function TurnOn():void
		{
			mCharacter.MouseControlled = false;
			mOverlay.TheVisualObject.visible = true;
			mOverlay.TheVisualObject.gotoAndPlay("tv_show");
		}
		
		private function OnTvHideEnd():void
		{
			mOverlay.TheVisualObject.visible = false;
			mCharacter.MouseControlled = true;
		}
		
		private var mOverlay : SceneObject;
		private var mCharacter : Character;

	}
}
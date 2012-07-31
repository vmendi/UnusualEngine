package GameComponents.Desafiate
{
	import GameComponents.Character;
	import GameComponents.GameComponent;

	public class Racks extends GameComponent
	{
		
		override public function OnPreStart():void
		{
			
		}

		override public function OnStart():void
		{
			mStatus = TheGameModel.FindGameComponentByShortName("GameStatus") as GameStatus;
			
		}
		
		override public function OnStartComplete():void
		{
			TheVisualObject.InteractiveArea.visible = false;
			if (mStatus.Checkpoint == Checkpoints.INTER02 || mStatus.Checkpoint == Checkpoints.TM03_START)
			{
				ShowArcade();
			}
		}
		
		public function ShowArcade():void
		{
			TheVisualObject.gotoAndStop("arcade");
			TheVisualObject.InteractiveArea.visible = true;
		}
		
		private var mStatus : GameStatus;
		private var mCharacter : Character;
	}
}
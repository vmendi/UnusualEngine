package GameComponents.Desafiate
{
	import GameComponents.Character;
	import GameComponents.GameComponent;
	
	import Model.SceneObject;
	import Model.UpdateEvent;

	public class BicicletaSwitch extends GameComponent
	{
		
		override public function OnPreStart():void
		{

		}
		
		override public function OnStart():void
		{
			//TheVisualObject.visible = false;
		}
		
		override public function OnStop():void
		{
			//TheVisualObject.visible = true;
		}

		override public function OnStartComplete():void
		{
			//mCharacter = TheGameModel.FindGameComponentByShortName("Character") as Character;
			mDesafiateCharacter = TheGameModel.FindGameComponentByShortName("DesafiateCharacter") as DesafiateCharacter;
			mDesafiateBike = TheGameModel.FindGameComponentByShortName("DesafiateBike") as DesafiateBike;
			mInitFase = TheGameModel.FindGameComponentByShortName("InitFase") as InitFase;
			//mDesafiateInterface = TheGameModel.FindGameComponentByShortName("DesafiateInterface") as DesafiateInterface;
		}

		override public function OnUpdate(event:UpdateEvent):void
		{


		}

		public function OnCharacterInteraction(target:SceneObject):void
		{
			TheVisualObject.visible = false;
			//mInitFase.SwitchToBike();
			mDesafiateCharacter.Hide();
			mDesafiateCharacter.Freeze();
			mDesafiateBike.UnFreeze();
			mDesafiateBike.UnHide();
		}

		private var mCharacter : Character;
		private var mDesafiateCharacter : DesafiateCharacter;
		private var mDesafiateBike : DesafiateBike;
		private var mInitFase : InitFase;
		
	}
}
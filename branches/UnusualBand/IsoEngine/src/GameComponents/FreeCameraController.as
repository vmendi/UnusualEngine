package GameComponents
{
	import Model.UpdateEvent;

	public class FreeCameraController extends GameComponent
	{
		override public function OnUpdate(event:UpdateEvent):void
		{
			TheGameModel.TheIsoCamera.MoveWithKeyboard(event.ElapsedTime, false);
			TheGameModel.TheRender2DCamera.MoveWithKeyboard(event.ElapsedTime, true);
		}
	}
}
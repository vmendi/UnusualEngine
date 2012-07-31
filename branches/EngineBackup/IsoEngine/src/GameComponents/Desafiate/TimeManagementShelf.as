package GameComponents.Desafiate
{
	import GameComponents.GameComponent;
	import GameComponents.Interaction;

	import flash.events.Event;
	import flash.events.MouseEvent;

	import utils.MovieClipListener;
	import utils.MovieClipMouseDisabler;

	public class TimeManagementShelf extends GameComponent
	{
		[NonSerializable]
		public function get AvailableObject() : String
		{
			return mAvailableObject;
		}
		public function set AvailableObject(objName : String) : void
		{
			mAvailableObject = objName;

			if (mAvailableObject != null)
			{
				TheVisualObject.gotoAndStop(objName);
				MovieClipListener.AddFrameScript(TheVisualObject, objName, OnAvailableObjectReached);
			}
			else
				TheVisualObject.gotoAndStop("empty");
		}

		private function OnAvailableObjectReached():void
		{
			MovieClipListener.AddFrameScript(TheVisualObject, TheVisualObject.currentLabel, null);

			TheVisualObject.btTask.addEventListener(MouseEvent.CLICK, OnIconClick);
		}

		private function OnIconClick(e:Event):void
		{
			(TheAssetObject.FindGameComponentByShortName("Interaction") as Interaction).EmulateMouseClick();
			e.stopPropagation();
		}


		private var mAvailableObject : String = null;
	}
}
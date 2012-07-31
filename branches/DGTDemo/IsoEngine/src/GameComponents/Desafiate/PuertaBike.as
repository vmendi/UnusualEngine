package GameComponents.Desafiate
{
	import GameComponents.GameComponent;
	
	import Model.SceneObject;
	import Model.UpdateEvent;
	
	import flash.geom.Point;
	
	import utils.Delegate;
	import utils.MovieClipListener;

	public class PuertaBike extends GameComponent
	{
		
		public var Speech : String = "No";
		public var Duration : int = 2000;
		public var Popup : String = "No";
		
		override public function OnPreStart():void
		{

		}
		
		override public function OnStart():void
		{
			TheVisualObject.visible = false;
		}
		
		override public function OnStop():void
		{
			TheVisualObject.visible = true;
		}

		override public function OnStartComplete():void
		{
			mDesafiateBike = TheGameModel.FindGameComponentByShortName("DesafiateBike") as DesafiateBike;
			mDesafiateInterface = TheGameModel.FindGameComponentByShortName("DesafiateInterface") as DesafiateInterface;
		}

		override public function OnUpdate(event:UpdateEvent):void
		{
			if (TheAssetObject.TheIsoComponent.Bounds.IsPointInside(new Point(mDesafiateBike.WorldPos.x, mDesafiateBike.WorldPos.z))
				&& !mAbierta)
			{
				mDesafiateBike.Freeze();
				mAbierta = true;
				if (Speech != "No")
				{
					mDesafiateBike.Talk([Speech, Duration], Delegate.create(ShowInterface));
				}
				else
				{
					ShowInterface();
				}
			}
		}

		public function OnCharacterInteraction(target:SceneObject):void
		{
			switch(target.Name)
			{
				case "Sillon":

				break;
			}
		}
		
		public function ShowInterface():void
		{
			if (Popup != "No")
			{
				MovieClipListener.AddFrameScript(mDesafiateInterface.TheVisualObject, Popup+"Off", HideInterface);
				mDesafiateInterface.TheVisualObject.gotoAndStop(Popup);
			}
			else
			{
				mDesafiateBike.UnFreeze();
			}
		}

		public function HideInterface():void
		{
			mDesafiateBike.UnFreeze();
			mDesafiateInterface.TheVisualObject.gotoAndStop("empty");
		}

		private var mDesafiateBike : DesafiateBike;
		private var mAbierta : Boolean = false;
		private var mDesafiateInterface : DesafiateInterface; 
		
	}
}
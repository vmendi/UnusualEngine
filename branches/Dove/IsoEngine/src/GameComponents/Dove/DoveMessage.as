package GameComponents.Dove
{
	import GameComponents.GameComponent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import gs.TweenLite;

	public class DoveMessage extends GameComponent
	{
		public var Message : String = "Formulario enviado con éxito";
		public var FadeOutOnClose : Boolean = true;
		
		override public function OnStart():void
		{
			TheVisualObject["mcButAceptar"].addEventListener(MouseEvent.CLICK, OnAceptarClick);
			
			TheVisualObject.graphics.beginFill(0xFFFFFF, 0.6);
			TheVisualObject.graphics.drawRect(-1000, -1000, 2000, 2000);
			TheVisualObject.graphics.endFill();
			
			TheVisualObject.alpha = 0.0;
			
			TweenLite.to(TheVisualObject, 0.5, { alpha:1 });
		}
			
		private function OnAceptarClick(event:Event):void
		{
			if (FadeOutOnClose)
				TweenLite.to(TheVisualObject, 0.5, { alpha:0, onComplete:InterpEnd });
			else
				TheGameModel.DeleteSceneObject(TheSceneObject);
		}
		
		private function InterpEnd():void
		{
			TheGameModel.DeleteSceneObject(TheSceneObject);
		}
	}
}
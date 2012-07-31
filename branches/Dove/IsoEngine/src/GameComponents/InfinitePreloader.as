package GameComponents
{
	import gs.TweenLite;
	
	public class InfinitePreloader extends GameComponent
	{
		override public function OnStart():void
		{
			TheVisualObject.graphics.beginFill(0xFFFFFF, 0.6);
			TheVisualObject.graphics.drawRect(-1000, -1000, 2000, 2000);
			TheVisualObject.graphics.endFill();
			
			TheVisualObject.alpha = 0.0;
			
			TweenLite.to(TheVisualObject, 0.5, { alpha:1 });
		}
	}
}
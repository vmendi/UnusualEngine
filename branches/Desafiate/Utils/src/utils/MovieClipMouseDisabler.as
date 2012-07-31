package utils
{
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	
	public final class MovieClipMouseDisabler
	{
		static public function DisableMouse(parent : DisplayObjectContainer, disabled:Boolean = true) : void
		{
			parent.mouseEnabled = !disabled;
			for (var c : int = 0; c < parent.numChildren; c++)
			{
				var theChild : Object = parent.getChildAt(c);
				var container : DisplayObjectContainer = theChild as DisplayObjectContainer;
				
				if (container != null)
					DisableMouse(container, disabled);
				else
				{
					var interactive : InteractiveObject = theChild as InteractiveObject;
					if (interactive != null)
						interactive.mouseEnabled = !disabled;
				}
			}
		}
	}
}
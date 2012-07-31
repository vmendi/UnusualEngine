package GameView
{
	import flash.display.DisplayObjectContainer;
	import flash.utils.getQualifiedClassName;
	
	import mx.core.UIComponent;
	
	import utils.Type;

	public class HierarchyUtils
	{
		static public function FindParentOfType(child:UIComponent, type : String) : Object
		{
			var ret : DisplayObjectContainer = child.parent;
			
			while (ret != null && getQualifiedClassName(ret) != type)
			{
				ret = ret.parent;
			}
						
			return ret;
		}
	}
}
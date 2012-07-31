package GameView.Team
{
	import flash.geom.Point;
	
	import mx.core.ILayoutElement;
	
	import spark.layouts.supportClasses.LayoutBase;
	
	public final class FormationLayout extends LayoutBase
	{
		public function get FormationName() : String { return mFormationName; }
		public function set FormationName(f : String) : void 
		{ 
			mFormationName = f;
			
			if (target != null)
			{
				target.invalidateSize();
				target.invalidateDisplayList();
			}
		}
		
		private function GetNumLayoutElements():int
		{
			var layoutElements:int = 0;
			var numElements:int = target.numElements;
			
			for( var i:int = 0; i < numElements; i++ )
			{
				if( target.getElementAt( i ).includeInLayout )
					layoutElements++;
			}
			
			return layoutElements;
		}
		
		override public function get useVirtualLayout():Boolean { return false; }
						
		override public function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			var numElements:uint = target.numElements;
			
			if (numElements > 0)
			{									
				var fieldCapWidth : Number = target.getElementAt(0).getPreferredBoundsWidth();
				var fieldCapHeight : Number = target.getElementAt(0).getPreferredBoundsHeight();
				
				var points : Array = GetPointsForFielPos(FormationName, fieldCapWidth, fieldCapHeight);
				
				for( var i:int = 0; i < numElements; i++ )
				{
					var layoutElement : ILayoutElement = target.getElementAt(i);
					
					if(!layoutElement.includeInLayout)
						continue;
					
					layoutElement.setLayoutBoundsPosition(points[i].x, points[i].y);
					
					// Leave the element to size itself to its preferred size.
					layoutElement.setLayoutBoundsSize(NaN, NaN);
				}
			}
		}
		
		static private function GetPointsForFielPos(formation : String, fieldCapWidth : Number, fieldCapHeight : Number) : Array
		{
			var ret : Array = SoccerClientV1.GetMainGameModel().TheFormationModel.GetFormationByName(formation).Points.slice();			
			
			for (var c:int = 0; c < ret.length; c++)
			{
				ret[c] = new Point(ret[c].x - fieldCapWidth*0.5, ret[c].y - fieldCapHeight*0.5); 
			}
			
			return ret;
		}
		
		private var mFormationName : String;		
	}
}
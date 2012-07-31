﻿package away3d.materials.utils.data
{
	import flash.display.BitmapData;
	import flash.filters.ConvolutionFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Grow{
		
		public static function apply(sourcemap:BitmapData, passes:int = 10):BitmapData
		{
			passes = (passes < 1)? 1 : passes;
			
			var tmp0:BitmapData = new BitmapData(sourcemap.width, sourcemap.height, true, 0);
			var tmp1:BitmapData = new BitmapData( sourcemap.width, sourcemap.height, false, 0);
			var tmp2:BitmapData = tmp1.clone();
			var tmp3:BitmapData = tmp0.clone();
			
			var cf:ConvolutionFilter = new ConvolutionFilter(3,3,null,0,127);
			var dp:DisplacementMapFilter = new DisplacementMapFilter( tmp1, tmp1.rect.topLeft, 1, 2, 2, 2, "color",0,0 );
			var zeropt:Point = new Point(0,0);
			var mat0:Array = [-1,0,1,-2,0,2,-1,0,1];
			var mat1:Array = [-1,-2,-1,0,0,0,1,2,1];
			
			for(var i:int = 0;i<passes;++i){
				tmp0.draw(sourcemap);
				tmp0.threshold(tmp0, sourcemap.rect, zeropt,"==",0, 0xFFFFFF, 0xFFFFFF);
				
				tmp1.copyChannel( tmp0, sourcemap.rect, sourcemap.rect.topLeft, 8, 1 );
				tmp2.draw(tmp1);
				
				cf .matrix = mat0;
				tmp1.applyFilter(tmp1, tmp1.rect, tmp1.rect.topLeft, cf );
				
				cf.matrix = mat1;
				tmp2.applyFilter(tmp2, tmp2.rect, tmp2.rect.topLeft, cf );
				tmp1.copyChannel( tmp2, tmp1.rect, tmp1.rect.topLeft, 1, 2 );

				tmp3.draw(tmp0);
				tmp0.applyFilter( tmp0, sourcemap.rect, sourcemap.rect.topLeft, dp ); 
				tmp0.draw( tmp3); 
				sourcemap.draw(tmp0);
			}
			
			tmp0.dispose();
			tmp1.dispose();
			tmp2.dispose();
			tmp3.dispose();
			
			return sourcemap;
		}
		
		
	}
}
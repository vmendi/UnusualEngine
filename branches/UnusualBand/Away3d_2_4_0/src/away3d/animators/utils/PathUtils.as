﻿package away3d.animators.utils
{
	import away3d.core.math.Number3D;
	import away3d.animators.data.Path;
	
	/**
	 * Geometry handlers for classes using Path objects
	 */
    public class PathUtils
    {
    	 
		 public static function step( startVal:Number3D, endVal:Number3D, subdivision:int):Array {
			var aTween:Array = [];
			
			var stepx:Number =  (endVal.x-startVal.x) / subdivision;
			var stepy:Number =  (endVal.y-startVal.y) / subdivision;
			var stepz:Number =  (endVal.z-startVal.z) / subdivision;
			
			var step:int = 1;
			var scalestep:Number3D;
			
			while (step < subdivision) { 
				scalestep = new Number3D();
				scalestep.x = startVal.x+(stepx*step);
				scalestep.y = startVal.y+(stepy*step);
				scalestep.z = startVal.z+(stepz*step);
				aTween.push(scalestep);
				
				step ++;
			}
			
			aTween.push(endVal);
			
			return aTween;
		}
		 
		public static function rotatePoint(aPoint:Number3D, rotation:Number3D):Number3D
		{
			if(rotation.x !=0 || rotation.y != 0 || rotation.z != 0)
			{
				var x1:Number;
				var y1:Number;
				
				var rad:Number = Math.PI / 180;
				var rotx:Number = rotation.x * rad;
				var roty:Number = rotation.y * rad;
				var rotz:Number = rotation.z * rad;
				var sinx:Number = Math.sin(rotx);
				var cosx:Number = Math.cos(rotx);
				var siny:Number = Math.sin(roty);
				var cosy:Number = Math.cos(roty);
				var sinz:Number = Math.sin(rotz);
				var cosz:Number = Math.cos(rotz);
	
				var x:Number = aPoint.x;
				var y:Number = aPoint.y;
				var z:Number = aPoint.z;
	
				y1 = y;
				y = y1*cosx+z*-sinx;
				z = y1*sinx+z*cosx;
				
				x1 = x;
				x = x1*cosy+z*siny;
				z = x1*-siny+z*cosy;
			
				x1 = x;
				x = x1*cosz+y*-sinz;
				y = x1*sinz+y*cosz;
	
				aPoint.x = x;
				aPoint.y = y;
				aPoint.z = z;
			}
			
			return aPoint;
		}
		
		public static function getPointsOnCurve(_path:Path, subdivision:int):Array 
		{	
			var aSegPoints:Array = [];
			 
			for (var i:int = 0; i < _path.length; ++i)
				aSegPoints.push(PathUtils.getSegmentPoints(_path.array[i].v0, _path.array[i].vc, _path.array[i].v1, subdivision, (i ==_path.length-1)));
			
			return aSegPoints;
		}
		
		public static function getSegmentPoints(v0:Number3D, vc:Number3D, v1:Number3D, n:Number, last:Boolean):Array
		{
			var aPts:Array = [];
			
			for (var i:int = 0; i < n+((last)? 1 : 0); ++i)
				aPts.push(PathUtils.getNewPoint(v0.x, v0.y, v0.z, vc.x, vc.y, vc.z, v1.x, v1.y, v1.z, i / n));
			
			return aPts;
		}
		
		public static function getNewPoint(x0:Number = 0, y0:Number = 0, z0:Number=0, aX:Number = 0, aY:Number = 0, aZ:Number=0, x1:Number = 0, y1:Number = 0, z1:Number=0, t:Number = 0):Number3D 
		{
			return new Number3D(x0 + t * (2 * (1 - t) * (aX - x0) + t * (x1 - x0)), y0 + t * (2 * (1 - t) * (aY - y0) + t * (y1 - y0)), z0 + t * (2 * (1 - t) * (aZ - z0) + t * (z1 - z0)));
		}
      
		
    }
}

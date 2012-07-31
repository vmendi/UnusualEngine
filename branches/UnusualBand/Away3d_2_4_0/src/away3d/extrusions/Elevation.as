﻿package away3d.extrusions
{
   	import flash.display.BitmapData;
	import away3d.core.math.Number3D;
	
	/**
	* Class Elevation returns a multidimentional array of Number3D's to pass to the SkinClass in order to generate an elevated mesh from <Elevation></code>
	* 
	*/
	public class Elevation {
		
		private var _minElevation:Number = 0;
		private var _maxElevation:Number = 255;
		
		/**
		* Locks elevation factor beneath this level. Default is 0;
		*
		*/
		public function set minElevation(val:Number):void
        {
			_minElevation = val;
		}
		public function get minElevation():Number
        {
			return _minElevation;
		}
		/**
		* Locks elevation factor above this level. Default is 255;
		*
		*/
		public function set maxElevation(val:Number):void
        {
			_maxElevation = val;
		}
		public function get maxElevation():Number
        {
			return _maxElevation;
		}
		
		/**
		* Creates a generate <code>Elevation</code> object.
		*
		 */
		public function Elevation()
        {
		}
		
		/**
		* Generate the Array representing the mesh
		*
		* @param	sourceBmd				Bitmapdata. The bitmapData to read from.
		* @param	channel					[optional] String. The channel information to read. supported "a", alpha, "r", red, "g", green, "b", blue and "av" (averages and luminance). Default is red channel "r".
		* @param	subdivisionX			[optional] int. The subdivision to read the pixels along the x axis. Default is 10.
		* @param	subdivisionY			[optional] int. The subdivision to read the pixels along the y axis. Default is 10.
		* @param	scalingX					[optional] Number. The scale multiplier along the x axis. Default is 1.
		* @param	scalingY					[optional] Number. The scale multiplier along the y axis. Default is 1.
		* @param	elevate					[optional] Number. The scale multiplier along the z axis. Default is .5.
		*/
		
		public function generate(sourceBmd:BitmapData, channel:String = "r", subdivisionX:int = 10, subdivisionY:int = 10, scalingX:Number = 1, scalingY:Number = 1, elevate:Number = .5):Array
		{
			channel = channel.toLowerCase();
			
			var w:int = sourceBmd.width;
			var h:int = sourceBmd.height;
			var i:int;
			var j:int;
			var x:Number = 0;
			var y:Number = 0;
 			var z:Number = 0;
			var totalArray:Array = [];
			var tmpArray:Array = [];
			var color:uint;
			var cha:Number;
			
			
			for(j = h-1; j >-subdivisionY; j-=subdivisionY)
			{
				y = (j<0)? 0 : j;
				tmpArray = [];
				
				for(i = 0; i < w+subdivisionX; i+=subdivisionX)
				{
					x = (i<w-1)? i : w-1; 
					
					color = (channel == "a")? sourceBmd.getPixel32(x, y) : sourceBmd.getPixel(x, y);
					
					switch(channel){
						case "a":
							cha = color >> 24 & 0xFF;
							break;
						case "r":
							cha = color >> 16 & 0xFF;
							break;
						case "g":
							cha = color >> 8 & 0xFF;
							break;
						case "b":
							cha = color & 0xFF;
						case "av":
							cha = ((color >> 16 & 0xFF)*0.212671) + ((color >> 8 & 0xFF)*0.715160) + ((color >> 8 & 0xFF)*0.072169);
					}
					
					if(maxElevation < cha)
						cha = maxElevation;
						
					if(minElevation > cha)
						cha = minElevation;
						
					z = cha*elevate;
					
					tmpArray.push(new Number3D(x*scalingX, y*scalingY, z));
				}
				
				totalArray.push(tmpArray);
			}
			
			return totalArray;
		}
		

		
	}
}
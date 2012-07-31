﻿package away3d.exporters
{
   	import flash.display.BitmapData;
	
	/**
	* Class Elevation2AS3 generates a string class of the elevation to pass to the SkinClass and ElevationReader in order to save space and processing time.
	* 
	*/
	public class Elevation2AS3 {
		
		private var _minElevation:Number = 0;
		private var _maxElevation:Number = 255;
		private var _exportmap:Boolean;
		private var _classname:String;
		private var _packagename:String;
		 
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
		* Creates a generate an as3 file of the elevation array.
		* @param	classname			String, the name of the class that will be exported.
		* @param	packagename	[optional] String. the name of the package that will be exported.
		* @param	exportmap			[optional] Boolean. Defines if the class should generate an array to pass to the ElevationReader.
		*/
		public function Elevation2AS3(classname:String, packagename:String = "", exportmap:Boolean = false)
        {
			_exportmap = exportmap;
			_classname = classname.substring(0,1).toUpperCase()+classname.substring(1,classname.length);
			_packagename = packagename.toLowerCase();
		}
		
		/**
		* Generate the string representing the mesh and optionally color information for the reader.
		*
		* @param	sourceBmd				Bitmapdata. The bitmapData to read from.
		* @param	channel					[optional] String. The channel information to read. supported "a", alpha, "r", red, "g", green, "b", blue and "av" (averages and luminance). Default is red channel "r".
		* @param	subdivisionX			[optional] int. The subdivision to read the pixels along the x axis. Default is 10.
		* @param	subdivisionY			[optional] int. The subdivision to read the pixels along the y axis. Default is 10.
		* @param	factorX					[optional] Number. The scale multiplier along the x axis. Default is 1.
		* @param	factorY					[optional] Number. The scale multiplier along the y axis. Default is 1.
		* @param	elevate					[optional] Number. The scale multiplier along the z axis. Default is .5.
		*/
		
		public function export(sourceBmd:BitmapData, channel:String = "r", subdivisionX:int = 10, subdivisionY:int = 10, factorX:Number = 1, factorY:Number = 1, elevate:Number = .5):void
		{
			var source:String = "package "+_packagename+"\n{\n\timport away3d.core.math.Number3D;\n";
			
			if(_exportmap){
				source += "\timport flash.display.BitmapData;\n";
				source += "\timport away3d.extrusions.ElevationReader;\n";
			}
			source += "\n\tpublic class "+_classname+"\n\t{\n";
			source += "\t\t//exporterversion:1.0;\n\n";
			source += "\t\tprivate var arr:Array;\n";
			if(_exportmap){
				var insert:String = getColorInfo(sourceBmd, channel, subdivisionX, subdivisionY, factorX, factorY, elevate);
				source += "\t\tprivate var arrc:Array;\n";
			}
			source += "\n\t\tpublic function "+_classname+"()\n\t\t{\n\t\t\tarr =[";
			 
			channel = channel.toLowerCase();
			
			var w:int = sourceBmd.width;
			var h:int = sourceBmd.height;
			var i:int;
			var j:int;
			var x:Number = 0;
			var y:Number = 0;
 			var z:Number = 0;
			var tmpArray:Array = [];
			var color:uint;
			var cha:Number;
			
			for(j = h-1; j >-subdivisionY; j-=subdivisionY)
			{
				y = (j<0)? 0 : j;
				tmpArray = [];
				source += (j == h-1)? "[" : "],[";
				for(i = 0; i < w+subdivisionX; i+=subdivisionX)
				{
					source += (i > 0)? "," : "";
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
					source += (x*factorX)+","+(y*factorY)+","+z;
				}
			}
			
			source += "]];\n\t\t};";
			
			if(_exportmap)
				source += insert;
				
			source += "\n\n\t\tpublic function get data():Array\n\t\t{\n\t\t\t\ var output:Array = [];\n\t\t\t var i:int;\n\t\t\t var j:int;\n\t\t\t var tmp:Array;\n\t\t\t var tmp2:Array;\n\n\t\t\t for(i = 0;i<arr.length;++i){\n\t\t\t\ttmp = arr[i];\n\t\t\t\ttmp2 = [];\n\t\t\t\tfor(j = 0;j<tmp.length;j+=3){\n\t\t\t\t\ttmp2.push(new Number3D(tmp[j], tmp[j+1], tmp[j+2]));\n\t\t\t\t}\n\t\t\t\toutput.push(tmp2);\n\t\t\t }\n\t\t\t\ return output;\n\t\t}\n\n\t}\n}";
			
			trace(source);
		}
		
		private function getColorInfo(sourceBmd:BitmapData, channel:String, subdivisionX:int, subdivisionY:int, factorX:Number, factorY:Number, elevate:Number):String
		{ 
			
			var w:Number = sourceBmd.width;
			var h:Number = sourceBmd.height;
			var i:int = 0;
			var j:int = 0;
			var px1:Number; 
			var px2:Number;
			var px3:Number;
			var px4:Number;
			var lockx:int;
			var locky:int;
			
			var colorinfo:String = "\n\n\t\tpublic function set map(elevationreader:ElevationReader):void\n\t\t{\n\t\t\t\televationreader.setSource( buildMap(), \""+channel+"\", "+factorX+", "+factorY+", "+elevate+");\n\t\t};\n\n\t\tpublic function buildMap():BitmapData\n\t\t{\n\t\t\tvar w:Number = "+w+";\n\t\t\tvar h:Number = "+h+";\n\t\t\tvar subdivisionX:Number = "+subdivisionX+";\n\t\t\tvar subdivisionY:Number = "+subdivisionY+";\n\t\t\tvar i:int = 0;\n\t\t\tvar j:int = 0;\n\t\t\tvar k:int = 0;\n\t\t\tvar l:int = 0;\n\t\t\tvar px1:Number;\n\t\t\tvar px2:Number;\n\t\t\tvar px3:Number;\n\t\t\tvar px4:Number;\n\t\t\tvar col:Number;\n\t\t\tvar incXL:Number;\n\t\t\tvar incXR:Number;\n\t\t\tvar incYL:Number;\n\t\t\tvar incYR:Number;\n\t\t\tvar pxx:Number;\n\t\t\tvar pxy:Number;\n\t\t\tvar index:int = 0;\n\t\t\tvar aCol:Array = [";
			
			var del:String;
			for(i = 0; i < w+1; i+=subdivisionX)
			{
				del = (i == 0)? "" : ",";
				if(i+subdivisionX > w)
				{
					lockx = w;
				} else {
					lockx = i+subdivisionX;
				}

				for(j = 0; j < h+1; j+=subdivisionY)
				{

					if(j+subdivisionY > h)
					{
						locky = h;
					} else {
						locky = j+subdivisionY;
					}
					 
					if(j == 0){
						switch(channel){
							case "a":
								px1 = sourceBmd.getPixel32(i, j) >> 24 & 0xFF;
								px2 = sourceBmd.getPixel32(lockx, j) >> 24 & 0xFF;
								px3 = sourceBmd.getPixel32(lockx, locky) >> 24 & 0xFF;
								px4 = sourceBmd.getPixel32(i, locky) >> 24 & 0xFF;
								break;
							case "r":
								px1 = sourceBmd.getPixel(i, j) >> 16 & 0xFF;
								px2 = sourceBmd.getPixel(lockx, j) >> 16 & 0xFF;
								px3 = sourceBmd.getPixel(lockx, locky) >> 16 & 0xFF;
								px4 = sourceBmd.getPixel(i, locky) >> 16 & 0xFF;
								break;
							case "g":
								px1 = sourceBmd.getPixel(i, j) >> 8 & 0xFF;
								px2 = sourceBmd.getPixel(lockx, j) >> 8 & 0xFF;
								px3 = sourceBmd.getPixel(lockx, locky) >> 8 & 0xFF;
								px4 = sourceBmd.getPixel(i, locky) >> 8 & 0xFF;
								break;
							case "b":
								px1 = sourceBmd.getPixel(i, j) & 0xFF;
								px2 = sourceBmd.getPixel(lockx, j) & 0xFF;
								px3 = sourceBmd.getPixel(lockx, locky) & 0xFF;
								px4 = sourceBmd.getPixel(i, locky) & 0xFF;
								break;
						}
						colorinfo += del+px1+","+px2+","+px3+","+px4;
					} else {
						
						px1 = px4;
						px2 = px3;
						switch(channel){
							case "a":
								px3 = sourceBmd.getPixel32(lockx, locky) >> 24 & 0xFF;
								px4 = sourceBmd.getPixel32(i, locky) >> 24 & 0xFF;
								break;
							case "r":
								px3 = sourceBmd.getPixel(lockx, locky) >> 16 & 0xFF;
								px4 = sourceBmd.getPixel(i, locky) >> 16 & 0xFF;
								break;
							case "g":
								px3 = sourceBmd.getPixel(lockx, locky) >> 8 & 0xFF;
								px4 = sourceBmd.getPixel(i, locky) >> 8 & 0xFF;
								break;
							case "b":
								px3 = sourceBmd.getPixel(lockx, locky) & 0xFF;
								px4 = sourceBmd.getPixel(i, locky) & 0xFF;
								break;
						}
						colorinfo += ","+px3+","+px4;
					}
				}
			}
				
				colorinfo += "];\n\t\t\tvar bmd:BitmapData = new BitmapData("+w+", "+h+", false, 0x000000);\n\t\t\tbmd.lock();\n\n\t\t\tfor(i = 0; i < w+1; i+=subdivisionX)\n\t\t\t{\n\t\t\t\tfor(j = 0; j < h+1; j+=subdivisionY)\n\t\t\t\t{\n\t\t\t\t\tif(j == 0){\n\t\t\t\t\t\tpx1 = aCol[index];\n\t\t\t\t\t\tpx2 = aCol[index+1];\n\t\t\t\t\t\tpx3 = aCol[index+2];\n\t\t\t\t\t\tpx4 = aCol[index+3];\n\t\t\t\t\t\tindex +=4;\n\n\t\t\t\t\t} else {\n\t\t\t\t\t\tpx1 = px4;\n\t\t\t\t\t\tpx2 = px3;\n\t\t\t\t\t\tpx3 = aCol[index];\n\t\t\t\t\t\tpx4 = aCol[index+1];\n\t\t\t\t\t\tindex +=2;\n\t\t\t\t\t}\n\n\t\t\t\t\tfor(k = 0; k < subdivisionX; ++k)\n\t\t\t\t\t{\n\t\t\t\t\t\tincXL = 1/subdivisionX * k;\n\t\t\t\t\t\tincXR = 1-incXL;\n\n\t\t\t\t\t\tfor(l = 0; l < subdivisionY; l++)\n\t\t\t\t\t\t{\n\t\t\t\t\t\t\tincYL = 1/subdivisionY * l;\n\t\t\t\t\t\t\tincYR = 1-incYL;\n\t\t\t\t\t\t\tpxx = ((px1*incXR) + (px2*incXL))*incYR;\n\t\t\t\t\t\t\tpxy = ((px4*incXR) + (px3*incXL))*incYL;\n\t\t\t\t\t\t\tbmd.setPixel(k+i, l+j, pxy+pxx << 16 );\n\t\t\t\t\t\t}\n\t\t\t\t\t}\n\t\t\t\t}\n\t\t\t}\n\n\t\t\tbmd.unlock();\n\n\t\t\treturn bmd;\n\n\t\t}\n";
				
				return colorinfo;
				 
			}

	}
}
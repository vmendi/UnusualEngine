﻿package away3d.materials.utils.data
{
	import away3d.core.math.Number3D;
		
	/**
	* Class holds typed data for the prebaking class
	*/
		
	public class LightData{
		
		public var lightfalloff:Number;
		public var lightradius:Number;
		public var brightness:Number;
		public var specular:Number;
		public var lightcolor:uint;
		public var lightR:int;
		public var lightG:int;
		public var lightB:int;
		public var ranges:Array;
		public var hit:int;
		public var lightposition:Number3D;
					
	}
}
﻿package away3d.materials.utils.data
{
	import flash.display.BitmapData;
	import away3d.core.base.Mesh;
	import away3d.core.math.Number3D;
	
	/**
	* Class holds typed data for the prebaking class
	*/
		
	public class MeshData{
		
		public var tracemap:BitmapData;
		public var sourcemap:BitmapData;
		public var backsourcemap:BitmapData;
		public var backtracemap:BitmapData;
		public var imagename:String;
		public var scenePosition:Number3D;
		public var rotations:Number3D;
		public var mesh:Mesh;
		public var id:int;
		public var index:int;
		public var backcloned:Boolean;
		public var frontcloned:Boolean;
		public var render:Boolean = true;
		public var proxdist:Number;
		
	}
}
﻿package away3d.materials.utils.data
{
	/**
	* Class holds typed data for the prebaking class
	*/
	import flash.display.BitmapData;
	
	public class RenderData{
		
		public var name:String;
		public var source:BitmapData;
		public var isBack:Boolean;
		
		function RenderData(name:String, source:BitmapData, isBack:Boolean = false){
			this.name = name;
			this.source = source;
			this.isBack = isBack;
		}
	}
}
﻿package away3d.materials.utils.data
{
	/**
	* Class holds typed data for the prebaking and the normalgenerator classes
	*/
		
	public class LScan{
		
		public var x:int;
		public var y:int;
		public var color:uint;
		
		function LScan(x:int, y:int, col:uint = 0){
			this.x = x;
			this.y = y;
			this.color = col;
		}
	}
}
﻿package away3d.animators.data
{
	import away3d.core.math.Number3D;
	/**
	 * Holds information about a single Path definition.
	 */
    public class Path
    {
    	/**
    	 * The array that contains the path definition.
    	 */
        public var aSegments:Array;
		
		/**
    	 * The worldAxis of reference
    	 */
		public var worldAxis:Number3D = new Number3D(0,1,0);
    	
		
        private var _smoothed:Boolean;
		/**
    	 * returns true if the smoothPath handler is being used.
    	 */
		public function get smoothed():Boolean
		{
			return _smoothed;
		}
		
		private var _averaged:Boolean;
		/**
    	* returns true if the averagePath handler is being used.
    	*/
		public function get averaged():Boolean
		{
			return _averaged;
		}
		/**
		 * Creates a new <code>Path</code> object.
		 * 
		 * @param	 aVectors		An array of a series of number3D's organized in the following fashion. [a,b,c,a,b,c etc...] a = v1, b=vc (control point), c = v2
		 */
        public function Path(aVectors:Array)
        {
			if(aVectors.length < 3)
				throw new Error("Path array must contain at least 3 Number3D's");
			
            this.aSegments = [];
			for(var i:int = 0; i<aVectors.length; i+=3)
				this.aSegments.push( new CurveSegment(aVectors[i], aVectors[i+1], aVectors[i+2]) );
			 
        }
		
		/**
		 * adds a CurveSegment to the path
		 * @see CurveSegment:
		 */
		public function add(cs:CurveSegment):void
        {
			this.aSegments.push(cs);
        }
		
		/**
		 * returns the length of the Path elements array
		 * 
		 * @return	an integer: the length of the Path elements array
		 */
		public function get length():int
        {
			return this.aSegments.length;
        }
		
		/**
		 * returns the Path elements array
		 * 
		 * @return	an Array: the Path elements array
		 */
		public function get array():Array
        {
			return this.aSegments;
        }
		
		/**
		 * removes a segment in the path according to id.
		 * 
		 */
		public function removeSegment(index:int):void
        {
			if(index<= this.aSegments.length-2){
				var nextSeg:Number3D = this.aSegments[index+1].v0;
				nextSeg = this.aSegments[index].v1;
			}
			this.aSegments.splice(index, 1);
        }
		
		/**
		 * handler will smooth the path using anchors as control vector of the CurveSegments 
		 * note that this is not dynamic, the CurveSegments values are overwrited
		 */
		public function smoothPath():void
        {
			if(this.aSegments.length <= 2)
				return;
			 
			_smoothed = true;
			_averaged = false;
			 
			var x:Number;
			var y:Number;
			var z:Number;
			var seg0:Number3D;
			var seg1:Number3D;
			var tmp:Array = [];
			var i:int;
			
			var startseg:Number3D = new Number3D(this.aSegments[0].v0.x, this.aSegments[0].v0.y, this.aSegments[0].v0.z);
			var endseg:Number3D = new Number3D(this.aSegments[this.aSegments.length-1].v1.x, 
																		this.aSegments[this.aSegments.length-1].v1.y,
																		this.aSegments[this.aSegments.length-1].v1.z);
			for(i = 0; i< length-1; ++i)
			{
				if(this.aSegments[i].vc == null)
					this.aSegments[i].vc = this.aSegments[i].v1;
				
				if(this.aSegments[i+1].vc == null)
					this.aSegments[i+1].vc = this.aSegments[i+1].v1;
				
				seg0 = this.aSegments[i].vc;
				seg1 = this.aSegments[i+1].vc;
				x = (seg0.x + seg1.x) * .5;
				y = (seg0.y + seg1.y) * .5;
				z = (seg0.z + seg1.z) * .5;
				
				tmp.push( startseg,  new Number3D(seg0.x, seg0.y, seg0.z), new Number3D(x, y, z));
				startseg = new Number3D(x, y, z);
				this.aSegments[i] = null;
			}
			
			seg0 = this.aSegments[this.aSegments.length-1].vc;
			tmp.push( startseg,  new Number3D((seg0.x+seg1.x)*.5, (seg0.y+seg1.y)*.5, (seg0.z+seg1.z)*.5), endseg);
			
			this.aSegments[0] = null;
			this.aSegments = [];
			
			for(i = 0; i<tmp.length; i+=3)
				this.aSegments.push( new CurveSegment(tmp[i], tmp[i+1], tmp[i+2]) );
				tmp[i] = tmp[i+1] = tmp[i+2] = null;
			 
			tmp = null;
		}
		
		/**
		 * handler will average the path using averages of the CurveSegments
		 * note that this is not dynamic, the path values are overwrited
		 */
		
		public function averagePath():void
        {
			_averaged = true;
			_smoothed = false;
			
			for(var i:int = 0; i<this.aSegments.length; ++i){
				this.aSegments[i].vc.x = (this.aSegments[i].v0.x+this.aSegments[i].v1.x)*.5;
				this.aSegments[i].vc.y = (this.aSegments[i].v0.y+this.aSegments[i].v1.y)*.5;
				this.aSegments[i].vc.z = (this.aSegments[i].v0.z+this.aSegments[i].v1.z)*.5;
			}
        }

    }
}
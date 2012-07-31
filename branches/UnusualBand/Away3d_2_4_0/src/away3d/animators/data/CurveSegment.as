﻿package away3d.animators.data
{
	import away3d.core.math.Number3D;
	/**
	 * Holds information about a segment of a curve.
	 */
    public class CurveSegment
    {
    	/**
    	 * coordinates first anchor.
    	 */
        public var v0:Number3D;
		
		/**
    	 * coordinates control vector for this curve.
    	 */
        public var vc:Number3D;
		
		/**
    	 * coordinates end anchor.
    	 */
        public var v1:Number3D;
    	
		/**
		 * Creates a new <code>Segment</code> object.
		 * 
		 * @param	 v0			A Number3D, the start anchor vector of the curve
		 * @param	 vc			A Number3D, the control vector of the curve
		 * @param	 v1			A Number3D, the end anchor vector of the curve
		 */
        public function CurveSegment(v0:Number3D, vc:Number3D, v1:Number3D)
        {
            this.v0 = v0;
			this.vc = vc;
			this.v1 = v1;
        }
		
    }
}
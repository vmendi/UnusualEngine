﻿package away3d.core.filter
{
    import away3d.cameras.*;
    import away3d.containers.*;
    import away3d.core.clip.*;
    import away3d.core.draw.*;

    /**
    * Defines a maximum z value for rendering primitives
    */
    public class ZDepthFilter implements IPrimitiveFilter
    {
    	private var _primitives:Array;
		private var _maxZ:Number;
    	
		/**
		 * Creates a new <code>ZDepthFilter</code> object.
		 *
		 * @param	maxZ	A maximum allowed depth value for drawing primitives.
		 */
		function ZDepthFilter(maxZ:Number){
			_maxZ = maxZ;
		}
        
		/**
		 * @inheritDoc
		 */
        public function filter(primitives:Array, scene:Scene3D, camera:Camera3D, clip:Clipping):Array
        {
				_primitives = [];
				var pri:DrawPrimitive;
				for each (pri in primitives) {
					if (pri.screenZ < _maxZ)
						_primitives.push(pri); 
				}

            	return _primitives;
        }
		
		/**
		 * Used to trace the values of a filter.
		 * 
		 * @return A string representation of the filter object.
		 */
        public function toString():String
        {
            return "ZDepthFilter";
        }
    }
}
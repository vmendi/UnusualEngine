﻿package away3d.core.filter
{
    import away3d.cameras.*;
    import away3d.containers.*;
    import away3d.core.clip.*;
    /**
    * Defines a maximum allowed drawing primitives.
    */
    public class MaxPolyFilter implements IPrimitiveFilter
    {
		private var _maxP:int;
    	
		/**
		 * Creates a new <code>MaxPolyFilter</code> object.
		 *
		 * @param	maxP		A maximum allowed drawing primitives. Default = 1000;
		 */
		function MaxPolyFilter(maxP:int = 1000){
			_maxP = maxP;
		}
        
		/**
		 * @inheritDoc
		 */
        public function filter(primitives:Array, scene:Scene3D, camera:Camera3D, clip:Clipping):Array
        {
			if(primitives.length > _maxP)
				primitives.sortOn("screenZ", Array.NUMERIC);
				primitives.splice(_maxP);
			
			return primitives;
        }
		
		/**
		 * Used to trace the values of a filter.
		 * 
		 * @return A string representation of the filter object.
		 */
        public function toString():String
        {
            return "MaxPolyFilter";
        }
    }
}
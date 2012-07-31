﻿package away3d.events
{
    import away3d.animators.PathAnimator;
    import flash.events.Event;
    
    public class PathEvent extends Event
    {
    	static public var CYCLE:String = "cycle";
		static public var RANGE:String = "range";
		static public var CHANGE_SEGMENT:String = "change_segment";
    	
        public var pathanimator:PathAnimator;

        public function PathEvent(type:String, pathanimator:PathAnimator)
        {
            super(type);
            this.pathanimator = pathanimator;
        }
    }
}

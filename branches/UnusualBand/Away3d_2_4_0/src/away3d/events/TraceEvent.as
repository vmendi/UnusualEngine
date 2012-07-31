﻿package away3d.events
{
	import flash.events.Event;
	
	public class TraceEvent extends Event {
		
		// total process
		public var percent:Number = 0;
		// if more images are processed, represents the actual index
		public var count:int = 0;
		// process percent on actual processed image
		public var percentPart:Number = 0;
		// total images to be processed
		public var totalParts:Number = 1;
		
		/**
    	 * Defines the value of the type property of a tracecomplete event object.
    	 */
    	public static const TRACE_COMPLETE:String = "tracecomplete";
		
		/**
    	 * Defines the value of the type property of a traceprogress event object.
    	 */
    	public static const TRACE_PROGRESS:String = "traceprogress";
		
		/**
    	 * Defines the value of the type property of a tracecount event object.
    	 */
    	public static const TRACE_COUNT:String = "tracecount";
		
		
		function TraceEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false){
			super(type, bubbles, cancelable);
		}
		
	}
}
 
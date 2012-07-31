﻿package away3d.events
{
    import away3d.core.base.*;
    import away3d.loaders.AbstractParser;
    
    import flash.events.Event;
    
    /**
    * Passed as a parameter when a 3d object loader event occurs
    */
    public class ParserEvent extends Event
    {
		/**
    	 * Defines the value of the type property of a parseSuccess event object.
    	 */
    	public static const PARSE_SUCCESS:String = "parseSuccess";
		
		/**
    	 * Defines the value of the type property of a parseError event object.
    	 */
    	public static const PARSE_ERROR:String = "parseError";
		
		/**
    	 * Defines the value of the type property of a parseProgress event object.
    	 */
    	public static const PARSE_PROGRESS:String = "parseProgress";
		
    	/**
    	 * A reference to the loader object that is relevant to the event.
    	 */
        public var parser:AbstractParser;
        
    	/**
    	 * A reference to the parsed object that is relevant to the event.
    	 */
        public var result:Object3D;
        
		/**
		 * Creates a new <code>ParserEvent</code> object.
		 * 
		 * @param	type	The type of the event. Possible values are: <code>Loader3DEvent.PARSE_SUCCESS</code>, <code>Loader3DEvent.PARSE_ERROR</code> and <code>Loader3DEvent.PARSE_PROGRESS</code>.
		 * @param	parser	A reference to the parser object that is relevant to the event.
		 * @param	result	A reference to the parsed object that is relevant to the event.
		 */
        public function ParserEvent(type:String, parser:AbstractParser, result:Object3D)
        {
            super(type);
            this.parser = parser;
            this.result = result;
        }
		
		/**
		 * Creates a copy of the Loader3DEvent object and sets the value of each property to match that of the original.
		 */
        public override function clone():Event
        {
            return new ParserEvent(type, parser, result);
        }
    }
}
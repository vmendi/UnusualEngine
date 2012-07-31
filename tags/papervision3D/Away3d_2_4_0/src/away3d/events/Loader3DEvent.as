﻿package away3d.events
{
    import away3d.loaders.Loader3D;
    
    import flash.events.Event;
    
    /**
    * Passed as a parameter when a 3d object loader event occurs
    */
    public class Loader3DEvent extends Event
    {
    	/**
    	 * Defines the value of the type property of a loadSuccess event object.
    	 */
    	public static const LOAD_SUCCESS:String = "loadSuccess";
    	
    	/**
    	 * Defines the value of the type property of a loadProgress event object.
    	 */
    	public static const LOAD_PROGRESS:String = "loadProgress";
    	
    	/**
    	 * Defines the value of the type property of a loadError event object.
    	 */
    	public static const LOAD_ERROR:String = "loadError";
    	
    	/**
    	 * A reference to the loader object that is relevant to the event.
    	 */
        public var loader:Loader3D;
		
		/**
		 * Creates a new <code>Loader3DEvent</code> object.
		 * 
		 * @param	type	The type of the event. Possible values are: <code>Loader3DEvent.LOAD_SUCCESS</code> and <code>Loader3DEvent.LOAD_ERROR</code>.
		 * @param	loader	A reference to the loader object that is relevant to the event.
		 */
        public function Loader3DEvent(type:String, loader:Loader3D)
        {
            super(type);
            this.loader = loader;
        }
		
		/**
		 * Creates a copy of the Loader3DEvent object and sets the value of each property to match that of the original.
		 */
        public override function clone():Event
        {
            return new Loader3DEvent(type, loader);
        }
    }
}

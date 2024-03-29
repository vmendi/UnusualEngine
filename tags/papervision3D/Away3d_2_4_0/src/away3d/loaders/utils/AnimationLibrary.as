﻿package away3d.loaders.utils
{
    import away3d.core.utils.Debug;
    import away3d.loaders.data.*;
    
    import flash.utils.Dictionary;
    
    /**
    * Store for all animations associated with an externally loaded file.
    */
    public dynamic class AnimationLibrary extends Dictionary
    {
    	/**
    	 * Adds an animation name reference to the library.
    	 */
        public function addAnimation(name:String):AnimationData
        {
        	//return if animation already exists
        	if (this[name])
        		return this[name];
        	
        	var animationData:AnimationData = new AnimationData();
            this[animationData.name = name] = animationData;
            return animationData;
        }
        
    	/**
    	 * Returns an animation data object for the given name reference in the library.
    	 */
        public function getAnimation(name:String):AnimationData
        {
        	//return if animation exists
        	if (this[name])
        		return this[name];
        	
        	Debug.warning("Animation '" + name + "' does not exist");
        	
        	return null;
        }
    }
}

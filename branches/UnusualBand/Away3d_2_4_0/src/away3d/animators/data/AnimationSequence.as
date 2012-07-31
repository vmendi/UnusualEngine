﻿package away3d.animators.data
{
   
	/**
	 * Holds information about a sequence of animation frames.
	 */
    public class AnimationSequence
    {
    	/**
    	 * The prefix string defining frames in the sequence.
    	 */
        public var prefix:String;
        
        /**
        * Determines if the animation should be smoothed (interpolated) between frames.
        */
        public var smooth:Boolean;
        
        /**
        * Determines whether the animation sequence should loop.
        */
        public var loop:Boolean;
    	
        /**
        * Determines the speed of playback in frames per second.
        */
        public var fps:Number;
        
		/**
		 * Creates a new <code>AnimationSequence</code> object.
		 * 
		 * @param	prefix		The prefix string defining frames in the sequence.
		 * @param	smooth		[optional] Determines if the animation should be smoothed (interpolated) between frames. Default = true;
		 * @param	loop			[optional] Determines whether the animation sequence should loop. Default = false;
		 * @param	fps			[optional] Determines the speed of playback in keyframes of per second.  Default = 3;
		 */
        public function AnimationSequence(prefix:String, smooth:Boolean = true, loop:Boolean = false, fps:Number = 3)
        {
            this.prefix = (prefix == null)? "" : prefix;
            this.smooth = smooth;
            this.loop = loop;
            this.fps = fps;
			
			if(this.prefix == "")
				trace("Prefix is null, this might cause enter endless loop");
        }
    }
}
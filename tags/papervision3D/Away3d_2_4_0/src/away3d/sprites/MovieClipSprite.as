﻿package away3d.sprites
{
    import away3d.core.base.*;
    import away3d.core.project.*;
    import away3d.core.utils.*;
    
    import flash.display.DisplayObject;
	
	/**
	 * Spherical billboard (always facing the camera) sprite object that uses a movieclip as it's texture.
	 * Draws individual display objects inline with z-sorted triangles in a scene.
	 */
    public class MovieClipSprite extends Object3D
    {
		/**
		 * Defines the displayobject to use for the sprite texture.
		 */
        public var movieclip:DisplayObject;
        
        /**
        * Defines the overall scaling of the sprite object
        */
        public var scaling:Number;
        
        /**
        * An optional offset value added to the z depth used to sort the sprite
        */
        public var deltaZ:Number;
        
        /**
        * Defines whether the sprite should scale with distance from the camera. Defaults to false
        */
		public var rescale:Boolean;
		
		 /**
        * Defines how the sprite should be align to its registration point. 
		* values can be: none, center, topcenter, bottomcenter, right, topright, bottomright, left, topleft or bottomleft. 
		* The align considers the width and height of the movieclip. Top left 0,0 in movieclip source. Use 'none' in case of centered mc with variable width. Default = center;
        */
		public var align:String;
    	
		/**
		 * Creates a new <code>MovieClipSprite</code> object.
		 * 
		 * @param	movieclip			The displayobject to use as the sprite texture.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function MovieClipSprite(movieclip:DisplayObject, init:Object = null)
        {
            super(init);

            this.movieclip = movieclip;

            scaling = ini.getNumber("scaling", 1);
            deltaZ = ini.getNumber("deltaZ", 0);
			rescale = ini.getBoolean("rescale", false);
			align = ini.getString("align", "center");
			
			projectorType = ProjectorType.MOVIE_CLIP_SPRITE;
        }
    }
}

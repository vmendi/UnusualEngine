﻿package away3d.core.light
{	
	import flash.display.*;

    /**
    * Abstract light primitve.
    */
    public class LightPrimitive
    {
 		/**
 		 * Red component level.
 		 */
        public var red:Number;
        
 		/**
 		 * Green component level.
 		 */
        public var green:Number;
        
 		/**
 		 * Blue component level.
 		 */
        public var blue:Number;
		
		/**
 		 * radius of the light.
 		 */
		public var radius:Number;
		
		/**
 		 * falloff radius of the light.
 		 */
		public var fallOff:Number;
		 
		/**
		 * Coefficient for the ambient light intensity.
		 */
        public var ambient:Number;
		
		/**
		 * Coefficient for the diffuse light intensity.
		 */
        public var diffuse:Number;
		
		/**
		 * Coefficient for the specular light intensity.
		 */
        public var specular:Number;
		
		/**
		 * Lightmap for ambient intensity.
		 */
        public var ambientBitmap:BitmapData;
		
		/**
		 * Lightmap for diffuse intensity.
		 */
        public var diffuseBitmap:BitmapData;
        		
		/**
		 * Combined lightmap for ambient and diffuse intensities.
		 */
        public var ambientDiffuseBitmap:BitmapData;
		
		/**
		 * Lightmap for specular intensity.
		 */
    	public var specularBitmap:BitmapData;
	}
}
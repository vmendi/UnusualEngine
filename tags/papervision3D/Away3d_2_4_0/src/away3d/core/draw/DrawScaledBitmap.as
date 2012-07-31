﻿package away3d.core.draw
{
	import away3d.arcane;
    import away3d.core.base.*;
    import away3d.core.render.*;
    
    import flash.display.BitmapData;
    import flash.geom.Matrix;
    import flash.geom.Point;

	use namespace arcane;
	
    /** Scaled bitmap primitive */
    public class DrawScaledBitmap extends DrawPrimitive
    {
        private var cos:Number;
        private var sin:Number;
        private var cosw:Number;
        private var cosh:Number;
		private var sinw:Number;
        private var sinh:Number;
        private var pointMapping:Matrix;
        private var mapping:Matrix = new Matrix();
        private var width:Number;
        private var height:Number;
        
    	/**
    	 * The bitmapData object used as the scaled bitmap primitive texture.
    	 */
        public var bitmap:BitmapData;
        
    	/**
    	 * The x value of the screenvertex used to position the scaled bitmap primitive in the view.
    	 */
        public var vx:Number;
		
    	/**
    	 * The y value of the screenvertex used to position the scaled bitmap primitive in the view.
    	 */
        public var vy:Number;
        
    	/**
    	 * The z value of the screenvertex used to position the scaled bitmap primitive in the view.
    	 */
        public var vz:Number;
        		
		/**
		 * The topleft x position of the billboard primitive.
		 */
        public var topleftx:Number;
				
		/**
		 * The topleft y position of the billboard primitive.
		 */
        public var toplefty:Number;
		
		/**
		 * The topright x position of the billboard primitive.
		 */
        public var toprightx:Number;
				
		/**
		 * The topright y position of the billboard primitive.
		 */
        public var toprighty:Number;
		
		/**
		 * The bottomleft x position of the billboard primitive.
		 */
        public var bottomleftx:Number;
				
		/**
		 * The bottomleft y position of the billboard primitive.
		 */
        public var bottomlefty:Number;
		
		/**
		 * The bottomright x position of the billboard primitive.
		 */
        public var bottomrightx:Number;
        		
		/**
		 * The bottomright y position of the billboard primitive.
		 */
        public var bottomrighty:Number;
        
		/**
    	 * A scaling value used to scale the scaled bitmap primitive.
    	 */
        public var scale:Number;
        
        /**
        * A rotation value used to rotate the scaled bitmap primitive.
        */
        public var rotation:Number;
        
        /**
        * Determines whether the texture bitmap is smoothed (bilinearly filtered) when drawn to screen.
        */
        public var smooth:Boolean;
        
		/**
		 * @inheritDoc
		 */
        public override function calc():void
        {
            screenZ = vz;
            minZ = screenZ;
            maxZ = screenZ;
            width = bitmap.width*scale;
            height = bitmap.height*scale;
                        
            if (rotation != 0) {
	            cos = Math.cos(rotation*Math.PI/180);
	            sin = Math.sin(rotation*Math.PI/180);
	            
	            cosw = cos*width/2;
	            cosh = cos*height/2;
	            sinw = sin*width/2;
	            sinh = sin*height/2;
	            
	            topleftx = vx - cosw - sinh;
	            toplefty = vy + sinw - cosh;
	            toprightx = vx + cosw - sinh;
	            toprighty = vy - sinw - cosh;
	            bottomleftx = vx - cosw + sinh;
	            bottomlefty = vy + sinw + cosh;
	            bottomrightx = vx + cosw + sinh;
	            bottomrighty = vy - sinw + cosh;

	            var boundsArrayx:Array = [];
	            boundsArrayx.push(topleftx);
	            boundsArrayx.push(toprightx);
	            boundsArrayx.push(bottomleftx);
	            boundsArrayx.push(bottomrightx);
	            minX = 100000;
	            maxX = -100000;
	            var boundsx:int;
	            for each (boundsx in boundsArrayx) {
	            	if (minX > boundsx)
	            		minX = boundsx;
	            	if (maxX < boundsx)
	            		maxX = boundsx;
	            }
	            
	            var boundsArrayy:Array = [];
	            boundsArrayy.push(toplefty);
	            boundsArrayy.push(toprighty);
	            boundsArrayy.push(bottomlefty);
	            boundsArrayy.push(bottomrighty);
	            minY = 100000;
	            maxY = -100000;
	            var boundsy:int;
	            for each (boundsy in boundsArrayy) {
	            	if (minY > boundsy)
	            		minY = boundsy;
	            	if (maxY < boundsy)
	            		maxY = boundsy;
	            }
	            
	            mapping.a = scale*cos;
	            mapping.b = -scale*sin;
	            mapping.c = scale*sin;
	            mapping.d = scale*cos;
	            mapping.tx = topleftx;
	            mapping.ty = toplefty;	            
            } else {
            	topleftx = vx - width/2;
	            toplefty = vy - height/2;
	            toprightx = topleftx+width;
	            toprighty = toplefty;
	            bottomleftx = topleftx;
	            bottomlefty = toplefty+height;
	            bottomrightx = toprightx;
	            bottomrighty = bottomlefty;
	            
            	minX = topleftx;
            	minY = toplefty;
            	maxX = bottomrightx;
            	maxY = bottomrighty;
	            mapping.a = mapping.d = scale;
	            mapping.c = mapping.b = 0;
	            mapping.tx = topleftx;
	            mapping.ty = toplefty;
            }
        }
        
		/**
		 * @inheritDoc
		 */
        public override function clear():void
        {
            bitmap = null;
        }			
        
		/**
		 * @inheritDoc
		 */
        public override function render():void
        {
			source.session.renderScaledBitmap(this, bitmap, mapping, smooth);
        }
        
		/**
		 * @inheritDoc
		 */
        public override function contains(x:Number, y:Number):Boolean
        {
            if (rotation != 0) {
	            if (topleftx*(y - toprighty) + toprightx*(toplefty - y) + x*(toprighty - toplefty) > 0.001)
	                return false;
	            
	            if (toprightx*(y - bottomrighty) + bottomrightx*(toprighty - y) + x*(bottomrighty - toprighty) > 0.001)
	                return false;
	            
	            if (bottomrightx*(y - bottomlefty) + bottomleftx*(bottomrighty - y) + x*(bottomlefty - bottomrighty) > 0.001)
	                return false;
	            
	            if (bottomleftx*(y - toplefty) + topleftx*(bottomlefty - y) + x*(toplefty - bottomlefty) > 0.001)
	                return false;
            }
            
            if (!bitmap.transparent)
                return true;
            
            pointMapping = mapping.clone();
            pointMapping.invert();
            
            var p:Point = pointMapping.transformPoint(new Point(x, y));
            if (p.x < 0)
                p.x = 0;
            if (p.y < 0)
                p.y = 0;
            if (p.x >= bitmap.width)
                p.x = bitmap.width-1;
            if (p.y >= bitmap.height)
                p.y = bitmap.height-1;
			
            var pixelValue:uint = bitmap.getPixel32(int(p.x), int(p.y));
            return uint(pixelValue >> 24) > 0x80;
        }
    }
}

﻿package away3d.core.draw
{
	import away3d.arcane;
	import away3d.core.utils.*;
	import away3d.materials.*;
	
	import flash.geom.*;

	use namespace arcane;
	
    /** Billboard primitive */
    public class DrawBillboard extends DrawPrimitive
    {
        private var cos:Number;
        private var sin:Number;
        private var cosw:Number;
        private var cosh:Number;
		private var sinw:Number;
        private var sinh:Number;
        private var uvMaterial:IUVMaterial;
        private var pointMapping:Matrix;
        private var w:Number;
        private var h:Number;
        private var _index:int;
        
        public var mapping:Matrix = new Matrix();
        
    	/**
    	 * The index of the screenvertex used to position the billboard primitive in the view.
    	 */
        public var index:int;
		
        public var screenVertices:Array;
        
        public var screenIndices:Array;
        
		/**
		 * The x position of the screenvertex of the billboard primitive.
		 */
        public var vx:Number;
        
		/**
		 * The y position of the screenvertex of the billboard primitive.
		 */
        public var vy:Number;
		
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
    	 * A scaling value used to scale the billboard primitive relative to the dimensions of a uv material.
    	 */
        public var scale:Number;
		
		/**
    	 * The width of the billboard if a non-uv material is used.
    	 */
        public var width:Number;
		
		/**
    	 * The height of the billboard if a non-uv material is used.
    	 */
        public var height:Number;
        
        /**
        * A rotation value used to rotate the scaled bitmap primitive.
        */
        public var rotation:Number;
        
    	/**
    	 * A reference to the billboard value object used by the billboard primitive.
    	 */
        public var billboardVO:BillboardVO;
        
    	/**
    	 * The material object used as the billboard primitive's texture.
    	 */
        public var material:IBillboardMaterial;
        
		/**
		 * @inheritDoc
		 */
        public override function calc():void
        {
        	_index = screenIndices[index]*3;
        	vx = screenVertices[_index];
        	vy = screenVertices[_index+1];
        	screenZ = screenVertices[_index+2];
        	
            minZ = screenZ;
            maxZ = screenZ;
            uvMaterial = material as IUVMaterial;
            if (uvMaterial) {
	            w = uvMaterial.width*scale;
	            h = uvMaterial.height*scale;
            } else {
            	w = width*scale;
            	h = height*scale;
            }
                        
            if (rotation != 0) {
	            cos = Math.cos(rotation*Math.PI/180);
	            sin = Math.sin(rotation*Math.PI/180);
	            
	            cosw = cos*w/2;
	            cosh = cos*h/2;
	            sinw = sin*w/2;
	            sinh = sin*h/2;
	            
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
            	bottomrightx = toprightx = (bottomleftx = topleftx = vx - w/2) + w;
	            bottomrighty = bottomlefty = (toprighty = toplefty = vy - h/2) + h;
	            
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
            //screenvertex = null;
        }			
        
		/**
		 * @inheritDoc
		 */
        public override function render():void
        {
			material.renderBillboard(this);
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
            
            uvMaterial = material as IUVMaterial;
            
            if (!uvMaterial || !uvMaterial.bitmap.transparent)
                return true;
            
            pointMapping = mapping.clone();
            pointMapping.invert();
            
            var p:Point = pointMapping.transformPoint(new Point(x, y));
            if (p.x < 0)
                p.x = 0;
            if (p.y < 0)
                p.y = 0;
            if (p.x >= uvMaterial.width)
                p.x = uvMaterial.width-1;
            if (p.y >= uvMaterial.height)
                p.y = uvMaterial.height-1;
			
            var pixelValue:uint = uvMaterial.bitmap.getPixel32(int(p.x), int(p.y));
            return uint(pixelValue >> 24) > 0x80;
        }
    }
}
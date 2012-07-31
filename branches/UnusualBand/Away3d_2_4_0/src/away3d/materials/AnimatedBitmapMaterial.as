﻿
package away3d.materials
{
    import away3d.arcane;
    import away3d.core.utils.*;
    
    import flash.display.*;
    import flash.events.Event;
    import flash.geom.*;
    import flash.utils.getTimer;

	use namespace arcane;
	
    /**
    * Bitmap material that allows fast rendering of animations by caching bitmapdata objects for each frame.
    * Not suitable for use with long animations, where the initialisation time will be lengthy and the memory footprint large.
    * If interactive movieclip properties are required, please refer to MovieMaterial.
	*/
    public class AnimatedBitmapMaterial extends TransformBitmapMaterial implements ITriangleMaterial, IUVMaterial
    {
		private var _broadcaster:Sprite = new Sprite();
		private var _playing:Boolean;
		private var _index:int;
		private var _cache:Array;
        
		private function update(event:Event = null):void
        {
			//increment _index
			if (_index < _cache.length - 1)
				_index++;
			else if (loop)
				_index = 0;
			_renderBitmap = _bitmap = _cache[_index];
			_bitmapDirty = true;
		}
		
		/**
		 * Indicates whether the animation will loop.
		 */
		public var loop:Boolean;
		
		/**
		 * Indicates whether the animation will start playing on initialisation.
		 * If false, only the first frame is displayed.
		 */
		public var autoplay:Boolean;
    	
		/**
		 * Creates a new <code>AnimatedBitmapMaterial</code> object.
		 *
		 * @param	movie				The movieclip to be bitmap cached for use in the material.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function AnimatedBitmapMaterial(movie:MovieClip, init:Object = null)
        {
			setMovie(movie);
			super(_cache[_index], init);
			
			loop = ini.getBoolean("loop", true);
			autoplay = ini.getBoolean("autoplay", true);
			_index = ini.getInt("_index", 0, {min:0, max:movie.totalFrames - 1});
			
			//add event listener
			if (autoplay)
			play();
            
    			//trigger first frame
			if (loop || autoplay)
				update();
			else
			_renderBitmap = _bitmap = _cache[_index];
    			
        }
        
        /**
        * Resumes playback of the animation
        */
        public function play():void
        {
        	if (!_playing) {
	        	_playing = true;
	        	_broadcaster.addEventListener(Event.ENTER_FRAME, update);
	        }
        }
        
        /**
        * Halts playback of the animation
        */
        public function stop():void
        {
        	if (_playing) {
	        	_playing = false;
	        	_broadcaster.removeEventListener(Event.ENTER_FRAME, update);
	        }        	
        }
		
    	/**
    	 * Resets the movieclip used by the material.
    	 * 
    	 * @param	movie	The movieclip to be bitmap cached for use in the material.
    	 */
		public function setMovie(movie:MovieClip):void
		{
			_cache = [];
			
			//determine boundaries of this movie
			var i:int;
			var rect:Rectangle;
			var minX:Number = 100000;
			var minY:Number = 100000;
			var maxX:Number = -100000;
			var maxY:Number = -100000;
			
			i = movie.totalFrames;
			while (i--)
			{
				movie.gotoAndStop(i);
				rect = movie.getBounds(movie);
				if (minX > rect.left)
				minX = rect.left;
				if (minY > rect.top)
				minY = rect.top;
				if (maxX < rect.right)
				maxX = rect.right;
				if (maxY < rect.bottom)
				maxY = rect.bottom;
			}
			
			//draw the cached bitmaps
			var W:int = maxX - minX;
			var H:int = maxY - minY;
			var mat:Matrix = new Matrix(1, 0, 0, 1, -minX, -minY);
			var tmp_bmd:BitmapData;
			var timer:int = getTimer();
			for(i=1; i<movie.totalFrames+1; ++i) {
				//draw frame and store in cache
				movie.gotoAndStop(i);
				tmp_bmd = new BitmapData(W, H, true, 0x00FFFFFF);
				tmp_bmd.draw(movie, mat, null, null, tmp_bmd.rect, true);
				_cache.push(tmp_bmd);
			
				//error timeout for time over 2 seconds
				if (getTimer() - timer > 2000) throw new Error("AnimatedBitmapMaterial contains too many frames. MovieMaterial should be used instead.");
			 
			}
		}
		
		/**
		 * Resets the cached bitmapData objects making up the animation with a pre-defined array.
		 */
		public function setFrames(sources:Array):void
        {
			var i:int;
			var _length:int = _cache.length;
			if(_length>0){
				for(i = 0; i<_length;++i){
					_cache[i].dispose();
				}
			}
			_length = sources.length;
			_cache = [];
			if (_index > _length - 1)
				_index = _length - 1;
			
			for(i = 0; i<_length; ++i){
				_cache.push(sources[i]);
			}
			_renderBitmap = _bitmap = _cache[_index];
		}
		
		/**
		 * Manually sets the frame index of the animation.
		 */
		public function set index(f:int):void
        {
			_index = (f<0)? 0 : (f>_cache.length - 1)? _cache.length - 1 : f; 
			_renderBitmap = _bitmap = _cache[_index];		
		}
		/**
		 * returns the frame index of the animation.
		 */
		public function get index():int
        {
			return _index;		
		}
		
		/**
		 * Manually clears all frames of the animation.
		 * a new series of bitmapdatas will be required using the setFrames handler.
		 */
		public function clear():void
        {
			stop();
			var _length:int = _cache.length;
			if(_length>0){
				for(var i:int = 0; i<_length;++i){
					_cache[i].dispose();
				}
			}
			_cache = [];
		}
    }
}
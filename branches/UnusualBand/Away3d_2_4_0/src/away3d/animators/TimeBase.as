﻿package away3d.animators
{
	import away3d.containers.Scene3D;

	public class TimeBase
	{
		private var _fps:Number;
		private var _time:Number = 1;
		private var _frameval:Number;
		private var _scene:Scene3D;
		
		private function get time():Number
		{
			 var now:int = _scene.tickTraverser.now;
			 
			 if(now != _time)
				_frameval = (now - _time) * fps / 1000;
				_time = now;
			
			return _frameval;
		}
		/**
		 * Creates a new <code>TimeBase</code> object.
		 *
		 * @param	scene				The scene 
		 * @param	fpsrate				The frame per second rate
		 * 
		 */
		public function TimeBase( scene:Scene3D, fpsrate:Number)
		{
			fps = fpsrate;
			_scene = scene;
			scene.updateTime();
		}
		
		/**
    	 * Set the fps rate set for this class.
    	 */
		public function set fps(value:Number):void
		{
			_fps = (value > 0)? value : _fps;
		}
		
		/**
 		 * Returns  the fps rate set for this class.
 		 * 
 		 * @return	The fps rate set for this class.
 		 */
		public function get fps():Number
		{
			return _fps;
		}
		/**
 		 * Returns the value passed at a the actual fps rate set for this class.
 		 * 
		 * @param	value		The number to be interpreted at the fps rate set for this class
		 * 
 		 * @return	A Number, the value passed at a the actual fps rate set for this class
 		 */
		public function timeVal(value:Number):Number
		{
			return value * ((value/fps)*time);
		}
		
	}
}
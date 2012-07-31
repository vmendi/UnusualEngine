﻿package away3d.core.base
{
	import away3d.core.base.Geometry;
	import away3d.core.base.Vertex;
	/**
	 * Holds information about the current state of animation to transition into another animation.
	 */
    public class AnimationTransition
    {
        private var _steps:Number = .1;
		private var _transitionvalue:Number = 10;
		private var _geom:Geometry;
		private var _interpolate:Number;
		private var _refFrame:Array;
     
        public function AnimationTransition(geo:Geometry)
        {
			_interpolate = 1;
			_geom = geo;
			 
			setRef();
        }
		 
        private function setRef():void
        {
			_refFrame = [];
			var _length:int = _geom.vertices.length;
			for(var i:int = 0; i<_length;++i)
				_refFrame.push(new Vertex(_geom.vertices[i].x, _geom.vertices[i].y, _geom.vertices[i].z));

        }
		
		private function updateRef():void
        {
			var _length:int = _refFrame.length;
			for(var i:int = 0; i<_length; ++i){
				_refFrame[i].x = _geom.vertices[i].x;
				_refFrame[i].y = _geom.vertices[i].y;
				_refFrame[i].z = _geom.vertices[i].z;
			}
        }
		 
		public function update():void
		{
			if(_interpolate < 1){
				var inv:Number = 1-_interpolate;
				var _length:int = _refFrame.length;
				for(var i:int = 0; i<_length;++i){
					_geom.vertices[i].x = (_refFrame[i].x * inv) + (_geom.vertices[i].x *_interpolate);
					_geom.vertices[i].y = (_refFrame[i].y * inv) + (_geom.vertices[i].y *_interpolate);
					_geom.vertices[i].z = (_refFrame[i].z * inv) + (_geom.vertices[i].z *_interpolate);
				}
				_interpolate += _steps;
			}
		}
		
		public function reset():void
		{
			updateRef();
			_interpolate = _steps;
		}
		
		public function get interpolate():Number
		{
			return _interpolate;
		}
		
		public function set transitionValue(val:Number):void
		{
			_transitionvalue =  (val<1)? 1 : val;
			_steps = 1/val;
		}
		public function get transitionValue():Number
		{
			 return _transitionvalue;
		}
		 
    }
}
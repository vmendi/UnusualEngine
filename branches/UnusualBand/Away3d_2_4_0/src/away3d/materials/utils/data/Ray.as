﻿package away3d.materials.utils.data
{
	import away3d.core.math.Number3D;
	
	public class Ray{
		
		private var _orig:Number3D = new Number3D();
		private var _dir:Number3D = new Number3D();
		private var _intersect:Number3D = new Number3D();
		private var _tu:Number3D = new Number3D();
		private var _tv:Number3D = new Number3D();
		private var _w:Number3D = new Number3D();
		//private var _refresh:Boolean;
		
		//plane
		private var _pn:Number3D = new Number3D();
		private var _npn:Number3D = new Number3D();
		//private var _eps:Number = 1/10000;
		
		function Ray(){
		}
		/**
		* Defines the origin point of the Ray object
		* 
		* @return	Number3D		The origin point of the Ray object
		*/
		public function set orig(o:Number3D):void
		{
			_orig.x = o.x;
			_orig.y = o.y;
			_orig.z = o.z;
		}
		
		public function get orig():Number3D
		{
			return _orig;
		}
		
		/**
		* Defines the directional vector of the Ray object
		* 
		* @return	Number3D		The directional vector
		*/
		public function set dir(n:Number3D):void
		{
			_dir.x = n.x;
			_dir.y = n.y;
			_dir.z = n.z;
		}
		
		public function get dir():Number3D
		{
			return _dir;
		}
		
		/**
		* Defines the directional normal of the Ray object
		* 
		* @return	Number3D		The normal of the plane
		*/
		public function get planeNormal():Number3D
		{
			return _pn;
		}
		
		/**
		* Checks ray intersection by mesh.boundingRadius
		* 
		* @return	Boolean		If the ray intersect the mesh boundery
		*/
    	public function intersectBoundingRadius(pos:Number3D, radius:Number):Boolean
		{
			var rsx:Number = _orig.x - pos.x;
			var rsy:Number = _orig.y - pos.y;
			var rsz:Number = _orig.z - pos.z;
			var B:Number = rsx*_dir.x + rsy*_dir.y + rsz*_dir.z;
			var C:Number = rsx*rsx + rsy*rsy + rsz*rsz - (radius*radius);
			
			return (B * B - C) > 0;
		}
		
		public function getIntersect(p0:Number3D, p1:Number3D, v0:Number3D, v1:Number3D, v2:Number3D):Number3D
		{

			_tu.sub(v1, v0);
			_tv.sub(v2, v0);
			
			_pn.x =  _tu.y*_tv.z - _tu.z*_tv.y;
			_pn.y =  _tu.z*_tv.x - _tu.x*_tv.z;
			_pn.z =  _tu.x*_tv.y - _tu.y*_tv.x;
			 
			if (_pn.modulo ==0)
				return null;
			
			_dir.sub(p1, p0);
			_orig.sub(p0, v0);
			 
			_npn.x = -_pn.x;
			_npn.y = -_pn.y;
			_npn.z = -_pn.z;
			
			var a:Number = _npn.dot( _orig);
			
			if (a ==0)
				return null;
				
			var b:Number = _pn.dot( _dir);
			var r:Number = a / b;
			
			//no hit
			if (r < 0 || r > 1)
				return null;
			
			//the ray intersects the plane at.
			_intersect.x = p0.x+(_dir.x*r);
			_intersect.y = p0.y+(_dir.y*r);
			_intersect.z = p0.z+(_dir.z*r);
 
			var uu:Number = _tu.dot(_tu);
			var uv:Number = _tu.dot(_tv);
			var vv:Number = _tv.dot(_tv);
			_w.sub(_intersect, v0);
			var wu:Number = _w.dot(_tu);
			var wv:Number = _w.dot(_tv);
			var d:Number = uv * uv - uu * vv;

			var v:Number = (uv * wv - vv * wu) / d;
			if (v < 0 || v > 1)
				return null;
			 
			var t:Number = (uv * wu - uu * wv) / d;
			if (t < 0 || (v + t) > 1.0)
				return null;
			
			return _intersect;
		}
		 
		
		
	}
}
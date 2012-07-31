﻿package away3d.animators
{
	import away3d.core.base.Mesh;
	import away3d.core.base.Object3D;
	import away3d.core.base.Face;
	import away3d.core.math.Number3D;
	import away3d.core.math.Matrix3D;
	
	public class FaceLink
	{
		private var _face:Face;
		private var _offsetn:Number;
		private var _obj:Object3D;
		private var _source:Mesh;
		private var _n:Number3D = new Number3D();
		private var _pos:Number3D = new Number3D();
		private var _base:Number3D = new Number3D();
		private var _target:Number3D;
		private var _align:Boolean;
		private var _rad:Number = Math.PI / 180;
		
		private function average():void
		{
			_pos.x = (_face.v0.x + _face.v1.x + _face.v2.x) / 3;
			_pos.y = (_face.v0.y + _face.v1.y + _face.v2.y) / 3;
			_pos.z = (_face.v0.z + _face.v1.z + _face.v2.z) / 3;
		}
		 
		/**
		 * Creates a new <code>FaceLink</code> object.
		 * This class allows to link two objects together by a face object of one of the two, like a man and a his gun etc...
		 * ideal for animated meshes or simple systems.
		 * 
		 * @param	obj				The Object3D to be linked to the face during animations.
		 * @param	meshsource	The Mesh witch hold the Face object reference.
		 * @param face				The Face object reference to be used as anchor.
		 * @param offset			[optional] The distance of the objectposition along the face normal. Default = 0;
		 * @param align				[optional] If the mesh must be aligned to the normal vector. Default = false;
		 * @param target			[optional] If the mesh points at a given Number3D.  Default = null;
		 */
		 
		public function FaceLink(obj:Object3D, meshsource:Mesh, face:Face, offset:Number = 0, align:Boolean= false, target:Number3D = null)
		{
			_obj = obj;
			_source = meshsource;
			_face = face;
			_offsetn = offset;
			_target = target;
			_align = align;
			average();
		}
		
		public function update( updateNormal:Boolean = false):void
		{
			
			if(updateNormal){
				_face.normalDirty = true;
			 	average();
			}
			
			var m:Matrix3D = _source.sceneTransform;
			_n.rotate(_face.normal, m);
			
			var rotx:Number = _source.rotationX * _rad;
			var roty:Number = _source.rotationY * _rad;
			var rotz:Number = _source.rotationZ * _rad;
			var sinx:Number = Math.sin(rotx);
			var cosx:Number = Math.cos(rotx);
			var siny:Number = Math.sin(roty);
			var cosy:Number = Math.cos(roty);
			var sinz:Number = Math.sin(rotz);
			var cosz:Number = Math.cos(rotz);
 
			var x:Number = _pos.x;
			var y:Number = _pos.y;
			var z:Number = _pos.z;

			var y1:Number = y;
			y = y1*cosx+z*-sinx;
			z = y1*sinx+z*cosx;
			
			var x1:Number = x;
			x = x1*cosy+z*siny;
			z = x1*-siny+z*cosy;
		
			x1 = x;
			x = x1*cosz+y*-sinz;
			y = x1*sinz+y*cosz;
 
			_obj.x = x - (_offsetn* _n.x);
			_obj.y = y - (_offsetn* _n.y);
			_obj.z = z - (_offsetn* _n.z);
			
			if(_align || _target != null)
				_obj.rotationX = 0;
				_obj.rotationY = 0;
				_obj.rotationZ = 0;
				
			if(_align)
				 _base.x = x;
				 _base.y = y;
				 _base.z = z;
				_obj.lookAt(_base);
			 
			if(_target != null)
				_obj.lookAt(_target);
				
			_obj.x += _source.scenePosition.x;
			_obj.y += _source.scenePosition.y;
			_obj.z += _source.scenePosition.z;
		}
		
		/**
		 * The offset value along the normal vector of the face
		 */
		public function get offset():Number
		{
			return _offsetn;
		}
		
		public function set offset(val:Number):void
		{
			_offsetn = val;
		}
		
		/**
		 * Defines if the object is aligned along the normal
		 */
		public function get align():Boolean
		{
			return _align;
		}
		
		public function set align(b:Boolean):void
		{
			_align = b;
			
			if(_align)
				_target = null;
		}
		
		/**
		 * The object will lookAt a given Number3D while remaining on it's position: the center of the face with the optional offset.
		 */
		public function get target():Number3D
		{
			return _target;
		}
		
		public function set target(n:Number3D):void
		{
			_target = n;
			_align = (n == null);
		}
		
		/**
		 *Defines another face to be used as anchor
		 */
		public function get face():Face
		{
			return _face;
		}
		
		public function set face(f:Face):void
		{
			_face = f;
			average();
		}
		
		/**
		 *Defines another object3D to be attached to the face.
		 */
		public function get object():Object3D
		{
			return _obj;
		}
		
		public function set object(obj:Object3D):void
		{
			_obj = obj;
		}
		
		/**
		 *Defines another face to be used as anchor by its index
		 */
		public function set faceindex(i:int):void
		{
			_face = _source.faces[i];
			average();
		}
		 
	}
}

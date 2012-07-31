﻿package away3d.geom{
	
	import away3d.core.base.Mesh;
	import away3d.core.base.Vertex;
	import away3d.core.base.Face;
	import away3d.core.base.UV;
	import away3d.core.base.Object3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.arcane;
	
	use namespace arcane;
	  
	
	/**
	 * Class Weld removes from the faces found of one or more object3d all the duplicated vertexes and uv's<Weld></code>
	 */
	public class Weld{
		private var _av:Array;
		private var _auv:Array;
		private var _bUv:Boolean;
		private var _delv:int;
		private var _delu:int;
		 
		private function parse(object3d:Object3D):void
		{
			 
			if(object3d is ObjectContainer3D){
			
				var obj:ObjectContainer3D = (object3d as ObjectContainer3D);
			
				for(var i:int =0;i<obj.children.length;++i){
					
					if(obj.children[i] is ObjectContainer3D){
						parse(obj.children[i]);
					} else if(obj.children[i] is Mesh){
						weld( obj.children[i]);
					}
				}
				
			}else if(object3d is Mesh){
				weld( object3d as Mesh);
			}
			 
		}
		
		private function createVertex(v:Vertex):Boolean
		{
			for(var i:int=0;i<_av.length;++i){
					if(v.x == _av[i].x && v.y == _av[i].y && v.z == _av[i].z ){
						_delv ++;
						return false;
					}
			}
			_av.push(v);
			return true;
		}
		
		private function createUV(face:Face, index:int):void
		{
			var uv:UV = face["uv"+index];
			for(var i:int=0;i<_auv.length;++i){
					if(uv.u == _auv[i].u && uv.v == _auv[i].v){
						face["uv"+index] = null;
						face["uv"+index] = _auv[i];
						_delu ++;
						return;
					}
			}
			_auv.push(uv);
		}
		
		private function weld(obj:Mesh):void
		{
				var face:Face;
				var v:Vertex;
				var i:int = 0;
				var y:int = 0;
				var loop:int = obj.faces.length;
 
				for(i=0;i<obj.vertices.length;++i){
					
					if(createVertex(obj.vertices[i])){
						v = _av[_av.length-1];
						for(y=0;y<loop;++y){
							face = obj.faces[y];
							
							if(face.v0.x == v.x && face.v0.y == v.y && face.v0.z == v.z )
								face.v0 = v;
							 
							if(face.v1.x == v.x && face.v1.y == v.y && face.v1.z == v.z )
								face.v1 = v;
							
							if(face.v2.x == v.x && face.v2.y == v.y && face.v2.z == v.z )
								face.v2 = v;

						}
					}
				}
				
				//obj.vertices = [];
				//obj.vertices = _av;
				 
				if(_bUv){
					 
					for(y=0;y<loop;++y){
						
						face = obj.faces[y];
						createUV(face, 0);
						createUV(face, 1);
						createUV(face, 2);
					}
					
					_auv = null;
				}
				
		}
		 
		/**
		*  Class Weld removes from the faces found of an object3d all the duplicated vertexes and uv's.
		* @param	 doUVs			[optional] Boolean. If uv's needs to be optimized as well. Default is true.
		*/
		 
		function Weld(doUVs:Boolean = true):void
		{
			_bUv = doUVs;
		}
		/**
		*  Apply the welding code to a given object3D.
		* @param	 object3d		Object3D. The target Object3d object.
		*/
		public function apply(object3d:Object3D):void
		{
			_delv = _delu = 0;
			_av = [];
			
			if(_bUv)
				_auv = [];
				
			parse(object3d);
			
			_av = null;
			
			if(_bUv)
				_auv = null;
		}
		
		/**
		* Defines if the weld operation treats the UV's.
		*/
		public function set doUVs(b:Boolean):void
		{
			_bUv = b;
		}
		
		public function get doUVs():Boolean
		{
			return _bUv;
		}
		
		/**
		* returns howmany vertexes were deleted during the welding operation.
		*/
		public function get countvertices():int
		{
			return _delv;
		}
		
		/**
		* returns howmany uvs were deleted during the welding operation.
		*/
		public function get countuvs():int
		{
			return _delu;
		}
		
		
	}
}
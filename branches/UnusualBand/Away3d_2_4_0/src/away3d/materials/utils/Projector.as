﻿package away3d.materials.utils
{
	import away3d.core.base.Vertex;
	import away3d.core.base.UV;
	import away3d.core.base.Mesh;
	import away3d.core.base.Object3D;
	import away3d.core.base.Face;
	import away3d.containers.ObjectContainer3D;

	/**
	* Class remaps the uvs of an Object3D for a given orientation:
	* orientation = "front", "back", "top", "bottom", "left" and "right"
	*/
	
	public class Projector
	{
		private static var _width:Number;
		private static var _height:Number;
		private static var _offsetW:Number;
		private static var _offsetH:Number;
		private static var _orientation:String;
		
		
		/**
		*  Applies the mapping to the Object3D object according to string orientation
		* @param	 orientation	String. Defines the way the map will be projected onto the Object3D. orientation value  can be: "front", "back", "top", "bottom", "left" and "right"
		* @param	 object3d		Object3d. The Object3D to remap.
		*/
		public static function project(orientation:String, object3d:Object3D):void
		{
			_orientation = orientation.toLowerCase();
			 
			if(_orientation == "front" || _orientation == "back"){
				_width = object3d.maxX - object3d.minX;
				_height = object3d.maxY - object3d.minY;
				_offsetW = (object3d.minX>0)? -object3d.minX : Math.abs(object3d.minX);
				_offsetH= (object3d.minY>0)? -object3d.minY : Math.abs(object3d.minY);	
			}
			
			if(_orientation == "left" || _orientation == "right"){
				_width = object3d.maxZ - object3d.minZ;
				_height = object3d.maxY - object3d.minY;
				_offsetW = (object3d.minZ>0)? -object3d.minZ : Math.abs(object3d.minZ);
				_offsetH= (object3d.minY>0)? -object3d.minY : Math.abs(object3d.minY);
			}
			
			if(_orientation == "top" || _orientation == "bottom"){
				_width = object3d.maxX - object3d.minX;
				_height = object3d.maxZ - object3d.minZ;
				_offsetW = (object3d.minX>0)? -object3d.minX : Math.abs(object3d.minX);
				_offsetH= (object3d.minZ>0)? -object3d.minZ : Math.abs(object3d.minZ);
			}
			
			parse(object3d);
		}
		
		private static function parse(object3d:Object3D):void
		{
			 
			if(object3d is ObjectContainer3D){
			
				var obj:ObjectContainer3D = (object3d as ObjectContainer3D);
			
				for(var i:int =0;i<obj.children.length;++i){
					
					if(obj.children[i] is ObjectContainer3D){
						parse(obj.children[i]);
					} else if(obj.children[i] is Mesh){
						remapMesh( obj.children[i]);
					}
				}
				
			} else if (object3d is Mesh){
				remapMesh( object3d as Mesh);
			}
			 
		}
		
		private static function remapMesh(mesh:Mesh):void
		{
			var i:int;
			var f:Face;
			
			for(i = 0;i<mesh.faces.length;++i){
				f = mesh.faces[i];
				
				switch(_orientation){
					case "front":
						f.uv0.u = (f.v0.x+_offsetW+mesh.scenePosition.x)/_width;
						f.uv0.v = 1- (f.v0.y+_offsetH+mesh.scenePosition.y)/_height;
						f.uv1.u = (f.v1.x+_offsetW+mesh.scenePosition.x)/_width;
						f.uv1.v = 1-(f.v1.y+_offsetH+mesh.scenePosition.y)/_height;
						f.uv2.u = (f.v2.x+_offsetW+mesh.scenePosition.x)/_width;
						f.uv2.v = 1-(f.v2.y+_offsetH+mesh.scenePosition.y)/_height;
						break;
						
					case "back":
						f.uv0.u = 1-(f.v0.x+_offsetW+mesh.scenePosition.x)/_width;
						f.uv0.v = 1- (f.v0.y+_offsetH+mesh.scenePosition.y)/_height;
						f.uv1.u = 1-(f.v1.x+_offsetW+mesh.scenePosition.x)/_width;
						f.uv1.v = 1-(f.v1.y+_offsetH+mesh.scenePosition.y)/_height;
						f.uv2.u = 1-(f.v2.x+_offsetW+mesh.scenePosition.x)/_width;
						f.uv2.v = 1-(f.v2.y+_offsetH+mesh.scenePosition.y)/_height;
						break;
					
					case "right":
						f.uv0.u = (f.v0.z+_offsetW+mesh.scenePosition.z)/_width;
						f.uv0.v = 1- (f.v0.y+_offsetH+mesh.scenePosition.y)/_height;
						f.uv1.u = (f.v1.z+_offsetW+mesh.scenePosition.z)/_width;
						f.uv1.v = 1-(f.v1.y+_offsetH+mesh.scenePosition.y)/_height;
						f.uv2.u = (f.v2.z+_offsetW+mesh.scenePosition.z)/_width;
						f.uv2.v = 1-(f.v2.y+_offsetH+mesh.scenePosition.y)/_height;
						break;
						
					case "left":
						f.uv0.u = 1-(f.v0.z+_offsetW+mesh.scenePosition.z)/_width;
						f.uv0.v = 1- (f.v0.y+_offsetH+mesh.scenePosition.y)/_height;
						f.uv1.u = 1-(f.v1.z+_offsetW+mesh.scenePosition.z)/_width;
						f.uv1.v = 1-(f.v1.y+_offsetH+mesh.scenePosition.y)/_height;
						f.uv2.u = 1-(f.v2.z+_offsetW+mesh.scenePosition.z)/_width;
						f.uv2.v = 1-(f.v2.y+_offsetH+mesh.scenePosition.y)/_height;
						break;
						
					case "top":
						f.uv0.u = (f.v0.x+_offsetW+mesh.scenePosition.x)/_width;
						f.uv0.v = 1- (f.v0.z+_offsetH+mesh.scenePosition.z)/_height;
						f.uv1.u = (f.v1.x+_offsetW+mesh.scenePosition.x)/_width;
						f.uv1.v = 1-(f.v1.z+_offsetH+mesh.scenePosition.z)/_height;
						f.uv2.u = (f.v2.x+_offsetW+mesh.scenePosition.x)/_width;
						f.uv2.v = 1-(f.v2.z+_offsetH+mesh.scenePosition.z)/_height;
						break;
						
					case "bottom":
						f.uv0.u = 1- (f.v0.x+_offsetW+mesh.scenePosition.x)/_width;
						f.uv0.v = 1- (f.v0.z+_offsetH+mesh.scenePosition.z)/_height;
						f.uv1.u = 1- (f.v1.x+_offsetW+mesh.scenePosition.x)/_width;
						f.uv1.v = 1-(f.v1.z+_offsetH+mesh.scenePosition.z)/_height;
						f.uv2.u = 1- (f.v2.x+_offsetW+mesh.scenePosition.x)/_width;
						f.uv2.v = 1-(f.v2.z+_offsetH+mesh.scenePosition.z)/_height;
						break;
					
				}
				
			}
			
		}
		
		
	}
}
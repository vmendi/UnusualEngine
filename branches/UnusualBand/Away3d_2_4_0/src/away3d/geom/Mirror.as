﻿package away3d.geom{
	
	import away3d.core.math.Number3D;
	import away3d.core.base.*;
	import away3d.containers.ObjectContainer3D;
	import away3d.materials.ITriangleMaterial;
	
	/**
	 * Class Mirror an Object3D geometry and its uv's <Mirror></code>
	 * 
	 */
	public class Mirror{
		
		private static var Axes:Array = ["x-", "x+", "x", "y-", "y+", "y", "z-", "z+", "z"];
		 
		private static function validate( axe:String):Boolean
		{
			for(var i:int =0;i<Mirror.Axes.length;++i)
				if(axe == Mirror.Axes[i]) return true;
				
			return false;
		}
		
		private static function checkInvalid( v:Vertex):Vertex
		{
			v = (v == null)? new Vertex(0,0,0) : v;
			
			v.x = (isNaN(v.x))? 0 : v.x;
			v.y = (isNaN(v.y))? 0 : v.y;
			v.z = (isNaN(v.z))? 0 : v.z;
							
			return v;
		}

		private static function build(object3d:Object3D, axe:String, recenter:Boolean, duplicate:Boolean = true):void
		{
				var obj:Mesh = (object3d as Mesh);
				var aFaces:Array = obj.faces;
				var face:Face;
				var i:int;
				var uva: UV;
				var uvb: UV;
				var uvc: UV;
				var va: Vertex;
				var vb: Vertex;
				var vc :Vertex;
				var mat:ITriangleMaterial;
				var uv0: UV;
				var uv1: UV;
				var uv2: UV;
				var v0: Vertex;
				var v1: Vertex;
				var v2 :Vertex;
				var posi:Number3D = object3d.position;
				var facecount:int = aFaces.length;
				var offset:Number;
				var flip:Boolean = true;
				switch(axe){
					
						case "x":
							offset = posi.x;
						break;
						case "x-":
							offset = Math.abs(object3d.minX)+object3d.maxX;
						break;
						case "x+":
							offset = Math.abs(object3d.minX)+object3d.maxX;
						break;
						
						case "y":
							offset = posi.y;
						break;
						case "y-":
							offset = Math.abs(object3d.minY)+object3d.maxY;
						break;
						case "y+":
							offset = Math.abs(object3d.minY)+object3d.maxY;
						break;
						
						case "z":
							offset = posi.z;
						break;
						case "z-":
							flip = false;
							offset = Math.abs(object3d.minZ)+object3d.maxZ;
						break;
						case "z+":
							flip = false;
							offset = Math.abs(object3d.minZ)+object3d.maxZ;
							
				}
				
				if(isNaN(offset)){
					trace("--> invalid object bounderies");
					return;
				}
				
				for(i=0;i<facecount;++i){
					face = aFaces[i];
					mat= face.material;
					
					va = checkInvalid(face.v0);
					vb = checkInvalid(face.v1);
					vc = checkInvalid(face.v2);
					
					if(!duplicate){
						uva = face.uv0;
						uvb = face.uv1;
						uvc = face.uv2;
						
						uv0 = new UV(uva.u, uva.v);
						uv1 = new UV(uvb.u, uvb.v);
						uv2 = new UV(uvc.u, uvc.v);
						
						face.v0 = face.v1 = face.v2 = null;
						face.uv0 = face.uv1 = face.uv2 = null;
					}
					 
					switch(axe){
						case "x":
							v0 = new Vertex( -va.x -(offset*2), va.y, va.z);
							v1 = new Vertex( -vb.x -(offset*2), vb.y, vb.z);
							v2 = new Vertex( -vc.x -(offset*2), vc.y, vc.z);
						break;
						
						case "x-":
							v0 = new Vertex(-va.x - offset, va.y, va.z);
							v1 = new Vertex(-vb.x - offset, vb.y, vb.z);
							v2 = new Vertex(-vc.x - offset, vc.y, vc.z);
							 
						break;
						
						case "x+":
							v0 = new Vertex(-va.x + offset, va.y, va.z);
							v1 = new Vertex(-vb.x + offset, vb.y, vb.z);
							v2 = new Vertex(-vc.x + offset, vc.y, vc.z);
						break;
						//
						case "y":
							v0 = new Vertex(va.x , -va.y -(offset*2), va.z);
							v1 = new Vertex(vb.x , -vb.y -(offset*2), vb.z);
							v2 = new Vertex(vc.x , -vc.y -(offset*2), vc.z);
						break;
						
						case "y-":
							v0 = new Vertex(va.x , -va.y - offset, va.z);
							v1 = new Vertex(vb.x, -vb.y - offset, vb.z);
							v2 = new Vertex(vc.x, -vc.y - offset, vc.z);
							 
						break;
						
						case "y+":
							v0 = new Vertex(va.x, -va.y+ offset, va.z);
							v1 = new Vertex(vb.x, -vb.y+ offset, vb.z);
							v2 = new Vertex(vc.x, -vc.y+ offset, vc.z);
						break;
						//
						case "z":
							v0 = new Vertex(va.x , va.y, -va.z -(offset*2));
							v1 = new Vertex(vb.x , vb.y, -vb.z -(offset*2));
							v2 = new Vertex(vc.x , vc.y, -vc.z -(offset*2));
						break;
						
						case "z-":
							v0 = new Vertex(va.x, va.y, va.z - offset);
							v1 = new Vertex(vb.x, vb.y, vb.z - offset);
							v2 = new Vertex(vc.x, vc.y, vc.z - offset);
							 
						break;
						
						case "z+":
							v0 = new Vertex(va.x, va.y, va.z+ offset);
							v1 = new Vertex(vb.x, vb.y, vb.z+ offset);
							v2 = new Vertex(vc.x, vc.y, vc.z + offset);

					}
					 
					if(flip){
						
						if(duplicate){
							obj.addFace(new Face(v1, v0, v2, mat, face.uv1, face.uv0, face.uv2 ) );
						}else{
							face.v0 = v1;
							face.v1 = v0;
							face.v2 = v2;
							face.uv0 = uv1;
					 		face.uv1 = uv0;
							face.uv2 = uv2;
						}
						
					} else {
						
						if(duplicate){
							obj.addFace(new Face(v0, v1, v2, mat, face.uv0, face.uv1, face.uv2 ) );
						}else{
							face.v0 = v0;
							face.v1 = v1;
							face.v2 = v2;
							face.uv0 = uv0;
					 		face.uv1 = uv1;
							face.uv2 = uv2;
						}
					}
					 
				}
				
				if(recenter)
					obj.applyPosition((obj.minX+obj.maxX)*.5, (obj.minY+obj.maxY)*.5, (obj.minZ+obj.maxZ)*.5);
				
		}
		 
		 /**
		 * Mirrors an Object3D Mesh object geometry and uv's
		 * 
		 * @param	 object3d		The Object3D, ObjectContainer3D are parsed recurvely as well.
		 * @param	 axe		A string "x-", "x+", "x", "y-", "y+", "y", "z-", "z+", "z". "x", "y","z" mirrors on world position 0,0,0, the + mirrors geometry in positive direction, the - mirrors geometry in positive direction.
		 * @param	 recenter	[optional]	Recenter the Object3D pivot. This doesn't affect ObjectContainers3D's. Default is true.
		 * @param	 duplicate	[optional]	Duplicate model geometry along the axe or set to false mirror but do not duplicate. Default is true.
		 * 
		 */
		public static function apply(object3d:Object3D, axe:String, recenter:Boolean = true, duplicate:Boolean = true):void
		{
			axe = axe.toLowerCase();
			
			if(Mirror.validate(axe)){
				
				if(object3d is ObjectContainer3D){
					
					var obj:ObjectContainer3D = (object3d as ObjectContainer3D);
					
					for(var i:int =0;i<obj.children.length;++i){
						 
						if(obj.children[i] is ObjectContainer3D){
							Mirror.apply(obj.children[i], axe, recenter, duplicate);
						} else{
							Mirror.build( obj.children[i], axe, recenter, duplicate);
						}
					}
					
				}else{
					Mirror.build( object3d, axe, recenter, duplicate);
				}
			 
			} else{
				trace("Mirror error: unvalid axe string:"+Mirror.Axes.toString());
			}
		}
		
	}
}
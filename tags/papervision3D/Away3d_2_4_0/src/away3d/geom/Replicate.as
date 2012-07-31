﻿package away3d.geom{
	
	import away3d.core.base.Mesh;
	import away3d.core.base.Vertex;
	import away3d.core.base.UV;
	import away3d.core.base.Face;
	import away3d.core.math.Number3D;

	/**
	* Class Replicate create a new Mesh object from transformed copies of the original .<Replicate></code>
	*/
	
	public class Replicate{
		
		private var _rotations:Number3D;
		private var _positions:Number3D;
		private var _scales:Number3D;
		private var _copies:int;
		 
		private function replicate(omesh:Mesh):Mesh
		{
			var i:int;
			var j:int;
			var loop:int = omesh.faces.length;
			
			var mesh:Mesh = new Mesh();
			var x:int;
			var y:int;
			var z:int;
			
			var rotx:Number = 0;
			var roty:Number = 0;
			var rotz:Number = 0;
			
			var v0:Vertex;
			var v1:Vertex;
			var v2:Vertex;
			
			var uv0:UV;
			var uv1:UV;
			var uv2:UV;
			
			var face:Face;
			var uvs:Array = [];
			
			for(i = 0;i<loop;++i){
				
				face = omesh.faces[i];
				
				v0 = new Vertex(face.v0.x, face.v0.y, face.v0.z);
				v1 = new Vertex(face.v1.x, face.v1.y, face.v1.z);
				v2 = new Vertex(face.v2.x, face.v2.y, face.v2.z);
				
				uv0 = new UV(face.uv0.u, face.uv0.v);
				uv1 = new UV(face.uv1.u, face.uv1.v);
				uv2 = new UV(face.uv2.u, face.uv2.v);
				
				uvs.push(uv0, uv1, uv2);
				
				mesh.addFace( new Face(v0, v1, v2, null, uv0, uv1, uv2 ) );
			}
			
			if(_scales.x != 1 || _scales.y != 1 || _scales.z != 1){
				var aScales:Array = stepScale(_scales, _copies);
			}
			
			for(i = 1;i<_copies;++i){
				
				x = _positions.x* i;
				y = _positions.y* i;
				z = _positions.z* i;
				
				if(_rotations.x != 0)
					rotx = _rotations.x* i;
				if(_rotations.y != 0)
					roty = _rotations.y* i;
				if(_rotations.z != 0)
					rotz = _rotations.z* i;
				
				for(j = 0;j<loop;++j){
					
					face = omesh.faces[j];
					
					v0 = new Vertex(face.v0.x, face.v0.y, face.v0.z);
					v1 = new Vertex(face.v1.x, face.v1.y, face.v1.z);
					v2 = new Vertex(face.v2.x, face.v2.y, face.v2.z);
					
					if(_scales.x != 1 || _scales.y != 1 || _scales.z != 1){
						scale(v0, aScales[i-1]);
						scale(v1, aScales[i-1]);
						scale(v2, aScales[i-1]);
					}
					
					if(_rotations.x != 0 || _rotations.y != 0 || _rotations.z != 0){
						rotate(v0, rotx, roty, rotz);
						rotate(v1, rotx, roty, rotz);
						rotate(v2, rotx, roty, rotz);
					}
					
					add(v0, x, y, z);
					add(v1, x, y, z);
					add(v2, x, y, z);
					
					if(j == 0){
						mesh.addFace(new Face(v0, v1, v2, null, uvs[0], uvs[1], uvs[2]) );
					} else {
						mesh.addFace(new Face(v0, v1, v2, null, uvs[(j*3)], uvs[(j*3)+1], uvs[(j*3)+2]) );
					}
					
				}
				
			}
			
			uvs = null;
			mesh.material = omesh.material;
			
			return mesh;
		}
		
		private function scale(v:Vertex, nscale:Number3D):void
        {
			if(_scales.x != 1)
				v.x *= nscale.x;
				
			if(_scales.y != 1)
				v.y *= nscale.y;
			
			if(_scales.z != 1)
				v.z *= nscale.z;
			
			v.setValue(v.x, v.y, v.z);
        }
		
		private function add(v:Vertex, x:Number, y:Number, z:Number):void
		{
			v.x += x;
        	v.y += y;
        	v.z += z;
			
			v.setValue(v.x, v.y, v.z);
		}
		
		 private function stepScale( dest:Number3D, subdivision:int):Array
		 {
			var ascales:Array = [];
			var sx:Number =  (dest.x-1) / subdivision;
			var sy:Number =  (dest.y-1) / subdivision;
			var sz:Number =  (dest.z-1) / subdivision;
			
			var s:int = 1;
			var scales:Number3D;
			
			while (s < subdivision) { 
				scales = new Number3D();
				scales.x = 1+(sx*s);
				scales.y = 1+(sy*s);
				scales.z = 1+(sz*s);
				ascales.push(scales);
				
				s ++;
			}
			
			ascales.push(dest);
			
			return ascales;
		}
		
		private function rotate(v:Vertex, rotX:Number, rotY:Number, rotZ:Number ):void
		{
			var x:Number;
			var y:Number;
			var z:Number;
			var x1:Number;
			var y1:Number;
			var rad:Number = Math.PI / 180;
			var rotx:Number = rotX * rad;
			var roty:Number = rotY * rad;
			var rotz:Number = rotZ * rad;
			var sinx:Number = Math.sin(rotx);
			var cosx:Number = Math.cos(rotx);
			var siny:Number = Math.sin(roty);
			var cosy:Number = Math.cos(roty);
			var sinz:Number = Math.sin(rotz);
			var cosz:Number = Math.cos(rotz);
   
			x = v.x;
			y = v.y;
			z = v.z;

			y1 = y;
			y = y1*cosx+z*-sinx;
			z = y1*sinx+z*cosx;
			
			x1 = x;
			x = x1*cosy+z*siny;
			z = x1*-siny+z*cosy;
		
			x1 = x;
			x = x1*cosz+y*-sinz;
			y = x1*sinz+y*cosz;

			v.setValue(x, y, z);
		}
		 
		/**
		*  Class Replicate create a new Mesh object from transformed copies of the original .<Replicate></code>
		*
		* @param	 copies		[optional] int. Defines how repeats of the original mesh will be done.
		* @param	 positions	[optional] Number3D. Defines the offset x,y and z for the position increase. Default is 0,0,0.
		* @param	 rotations	[optional] Number3D. Defines the offset x,y and z for the position increase. Default is 0,0,0.
		* @param	 scales	[optional] Number3D. Defines the offset x,y and z for the position increase. Default is 1,1,1.
		*/
		
		function Replicate( copies:int, positions:Number3D = null, rotations:Number3D = null, scales:Number3D = null ):void
		{
			_copies = copies;
			_positions = (positions == null)? new Number3D(0,0,0) :  positions;
			_rotations = (rotations == null)? new Number3D(0,0,0) :  rotations;
			_scales = (scales == null)? new Number3D(1,1,1) :  scales;
		}
		
		/**
		*  Apply the replicate code to the mesh
		* 
		* @param	 mesh	Mesh. The mesh that will be replicated according to properties such as positions, rotations, scales and copies.
		* @return Mesh
		*/
		public function apply(mesh:Mesh):Mesh
		{
			//setRotations();
			return replicate(mesh);
		}
		
		/**
		* Defines howmany copies of the priginal mesh will be done.
		*/
		public function set copies(i:int):void
		{
			_copies = (i > 0)? i : 1;
		}
		
		public function get copies():int
		{
			return _copies;
		}
		
		/**
		* Defines the offset x, y and z applied during the replicate process
		*/
		public function set positions(n:Number3D):void
		{
			_positions = n;
		}
		
		public function get positions():Number3D
		{
			return _positions;
		}
		
		/**
		* Defines the rotations x, y and z applied during the replicate process
		*/
		public function set rotations(n:Number3D):void
		{
			_rotations = n;
		}
		
		public function get rotations():Number3D
		{
			return _rotations;
		}
		
		/**
		* Defines the scales x, y and z applied during the replicate process
		*/
		public function set scales(n:Number3D):void
		{
			_scales = n;
		}
		
		public function get scales():Number3D
		{
			return _scales;
		}
		
		
	}
}
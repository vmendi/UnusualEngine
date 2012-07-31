﻿package away3d.extrusions
{
   	import flash.display.BitmapData;
	import flash.geom.Point;
	import away3d.core.math.Number3D;
	import away3d.core.base.*;
	import away3d.arcane;
	
	use namespace arcane;
	  
	public class NormalUVModifier {
		
		private var _mesh:Mesh;
		private var _geom:Array;
		private var _sourceBmd:BitmapData;
		private var _maxLevel:Number = 255;
		
		private function updateVertex(orivertex:Vertex, vertex:Vertex, pt:Point, normal:Number3D, channel:String, factor:Number):void
		{
				var color:uint = ( channel == "a")? _sourceBmd.getPixel32(pt.x, pt.y) : _sourceBmd.getPixel(pt.x, pt.y);
				var cha:Number;
				 
				switch(channel){
					case "a":
						cha = color >> 24 & 0xFF;
						break;
					case "r":
						cha = color >> 16 & 0xFF;
						break;
					case "g":
						cha = color >> 8 & 0xFF;
						break;
					case "b":
						cha = color & 0xFF;
						break;
					case "av":
						cha = ((color >> 16 & 0xFF)*0.212671) + ((color >> 8 & 0xFF)*0.715160) + ((color >> 8 & 0xFF)*0.072169);
				}
				
				if(cha <= _maxLevel){
					var multi:Number = (cha*factor);
					vertex.x = orivertex.x+(normal.x * multi);
					vertex.y = orivertex.y+(normal.y * multi);
					vertex.z = orivertex.z+(normal.z * multi);
				}
		}

		private function setVertices():void
		{
			var basevertices:Array = [];
			_geom = [];
			
			var j:int;
			
			for(var i:int = 0;i<_mesh.vertices.length;++i){
				basevertices[i] = _mesh.vertices[i];
			}
			
			var n0:Number3D;
			var n1:Number3D;
			var n2:Number3D;
			
			var v0:Vertex;
			var v1:Vertex;
			var v2:Vertex;
			
			var p0:Point;
			var p1:Point;
			var p2:Point;
			
			var m0:Boolean;
			var m1:Boolean;
			var m2:Boolean;
			
			if(_sourceBmd != null){
				var w:int = _sourceBmd.width-1;
				var h:int = _sourceBmd.height-1;
			}
			
			var face:Face;
			
			for(i = 0;i<_mesh.faces.length;++i){
				m0 = false;
				m1 = false;
				m2 = false;
				face = _mesh.faces[i];
	
				for(j = 0;j<basevertices.length;++j){
					
					if(basevertices[j] == face.v0 ){
						n0 = _mesh.geometry.getVertexNormal(face.v0);
						v0 = face.v0;
						if(_sourceBmd != null){
							p0 = new Point(face.uv0.u * w,  (1 - face.uv0.v) * h);
						} else{
							p0 = new Point(face.uv0.u ,  (1 - face.uv0.v));
						}
						basevertices.splice(j, 1);
						m0 = true;
						j--;
					}
					
					if(basevertices[j] == face.v1 ){
						n1 = _mesh.geometry.getVertexNormal(face.v1);
						v1 = face.v1;
						if(_sourceBmd != null){
							p1 = new Point(face.uv1.u * w,  (1 - face.uv1.v) * h);
						}else{
							p1 = new Point(face.uv1.u,  (1 - face.uv1.v));
						}
						basevertices.splice(j, 1);
						m1 = true;
						j--;
					}
					
					if(basevertices[j] == face.v2 ){
						n2 = _mesh.geometry.getVertexNormal(face.v2);
						v2 = face.v2;
						if(_sourceBmd != null){
							p2 = new Point(face.uv2.u * w,  (1 - face.uv2.v) * h);
						}else{
							p2 = new Point(face.uv2.u ,  (1 - face.uv2.v));
						}
						basevertices.splice(j, 1);
						m2 = true;
						j--;
					}
				}
				
				if(m0 || m1 || m2){
						
						var oV:Object = {};
						oV["n0"] = (m0)? n0 : null;
						oV["n1"] = (m1)? n1 : null;
						oV["n2"] = (m2)? n2 : null;
						
						oV["v0"] = (m0)? v0 : null;
						oV["v1"] = (m1)? v1 : null;
						oV["v2"] = (m2)? v2 : null;
						
						oV["v0o"] = (m0)? new Vertex(v0.x, v0.y, v0.z) : null;
						oV["v1o"] = (m1)? new Vertex(v1.x, v1.y, v1.z) : null;
						oV["v2o"] = (m2)? new Vertex(v2.x, v2.y, v2.z) : null;
						
						oV["p0"] = (m0)? p0 : null;
						oV["p1"] = (m1)? p1 : null;
						oV["p2"] = (m2)? p2 : null;
						
						_geom.push(oV);
				}
				
				if(basevertices.length == 0){
					break;
				}
				
			}
			
		}
		
		private function applyLevel(refreshnormal:Boolean = false):void
		{
			for(var i:int = 0;i<_geom.length;++i){
				if(_geom[i].v0 != null){
					_geom[i].v0o.x = _geom[i].v0.x;
					_geom[i].v0o.y = _geom[i].v0.y;
					_geom[i].v0o.z = _geom[i].v0.z;
				}
				if(_geom[i].v1 != null){
					_geom[i].v1o.x = _geom[i].v1.x;
					_geom[i].v1o.y = _geom[i].v1.y;
					_geom[i].v1o.z = _geom[i].v1.z;
				}
				if(_geom[i].v2 != null){
					_geom[i].v2o.x = _geom[i].v2.x;
					_geom[i].v2o.y = _geom[i].v2.y;
					_geom[i].v2o.z = _geom[i].v2.z;
				}
			}
			
			if(refreshnormal){
				for(i = 0;i<_mesh.faces.length;++i){
					_mesh.faces[i].normalDirty = true;
				}
			}
		}
		
		/**
		* Class NormalUVModifier modifies the vertices of a mesh with a bitmap information along the face normal vector
		* or rescale a model along the model faces normals.<NormalUVModifier></code>
		* 
		* @param	mesh						Object3D. The mesh Object3D to be updated.
		* @param	sourcebmd				[optional] BitmapData. The bitmapdata used as source for the influence.
		*/
		
		public function NormalUVModifier(mesh:Mesh, sourcebmd:BitmapData = null, maxlevel:Number = 255)
        {
			if((mesh as Mesh).vertices != null){
				maxLevel = maxlevel;
				_mesh = mesh as Mesh;
				_sourceBmd = sourcebmd;
				setVertices();
			} else{
				throw new Error("Unvalid Mesh, no vertices array found");
			}
		}
		
		/**
		* Updates the vertexes with the color value found at the uv's coordinates multiplied by a factor along the normal vector.
		*
		* @param	factor				Number. The multiplier. (multiplier * 0/255).
		* @param	channel				[optional] The channel of the source bitmapdata. Possible values, red channel:"r", green channel:"g", blue channel:"b", average:"av". Default is "r".
		*/
		public function update(factor:Number, channel:String = "r"):void
		{
				channel = channel.toLowerCase();
				
				for(var i:int = 0;i<_geom.length;++i){
					
					if(_geom[i].v0 != null){
						updateVertex(_geom[i].v0o, _geom[i].v0, _geom[i].p0, _geom[i].n0, channel, factor);
					}
					
					if(_geom[i].v1 != null){
						updateVertex(_geom[i].v1o, _geom[i].v1, _geom[i].p1, _geom[i].n1, channel, factor);
					}
					
					if(_geom[i].v2 != null){
						updateVertex(_geom[i].v2o, _geom[i].v2, _geom[i].p2, _geom[i].n2, channel, factor);
					}
					
				}
		}
		
		/**
		* Updates the vertexes alog the normal vectors according to a multiplier.
		* The influence is applied on top of the original vertex values.
		* @param	factor			Number. The multiplier.
		*/
		public function multiply(factor:Number):void
		{
			
			for(var i:int = 0;i<_geom.length;++i){
				if(_geom[i].v0 != null){
					_geom[i].v0.x = _geom[i].v0o.x+(_geom[i].n0.x * factor);
					_geom[i].v0.y = _geom[i].v0o.y+(_geom[i].n0.y * factor);
					_geom[i].v0.z = _geom[i].v0o.z+(_geom[i].n0.z * factor);
				}
				if(_geom[i].v1 != null){
					_geom[i].v1.x = _geom[i].v1o.x+( _geom[i].n1.x * factor);
					_geom[i].v1.y = _geom[i].v1o.y+(_geom[i].n1.y * factor);
					_geom[i].v1.z = _geom[i].v1o.z+(_geom[i].n1.z * factor);
				}
				if(_geom[i].v2 != null){
					_geom[i].v2.x = _geom[i].v2o.x+( _geom[i].n2.x * factor);
					_geom[i].v2.y = _geom[i].v2o.y+(_geom[i].n2.y * factor);
					_geom[i].v2.z = _geom[i].v2o.z+(_geom[i].n2.z * factor);
				}
			}
			
		}
		
		/**
		* Resets the vertexes to their original values
		*/
		public function resetVertices():void
		{
			for(var i:int = 0;i<_geom.length;++i){
				if(_geom[i].v0 != null){
					_geom[i].v0.x = _geom[i].v0o.x;
					_geom[i].v0.y = _geom[i].v0o.y;
					_geom[i].v0.z = _geom[i].v0o.z;
				}
				if(_geom[i].v1 != null){
					_geom[i].v1.x = _geom[i].v1o.x;
					_geom[i].v1.y = _geom[i].v1o.y;
					_geom[i].v1.z = _geom[i].v1o.z;
				}
				if(_geom[i].v2 != null){
					_geom[i].v2.x = _geom[i].v2o.x;
					_geom[i].v2.y = _geom[i].v2o.y;
					_geom[i].v2.z = _geom[i].v2o.z;
				}
			}
		}
		
		/**
		* Set a new source bitmapdata for the class
		*/
		public function set source(nSource:BitmapData):void
		{
			var nw:int = nSource.width;
			var nh:int = nSource.height;

			if(_sourceBmd != null){
				var w:int = _sourceBmd.width;
				var h:int = _sourceBmd.height;
			}
			
			_sourceBmd = nSource;
			
			for(var i:int = 0;i<_geom.length;++i){
				if(_geom[i].p0 != null){
					_geom[i].p0.x = (_sourceBmd != null)? (_geom[i].p0.x/w)*nw : _geom[i].p0.x = _geom[i].p0.x * nw;
					_geom[i].p0.y = (_sourceBmd != null)? (_geom[i].p0.y/h)*nh : _geom[i].p0.y = _geom[i].p0.y * nh;
					 
				}
				if(_geom[i].p1 != null){
					_geom[i].p1.x = (_sourceBmd != null)? (_geom[i].p1.x/w)*nw : _geom[i].p1.x = _geom[i].p1.x * nw;
					_geom[i].p1.y = (_sourceBmd != null)? (_geom[i].p1.y/h)*nh : _geom[i].p1.y = _geom[i].p1.y * nh;
					
				}
				if(_geom[i].p2 != null){
					_geom[i].p2.x = (_sourceBmd != null)? (_geom[i].p2.x/w)*nw : _geom[i].p2.x = _geom[i].p2.x * nw;
					_geom[i].p2.y = (_sourceBmd != null)? (_geom[i].p2.y/h)*nh : _geom[i].p2.y = _geom[i].p2.y * nh;
					
				}
			}
		}
		
		/**
    	 * Defines a maximum level of influence. Values required are 0 to 1. If above or equal that level the influence is not applyed.
    	 */
		public function set maxLevel(val:Number):void
		{
			val = (val<0)? 0 : ((val>1)? 1 : val);
			_maxLevel = 255*val;
		}
		public function get maxLevel():Number
		{
			return 1/_maxLevel;
		}
		
		/**
		* Apply the actual displacement and sets it as new base for further displacements.
		* @param	refreshnormal	s			[optional] Recalculates the normals of the Mesh. Default = false;
		*/
		public function apply(refreshnormal:Boolean = false):void
		{
			applyLevel(refreshnormal);
		}
		
		
	}
}
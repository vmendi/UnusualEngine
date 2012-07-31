﻿package away3d.extrusions{
	
	//import away3d.animators.data.CurveSegment;
	import away3d.animators.data.Path;
	import away3d.animators.utils.PathUtils;
	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.core.math.Matrix3D;
	import away3d.core.math.Number3D;
	import away3d.core.utils.Init;
	import away3d.materials.*;
 
	public class PathDuplicator extends Mesh{
		
		use namespace arcane;
		 
		private var xAxis:Number3D = new Number3D();
    	private var yAxis:Number3D = new Number3D();
    	private var zAxis:Number3D = new Number3D();
		private var _worldAxis:Number3D = new Number3D(0,1,0);
		private var _transform:Matrix3D = new Matrix3D();
		private var _path:Path;
		private var _points:Array;
		private var _uvs:Array;
		private var _materials:Array;
		private var _mesh:Object3D;
		private var _meshes:Array = [];
		private var _meshesindex:int = 0;
		private var _scales:Array;
		private var _rotations:Array;
		private var _subdivision:int = 2;
		private var _scaling:Number =  1;
		private var _recenter:Boolean = false;
		private var _closepath:Boolean = false;
		private var _aligntopath:Boolean = true;
		private var _smoothscale:Boolean = true;
		private var _segmentspread:Boolean = false;
		private var _material:ITriangleMaterial;
		 
        private function orientateAt(target:Number3D, position:Number3D):void
        {
            zAxis.sub(target, position);
            zAxis.normalize();
    
            if (zAxis.modulo > 0.1)
            {
                xAxis.cross(zAxis, _worldAxis);
                xAxis.normalize();
    
                yAxis.cross(zAxis, xAxis);
                yAxis.normalize();
    
                _transform.sxx = xAxis.x;
                _transform.syx = xAxis.y;
                _transform.szx = xAxis.z;
    
                _transform.sxy = -yAxis.x;
                _transform.syy = -yAxis.y;
                _transform.szy = -yAxis.z;
    
                _transform.sxz = zAxis.x;
                _transform.syz = zAxis.y;
                _transform.szz = zAxis.z;
				
            }
        }
		
		private function getGeomInfo():void
		{
			_points = [];
			_uvs = [];
			_materials = [];
			var face:Face;

			if(_mesh != null){
				for each(face in (_mesh as Mesh).faces){
					_points.push(face.v0, face.v1, face.v2);
					_uvs.push(face.uv0, face.uv1, face.uv2);
					_materials.push(face.material, null, null);
				}
			} else{
				for each(face in (_meshes[_meshesindex] as Mesh).faces){
					_points.push(face.v0, face.v1, face.v2);
					_uvs.push(face.uv0, face.uv1, face.uv2);
					_materials.push(face.material, null, null);
				}
				_meshesindex  = (_meshesindex+1 < _meshes.length)? _meshesindex+1 : 0;
			}
		}
		
		private function generate(aPointList:Array):void{
			
			var uva:UV;
			var uvb:UV;
			var uvc:UV;
			
			var va:Vertex;
			var vb:Vertex;
			var vc:Vertex;
			
			var m:Mesh = (_mesh == null)? _meshes[_meshesindex] as Mesh : _mesh as Mesh;
			 
			for(var i:int = 0;i<aPointList.length;i+=3){
				uva = new UV( _uvs[i].u , _uvs[i].v);
				uvb = new UV( _uvs[i+1].u , _uvs[i+1].v );
				uvc = new UV( _uvs[i+2].u , _uvs[i+2].v );
				
				va = new Vertex(aPointList[i].x, aPointList[i].y, aPointList[i].z);
				vb = new Vertex(aPointList[i+1].x, aPointList[i+1].y, aPointList[i+1].z);
				vc = new Vertex(aPointList[i+2].x, aPointList[i+2].y, aPointList[i+2].z);
				 
				if(_material == null){
					if(_materials[i] != null){
						addFace(new Face(va,vb,vc, _materials[i], uva, uvb, uvc ));
					} else {
						addFace(new Face(va,vb,vc, m.material as ITriangleMaterial, uva, uvb, uvc ));
					}
				}else{
					addFace(new Face(va,vb,vc, null, uva, uvb, uvc ));
				}
				
			}
		}
		
		/**
		 * Creates a new <PathDuplicator>PathDuplicator</code>
		 * 
		 * @param	 	path			A Path object. The _path definition.
		 * @param	 	mesh			An Object3D Mesh. The Mesh that will be duplicated according to subdivision factor along the path. Note that you can pass a meshes array to the init object or set it if you want to distribute more meshes along the path.
		 * @param 	scales		[optional]	An array containing a series of Number3D [Number3D(1,1,1)]. Defines the scale per segment. Init object smoothscale true smooth the scale across the segments, set to false the scale is applied equally to the whole segment, default is true.
		  * @param 	rotations	[optional]	An array containing a series of Number3D [Number3D(0,0,0)]. Defines the rotation per segment. Default is null. Note that last value entered is reused for the next segment.
		* @param 	init			[optional]	An initialisation object for specifying default instance properties. Default is null. 
		 * 
		 */
		 
		function PathDuplicator(path:Path=null, mesh:Object3D=null, scales:Array=null, rotations:Array=null, init:Object = null)
		{
				_path = path;
				_mesh = mesh;
				_scales = scales;
				_rotations = rotations;
				
				super(init);
				
				_subdivision = ini.getInt("subdivision", 2, {min:2});
				_scaling = ini.getNumber("scaling", 1);
				_recenter = ini.getBoolean("recenter", false);
				_closepath = ini.getBoolean("closepath", false);
				_aligntopath = ini.getBoolean("aligntopath", true);
				_smoothscale = ini.getBoolean("smoothscale", true);
				_segmentspread = ini.getBoolean("segmentspread", false);
				_meshes =  ini.getArray("meshes");
				
				_material = ini.getMaterial("material") as ITriangleMaterial;
				
				if(_path != null && (_mesh!= null || _meshes[0] != null) ) build();
		}
		
		public function build():void
		{
			var m:Mesh = (_mesh == null)? _meshes[0] as Mesh : _mesh as Mesh;
			if(_path.length != 0 && m.faces != null){
				_worldAxis = _path.worldAxis;
				/*if(_closepath){
					
					var ref:CurveSegment = _path.array[_path.array.length-1];
					var vc:Number3D = new Number3D(  (_path.array[0].vc.x+ref.vc.x)*.5,  (_path.array[0].vc.y+ref.vc.y)*.5, (_path.array[0].vc.z+ref.vc.z)*.5   );
					_path.add( new CurveSegment( _path.array[0].v1, vc, _path.array[0].v0 )   );

					if(_path.smoothed){
						
						var tpv1:Number3D = new Number3D((_path.array[0].v0.x+_path.array[_path.length-1].v0.x)*.5, (_path.array[0].v0.y+_path.array[_path.length-1].v0.y)*.5, (_path.array[0].v0.z+_path.array[_path.length-1].v0.z)*.5);
						var tpv2:Number3D = new Number3D((_path.array[0].v0.x+_path.array[0].v1.x)*.5, (_path.array[0].v0.y+_path.array[0].v1.y)*.5, (_path.array[0].v0.z+_path.array[0].v1.z)*.5);
						
						_path.array[_path.length-1].vc.x = tpv1.x;
						_path.array[_path.length-1].vc.y = tpv1.y;
						_path.array[_path.length-1].vc.z = tpv1.z;
						
						_path.array[_path.length-1].v1.x = (_path.array[0].v0.x+_path.array[0].v1.x)*.5;
						_path.array[_path.length-1].v1.y = (_path.array[0].v0.y+_path.array[0].v1.y)*.5;
						_path.array[_path.length-1].v1.z = (_path.array[0].v0.z+_path.array[0].v1.z)*.5;
						
						_path.array[0].v0.x = _path.array[_path.length-1].vc.x;
						_path.array[0].v0.y = _path.array[_path.length-1].vc.y;
						_path.array[0].v0.z = _path.array[_path.length-1].vc.z;
						
						_path.array[0].vc.x = tpv2.x;
						_path.array[0].vc.y = tpv2.y;
						_path.array[0].vc.z = tpv2.z;
						
						tpv1 = null;
						tpv2 = null;
						
					} 
					 
				}*/
				
				var aSegPoints:Array = PathUtils.getPointsOnCurve(_path, _subdivision);
				 
				var aPointlist:Array = [];
				//var aSegresult:Array = [];
				var atmp:Array;
				var tmppt:Number3D = new Number3D(0,0,0);
				 
				var i:int;
				var j:int;
				var k:int;
				
				var nextpt:Number3D;
				
				var lastscale:Number3D = new Number3D(1, 1, 1);
				var rescale:Boolean = (_scales != null);
				var rotate:Boolean = (_rotations != null);
				
				if(rotate && _rotations.length > 0){
					var lastrotate:Number3D = _rotations[0] ;
					var nextrotate:Number3D;
					var aRotates:Array = [];
					var tweenrot:Number3D;
				}
				 
				if(_smoothscale && rescale)
					var nextscale:Number3D = new Number3D(1, 1, 1);
					var aTs:Array = [];
				
				if(_meshes.length == 0) getGeomInfo();
				 
				for (i = 0; i <aSegPoints.length; ++i) {
					
					if(_meshes.length > 0 && !_segmentspread) getGeomInfo();
					
					if(rotate &&  i <aSegPoints.length){
						lastrotate = (_rotations[i] == null) ? lastrotate : _rotations[i];
						nextrotate = (_rotations[i+1] == null) ? lastrotate : _rotations[i+1];						
						aRotates = [lastrotate];
						aRotates = aRotates.concat(PathUtils.step( lastrotate, nextrotate,  _subdivision));
					}
					
					if(rescale)
						lastscale = (_scales[i] == null) ? lastscale : _scales[i];
						
					if(_smoothscale && rescale &&  i <aSegPoints.length){
						nextscale = (_scales[i+1] == null) ? lastscale : _scales[i+1];
						aTs = aTs.concat(PathUtils.step( lastscale, nextscale, _subdivision)); 
					}
					
					for(j = 0; j<aSegPoints[i].length;++j){
						
						if(_meshes.length > 0 && _segmentspread) getGeomInfo();
						
						atmp = [];
						atmp = atmp.concat(_points);
						aPointlist = [];
						
						if(rotate)
							tweenrot = aRotates[j];
						
						if(_aligntopath) {
							_transform = new Matrix3D();
							
							if(i == aSegPoints.length -1 && j == aSegPoints[i].length-1){
								
								if(_closepath){
									nextpt = aSegPoints[0][0];
									orientateAt(nextpt, aSegPoints[i][j]);
								} else{
									nextpt = aSegPoints[i][j-1];
									orientateAt(aSegPoints[i][j], nextpt);
								}
								
							} else {
								nextpt = (j<aSegPoints[i].length-1)? aSegPoints[i][j+1]:  aSegPoints[i+1][0];
								orientateAt(nextpt, aSegPoints[i][j]);
							}
						}
						
						for (k = 0; k <atmp.length; ++k) {
							
							if(_aligntopath) {
								tmppt = new Number3D();
								tmppt.x = atmp[k].x * _transform.sxx + atmp[k].y * _transform.sxy + atmp[k].z * _transform.sxz + _transform.tx;
								tmppt.y = atmp[k].x * _transform.syx + atmp[k].y * _transform.syy + atmp[k].z * _transform.syz + _transform.ty;
								tmppt.z = atmp[k].x * _transform.szx + atmp[k].y * _transform.szy + atmp[k].z * _transform.szz + _transform.tz;
						
								if(rotate)
									tmppt = PathUtils.rotatePoint(tmppt, tweenrot);
									
								tmppt.x +=  aSegPoints[i][j].x;
								tmppt.y +=  aSegPoints[i][j].y;
								tmppt.z +=  aSegPoints[i][j].z;
								 
								aPointlist.push(tmppt);
								
							} else {
								
								tmppt = new Number3D(atmp[k].x+aSegPoints[i][j].x, atmp[k].y+aSegPoints[i][j].y, atmp[k].z+aSegPoints[i][j].z);
								aPointlist.push(tmppt );
							}
							
							if(rescale && !_smoothscale){
									tmppt.x *= lastscale.x;
									tmppt.y *= lastscale.y;
									tmppt.z *= lastscale.z;
							}
						}
						
						if (_scaling != 1) {
								for (k = 0; k < aPointlist.length; ++k) {
									aPointlist[k].x *= _scaling;
									aPointlist[k].y *= _scaling;
									aPointlist[k].z *= _scaling;
								}
						}
						
						generate(aPointlist);
					}
					 
				}
				
				if(rotate)
						aRotates = null;
				
				if(_meshes.length > 0)
						_meshes = null;
				/*
				if(rescale && _smoothscale){
					 
					for (i = 0; i < aTs.length; ++i) {
						
						 for (j = 0;j < aSegresult[i].length; ++j) {
							aSegresult[i][j].x *= aTs[i].x;
							aSegresult[i][j].y *= aTs[i].y;
							aSegresult[i][j].z *= aTs[i].z;
						 }
						 
					}
					
					aTs = null;
				}
				 */
				
				aSegPoints = null;
				
				if(_recenter) {
					applyPosition( (this.minX+this.maxX)*.5,  (this.minY+this.maxY)*.5, (this.minZ+this.maxZ)*.5);
				} 
				/*else {
					x =  _path.array[0].v1.x;
					y =  _path.array[0].v1.y;
					z =  _path.array[0].v1.z;
				}*/
				
				type = "PathDuplicator";
				url = "Extrude";
			
			} else {
				trace("PathDuplicator error: mesh must be a valid Object3D of Mesh Type (same for meshes array). Path definition requires at least 1 object with 3 parameters: {v0:Number3D, va:Number3D ,v1:Number3D}, all properties being Number3D.");
			} 
		}
		 
		/**
    	 * Defines the resolution beetween each CurveSegments. Default 2, minimum 2.
    	 */ 
		public function set subdivision(val:int):void
		{
			_subdivision = (val<2)? 2 :val;
		}
		public function get subdivision():int
		{
			return _subdivision;
		}
		/**
    	 * Defines the scaling of the final generated mesh. Not being considered while building the mesh. Default 1.
    	 */
		public function set scaling(val:Number):void
		{
			_scaling = val;
		}
		public function get scaling():Number
		{
			return _scaling;
		} 
		/**
    	 * Defines if the final mesh should have its pivot reset to its center after generation. Default false.
    	 */
		public function set recenter(b:Boolean):void
		{
			_recenter = b;
		}
		public function get recenter():Boolean
		{
			return _recenter;
		}
		/**
    	 * Defines if the last segment should join the first one and close the loop. Default false.
    	 */
		public function set closepath(b:Boolean):void
		{
			_closepath = b;
		}
		public function get closepath():Boolean
		{
			return _closepath;
		}
		/**
    	 * Defines if the profile point array should be orientated on path or not. Default true. Note that Path object worldaxis property might need to be changed. default = 0,1,0.
    	 */
		public function set aligntopath(b:Boolean):void
		{
			_aligntopath = b;
		}
		public function get aligntopath():Boolean
		{
			return _aligntopath;
		}
		/**
    	 * Defines if a scale array of number3d is passed if the scaling should be affecting the whole segment or spreaded from previous curvesegmentscale to the next curvesegmentscale. Default true.
    	 */
		public function set smoothscale(b:Boolean):void
		{
			_smoothscale = b;
		}
		public function get smoothscale():Boolean
		{
			return _smoothscale;
		}
		 /**
    	 * Sets and defines the Path object. See animators.data package. Required.
    	 */ 
		 public function set path(p:Path):void
    	{
    		_path = p;
    	}
		 public function get path():Path
    	{
    		return _path;
    	}
		 
		/**
    	 * Sets and defines the Array of Number3D's (the profile information to be projected according to the Path object). Required if you do not pass a meshes array.
    	 */
		 public function set mesh(m:Object3D):void
    	{
    		_mesh = m;
    	}
		 public function get mesh():Object3D
    	{
    		return _mesh;
    	}
		 
		/**
    	 * Sets and defines the optional Array of Number3D's. A series of scales to be set on each CurveSegments
    	 */
		 public function set scales(aR:Array):void
    	{
    		_scales = aR;
    	}
		 public function get scales():Array
    	{
    		return _scales;
    	}
		
		/**
    	 * Sets and defines the optional Array of meshes. A series of meshes to be placed to be duplicated within each CurveSegments. When the last one in the array is reached, the first in the array will be used until the class reaches the last segment.
    	 */
		 public function set meshes(aR:Array):void
    	{
    		_meshes = aR;
    	}
		 public function get meshes():Array
    	{
    		return _meshes;
    	}
		
		/**
    	 * if the optional Array of meshes is passed, segmentspread define if the meshes[index] is repeated per segments or duplicated after each others. default = false.
    	 */
		 public function set segmentspread(b:Boolean):void
    	{
    		_segmentspread = b;
    	}
		 public function get segmentspread():Boolean
    	{
    		return _segmentspread;
    	}
		
		/**
    	 * Sets and defines the optional material to apply on each duplicated mesh information, according to source mesh.
    	 */
		 public function set texture(mat:ITriangleMaterial):void
    	{
    		_material = mat;
    	}
		 public function get texture():ITriangleMaterial
    	{
    		return _material;
    	}
		
		/**
    	* Sets and defines the optional Array of Number3D's. A series of rotations to be set on each CurveSegments
    	*/
		 public function set rotations(aR:Array):void
    	{
    		_rotations = aR;
    	}
		 public function get rotations():Array
    	{
    		return _rotations;
    	}
		
		 
	}
}
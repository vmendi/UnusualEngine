﻿package away3d.materials.shaders
{
	import away3d.arcane;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.math.Matrix3D;
	import away3d.core.render.*;
	import away3d.core.utils.*;
	
	import flash.display.*;
	import flash.geom.*;
	
	use namespace arcane;
	
	/**
	 * Shader class for environment lighting.
	 */
    public class EnviroShader extends AbstractShader
    {
        /** @private */
		arcane var _bitmap:BitmapData;
        /** @private */
		arcane var _reflectiveness:Number;
        /** @private */
		arcane var _colorTransform:ColorTransform;
        
		private var _width:int;
		private var _height:int;
		private var _halfWidth:int;
		private var _halfHeight:int;
		private var _enviroTransform:Matrix3D;
		 
		private var _sxd:Number;
		private var _sxx:Number;
		private var _sxy:Number;
		private var _sxz:Number;
		
		private var _syd:Number;
        private var _syx:Number;
        private var _syy:Number;
        private var _syz:Number;
                
        /**
        * Calculates the mapping matrix required to draw the triangle texture to screen.
        * 
        * @param	source	The source object of the material.
        * @param	face	The face object of the material.
        * @return			The required matrix object.
        */
		protected function getMapping(source:Mesh, face:Face):Matrix
		{
    		_n0 = source.geometry.getVertexNormal(face.v0);
			_n1 = source.geometry.getVertexNormal(face.v1);
			_n2 = source.geometry.getVertexNormal(face.v2);
			
			eTri0x = _n0.x * _sxx + _n0.y * _sxy + _n0.z * _sxz;
			eTri0y = _n0.x * _syx + _n0.y * _syy + _n0.z * _syz;
			eTri1x = _n1.x * _sxx + _n1.y * _sxy + _n1.z * _sxz;
			eTri1y = _n1.x * _syx + _n1.y * _syy + _n1.z * _syz;
			eTri2x = _n2.x * _sxx + _n2.y * _sxy + _n2.z * _sxz;
			eTri2y = _n2.x * _syx + _n2.y * _syy + _n2.z * _syz;
			
			//catch mapping where points are the same (flat surface)
			if (eTri1x == eTri0x && eTri1y == eTri0y) {
				eTri1x += 0.1;
				eTri1y += 0.1;
			}
			if (eTri2x == eTri1x && eTri2y == eTri1y) {
				eTri2x += 0.1;
				eTri2y += 0.1;
			}
			if (eTri0x == eTri2x && eTri0y == eTri2y) {
				eTri0x += 0.1;
				eTri0y += 0.1;
			}
			
			//calulate mapping
			_mapping.a = _halfWidth*(eTri1x - eTri0x);
			_mapping.b = _halfHeight*(eTri1y - eTri0y);
			_mapping.c = _halfWidth*(eTri2x - eTri0x);
			_mapping.d = _halfHeight*(eTri2y - eTri0y);
			_mapping.tx = _halfWidth*eTri0x + _halfWidth;
			_mapping.ty = _halfHeight*eTri0y + _halfHeight;
            _mapping.invert();
            
            return _mapping;
		}
		
		/**
		 * @inheritDoc
		 */
		protected function clearFaces(source:Object3D, view:View3D):void
        {
        	notifyMaterialUpdate();
        	
        	for each (var faceMaterialVO:FaceMaterialVO in _faceDictionary) {
        		if (source == faceMaterialVO.source && view == faceMaterialVO.view) {
	        		if (!faceMaterialVO.cleared)
	        			faceMaterialVO.clear();
	        		faceMaterialVO.invalidated = true;
	        	}
        	}
        }
        
		/**
		 * @inheritDoc
		 */
        protected override function renderShader(tri:DrawTriangle):void
        {
			//store a clone
			if (_faceMaterialVO.cleared && !_parentFaceMaterialVO.updated) {
				_faceMaterialVO.bitmap = _parentFaceMaterialVO.bitmap.clone();
				_faceMaterialVO.bitmap.lock();
			}
			
			_faceMaterialVO.cleared = false;
			_faceMaterialVO.updated = true;
			
			_faceVO = tri.faceVO;
			
			_mapping = getMapping(tri.source as Mesh, _face);
            _mapping.concat(_faceMaterialVO.invtexturemapping);
            
			//draw into faceBitmap
			_faceMaterialVO.bitmap.draw(_bitmap, _mapping, null, blendMode, _faceMaterialVO.bitmap.rect, smooth);
        }
        
		/**
		 * Setting for possible mapping methods.
		 */
		public var mode:String;
        
        /**
        * Returns the width of the bitmapData being used as the shader environment map.
        */
        public function get height():Number
        {
            return _bitmap.height;
        }
        
        /**
        * Returns the height of the bitmapData being used as the shader environment map.
        */
		public function get width():Number
        {
            return _bitmap.width;
        }
        
        /**
        * Returns the bitmapData object being used as the shader environment map.
        */
        public function get bitmap():BitmapData
        {
        	return _bitmap;
        }
				
		/**
		 * Coefficient for the reflectiveness of the environment map.
		 */
        public function get reflectiveness():Number
        {
        	return _reflectiveness;
        }
        
        public function set reflectiveness(val:Number):void
        {
            _reflectiveness = val;
            _colorTransform = new ColorTransform(_reflectiveness, _reflectiveness, _reflectiveness, 1);
        }
		
		/**
		 * Creates a new <code>EnviroShader</code> object.
		 * 
		 * @param	bitmap			The bitmapData object to be used as the material's environment map.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function EnviroShader(bitmap:BitmapData, init:Object = null)
        {
        	super(init);
            _bitmap = new BitmapData(bitmap.width,bitmap.height,true); // ensure  that alpha is discarded
            _bitmap.draw(bitmap);
            
            mode = ini.getString("mode", "linear");
            reflectiveness = ini.getNumber("reflectiveness", 0.5, {min:0, max:1});
            
        	_width = _bitmap.width;
        	_height = _bitmap.height;
			
            _halfWidth = _width/2;
            _halfHeight = _height/2;
        }
        
		/**
		 * @inheritDoc
		 */
		public override function updateMaterial(source:Object3D, view:View3D):void
        {
        	_enviroTransform = view.cameraVarsStore.viewTransformDictionary[source];
        	
			_sxx = _enviroTransform.sxx;
			_sxy = _enviroTransform.sxy;
			_sxz = _enviroTransform.sxz;
        	
        	_sxd = Math.sqrt(_sxx*_sxx + _sxy*_sxy + _sxz*_sxz);
			
			_sxx /= _sxd;
			_sxy /= _sxd;
			_sxz /= _sxd;
			
			_syx = _enviroTransform.syx;
			_syy = _enviroTransform.syy;
			_syz = _enviroTransform.syz;
			
        	_syd = Math.sqrt(_syx*_syx + _syy*_syy + _syz*_syz);
			
			_syx /= _syd;
			_syy /= _syd;
			_syz /= _syd;
			
        	if (view.scene.updatedObjects[source] || view.updated)
        		clearFaces(source, view);
        }
        
		/**
		 * @inheritDoc
		 */
        public override function renderLayer(tri:DrawTriangle, layer:Sprite, level:int):int
        {
        	super.renderLayer(tri, layer, level);
			
    		_shape = tri.source.session.getShape(this, level++, layer);
        	_shape.blendMode = blendMode;
        	_shape.transform.colorTransform = _colorTransform;
    		
			_source.session.renderTriangleBitmap(_bitmap, getMapping(_source, _face), tri.screenVertices, tri.screenIndices, tri.startIndex, tri.endIndex, smooth, false, _shape.graphics);
			
			if (debug)
                _source.session.renderTriangleLine(0, 0x0000FF, 1, tri.screenVertices, tri.screenCommands, tri.screenIndices, tri.startIndex, tri.endIndex);
            
            return level;
        }
    }
}
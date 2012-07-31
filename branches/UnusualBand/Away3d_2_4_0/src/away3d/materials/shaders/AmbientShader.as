﻿package away3d.materials.shaders {
	import away3d.core.light.DirectionalLight;	
	import away3d.core.light.AmbientLight;	
	import away3d.core.utils.FaceMaterialVO;	
	import away3d.containers.*;
	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.render.*;
	
	import flash.display.*;
	
	use namespace arcane;
	
	/**
	 * Shader class for ambient lighting
	 * 
	 * @see away3d.lights.AmbientLight3D
	 */
    public class AmbientShader extends AbstractShader
    {
        /**
        * Defines a 24 bit color value used by the shader
        */
        public var color:uint;
    	
		/**
		 * Creates a new <code>AmbientShader</code> object.
		 * 
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function AmbientShader(init:Object = null)
        {
        	super(init);
        }
        
		/**
		 * @inheritDoc
		 */
		public override function updateMaterial(source:Object3D, view:View3D):void
        {
        }
        
		/**
		 * @inheritDoc
		 */
        protected function clearFaces(source:Object3D, view:View3D):void
        {
        	view;//TODO : FDT Warning
        	notifyMaterialUpdate();
        	
        	for each (var _faceMaterialVO:FaceMaterialVO in _faceDictionary)
        		if (source == _faceMaterialVO.source)
	        		if (!_faceMaterialVO.cleared)
	        			_faceMaterialVO.clear();
        }
        
		/**
		 * @inheritDoc
		 */
        public override function renderLayer(tri:DrawTriangle, layer:Sprite, level:int):int
        {
        	super.renderLayer(tri, layer, level);
    		
    		var _tri_source_lightarray_ambients:Array = tri.source.lightarray.ambients;
        	for each (var ambient:AmbientLight in _tri_source_lightarray_ambients)
        	{
        		if (_lights.numLights > 1) {
					_shape = _session.getLightShape(this, level++, layer, ambient);
		        	_shape.blendMode = blendMode;
		        	_graphics = _shape.graphics;
		        } else {
		        	_graphics = layer.graphics;
		        }
	        	
				_source.session.renderTriangleBitmap(ambient.ambientBitmap, _mapping, tri.screenVertices, tri.screenIndices, tri.startIndex, tri.endIndex, smooth, false, _graphics);
        	}
			
			if (debug)
            	tri.source.session.renderTriangleLine(0, 0x0000FF, 1, tri.screenVertices, tri.screenCommands, tri.screenIndices, tri.startIndex, tri.endIndex);
            
            return level;
        }
        
		/**
		 * @inheritDoc
		 */
        protected override function renderShader(tri:DrawTriangle):void
        {
			tri;//TODO : FDT Warning
			var _source_lightarray_ambients:Array = _source.lightarray.ambients;
			for each (var ambient:AmbientLight in _source_lightarray_ambients)
	    	{
				_faceMaterialVO.bitmap.draw(ambient.ambientBitmap, null, null, blendMode);
	    	}
	    	
	    	var _source_lightarray_directionals:Array = _source.lightarray.directionals;
	    	for each (var directional:DirectionalLight in _source_lightarray_directionals)
	    	{
				_faceMaterialVO.bitmap.draw(directional.ambientBitmap, null, null, blendMode);
	    	}
        }
    }
}

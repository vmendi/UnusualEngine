﻿package away3d.core.filter
{
    import away3d.cameras.*;
    import away3d.containers.*;
    import away3d.core.clip.*;
    import away3d.core.draw.*;
    import away3d.core.utils.*;
    import away3d.materials.*;

    /**
    * Adds fog layers to a view and provides automatic farfield filtering for primitives outside the furthest fog layers.
	*/
    public class FogFilter implements IPrimitiveFilter
    {
    	private var i:int;
    	private var _primitives:Array;
    	private var _material:IFogMaterial;
    	private var _minZ:Number;
    	private var _maxZ:int;
    	private var _subdivisions:int;
    	private var _materials:Array;
    	private var _fogPrimitives:Array;
 		private var _materialsDirty:Boolean = true;
 		
 		private function updateMaterials():void
 		{
 			_materialsDirty = false;
 			
 			var sub:int;
 			
			//materials override subdivisions
            if (!_materials.length) {
            	i = sub = _subdivisions;
            	while (i--)
            		_materials.push(_material.clone());
            } else {
            	sub = _materials.length;
            }
            
            i = sub;
            _fogPrimitives = new Array();
			var fog:DrawFog;
            while(i--) {
            	(_materials[i] as IFogMaterial).alpha = 0.45*i/sub;
            	fog = new DrawFog();
            	fog.screenZ = _minZ + (_maxZ - _minZ)*i/(sub - 1);
            	fog.material = _materials[i];
            	_fogPrimitives.unshift(fog);
            }
 		}
 		
        /**
        * Instance of the Init object used to hold and parse default property values
        * specified by the initialiser object in the 3d object constructor.
        */
		protected var ini:Init;
		
		/**
		 * Defines the material used by the fog layers.
		 */
		public function get material():IFogMaterial
		{
			return _material;
		}
		
		public function set material(val:IFogMaterial):void
		{
			if (!(val is IFogMaterial))
            	throw new Error("FogFilter requires IFogMaterial");
            
			_material = val;
			
			_materialsDirty = true;
		}
		
		/**
		 * Defines the minimum distance (start distance) of the fog layers.
		 */
		public function get minZ():Number
		{
			return _minZ;
		}
		
		public function set minZ(val:Number):void
		{
			if (_minZ == val)
				return;
			
			_minZ = val;
			
			_materialsDirty = true;
		}
		
		/**
		 * Defines the maximum distance (end distance) of the fog layers.
		 */
		public function get maxZ():Number
		{
			return _maxZ;
		}
		
		public function set maxZ(val:Number):void
		{
			if (_maxZ == val)
				return;
			
			_maxZ = val;
			
			_materialsDirty = true;
		}
		
		/**
		 * Defines the maximum distance (end distance) of the fog layers.
		 */
		public function get subdivisions():Number
		{
			return _subdivisions;
		}
		
		public function set subdivisions(val:Number):void
		{
			if (_subdivisions == val)
				return;
			
			_subdivisions = val;
			
			_materialsDirty = true;
		}
		
		/**
		 * Defines an array of materials used by the fog layers (overrides material and subdivisions).
		 */
		public function get materials():Array
		{
			return _materials;
		}
		
		public function set materials(val:Array):void
		{
			_materials = val;
			
			_materialsDirty = true;
		}
		
		/**
		 * Creates a new <code>FogFilter</code> object.
		 *
		 * @param	init			[optional]	An initialisation object for specifying default instance properties.
		 */
		public function FogFilter(init:Object = null):void
		{
			ini = Init.parse(init);
			
			_material = ini.getMaterial("material") as IFogMaterial || new ColorMaterial(0x000000);
			_minZ = ini.getNumber("minZ", 1000, {min:0});
            _maxZ = ini.getNumber("maxZ", 5000, {min:0});
            _subdivisions = ini.getInt("subdivisions", 20, {min:1, max:50});
            _materials = ini.getArray("materials");
		}
		
		/**
		 * Allows color change at runtime of the filter
		 * @param	color			The new color for the filter
		 */
		public function updateMaterialColor(color:uint):void
		{
			for each (var fog:DrawFog in _fogPrimitives) {
				if(fog.material is ColorMaterial)
					fog.material = new ColorMaterial(color, {alpha:fog.material.alpha});
			}
		}
		
		/**
		 * @inheritDoc
		 */
        public function filter(primitives:Array, scene:Scene3D, camera:Camera3D, clip:Clipping):Array
        {
        	if (_materialsDirty)
        		updateMaterials();
        	
        	if (!primitives.length || !primitives[0].source || primitives[0].source.session != scene.session)
        		return primitives;
				
        	var fog:DrawFog;
			for each (fog in _fogPrimitives) {
				fog.source = scene;
				fog.clip = clip;
				primitives.push(fog);
			}
			
			_primitives = [];
			
			var p:DrawPrimitive;
			for each (p in primitives) {
				if (p.screenZ < _maxZ)
					_primitives.push(p); 
			}

        	return _primitives;
        }
		
		/**
		 * Used to trace the values of a filter.
		 * 
		 * @return A string representation of the filter object.
		 */
        public function toString():String
        {
            return "FogFilter";
        }
    }
}

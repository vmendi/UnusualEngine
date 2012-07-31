﻿package away3d.loaders.utils
{
    import away3d.core.utils.Debug;
    import away3d.loaders.data.*;
    import away3d.materials.*;
    
    import flash.display.BitmapData;
    import flash.utils.Dictionary;
    
    /**
    * Store for all materials associated with an externally loaded file.
    */
    public dynamic class MaterialLibrary extends Dictionary
    {
    	private var length:int = 0;
    	
    	/**
    	 * The root directory path to the texture files.
    	 */
    	public var texturePath:String;
    	
    	/**
    	 * Flag to determine if any of the contained textures require a file load.
    	 */
    	public var loadRequired:Boolean;
    	
    	/**
    	 * Adds a material name reference to the library.
    	 */
        public function addMaterial(name:String):MaterialData
        {
        	//return if material already exists
        	if (this[name])
        		return this[name];
        	
        	length++;
        	
        	var materialData:MaterialData = new MaterialData();
            this[materialData.name = name] = materialData;
            return materialData;
        }
    	
    	/**
    	 * Returns a material data object for the given name reference in the library.
    	 */
        public function getMaterial(name:String):MaterialData
        {
        	//return if material exists
        	if (this[name])
        		return this[name];
        	
        	Debug.warning("Material '" + name + "' does not exist");
        	
        	return null;
        }
        
    	
    	/**
    	 * Called after all textures have been loaded from the <code>TextureLoader</code> class.
    	 * 
    	 * @see away3d.loaders.utils.TextureLoader
    	 */
    	public function texturesLoaded(loadQueue:TextureLoadQueue):void
    	{
    		loadRequired = false;
    		
			var images:Array = loadQueue.images;
			var _materialData:MaterialData;
			var _image:TextureLoader;
			for each (_materialData in this)
			{
				for each (_image in images)
				{
					if (texturePath + _materialData.textureFileName == _image.filename)
					{
						try{
							_materialData.textureBitmap = new BitmapData(_image.width, _image.height, true, 0x00FFFFFF);
							_materialData.textureBitmap.draw(_image);
							_materialData.material = new BitmapMaterial(_materialData.textureBitmap);
						}catch(e:*){
							Debug.warning("File not found : " + texturePath + _materialData.textureFileName );
							_materialData.material = new WireframeMaterial();
						}
					}
				}
			}
    	}
    }
}
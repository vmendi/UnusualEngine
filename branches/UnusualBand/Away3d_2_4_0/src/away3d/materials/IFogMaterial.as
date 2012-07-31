﻿package away3d.materials
{
    import away3d.core.draw.*;

    /**
    * Interface for fog filter materials
    */
    public interface IFogMaterial extends ITriangleMaterial
    {
    	/**
    	 * Determines the alpha value of the material
    	 */
    	function get alpha():Number;
    	function set alpha(val:Number):void;
    	
    	/**
    	 * Sends the material data coupled with data from the DrawFog primitive to the render session
    	 */
		function renderFog(fog:DrawFog):void;
		
		/**
		 * Duplicates the material's properties to another <code>IFogMaterial</code> object
		 * 
		 * @return			The new object instance with duplicated properties applied
		 */
		function clone():IFogMaterial;
	}
}

﻿package away3d.loaders
{
    import away3d.arcane;
    import away3d.core.base.*;
    import away3d.core.utils.*;
    import away3d.materials.*;
    
    import flash.utils.*;
	
	use namespace arcane;
	
    /**
    * File loader for the Md2 file format.
    * 
    * @author Philippe Ajoux (philippe.ajoux@gmail.com)
    */
    public class Md2 extends AbstractParser
    {
		/** @private */
        arcane override function prepareData(data:*):void
        {
        	md2 = Cast.bytearray(data);
        	
            md2.endian = Endian.LITTLE_ENDIAN;

            var vertices:Array = [];
            var faces:Array = [];
            var uvs:Array = [];
            
            ident = md2.readInt();
            version = md2.readInt();

            // Make sure it is valid MD2 file
            if (ident != 844121161 || version != 8)
                throw new Error("Error loading MD2 file: Not a valid MD2 file/bad version");
                
            skinwidth = md2.readInt();
            skinheight = md2.readInt();
            framesize = md2.readInt();
            num_skins = md2.readInt();
            num_vertices = md2.readInt();
            num_st = md2.readInt();
            num_tris = md2.readInt();
            num_glcmds = md2.readInt();
            num_frames = md2.readInt();
            offset_skins = md2.readInt();
            offset_st = md2.readInt();
            offset_tris = md2.readInt();
            offset_frames = md2.readInt();
            offset_glcmds = md2.readInt();
            offset_end = md2.readInt();

            var i:int;
            // Vertice setup
            //      Be sure to allocate memory for the vertices to the object
            //      These vertices will be updated each frame with the proper coordinates
            for (i = 0; i < num_vertices; ++i)
                vertices.push(new Vertex());
				
			// map
			md2.position = offset_skins;
			var url:String = "";
			var char:uint;
			for (i = 0; i < 64; ++i) {
				char = md2.readUnsignedByte();
				if (char == 0)
					break;
				url += String.fromCharCode(char);
			}
			
			//overridden by the material property in constructor
			if (material) {
				mesh.material = material;
			} else if(url.substring(url.length -4, url.length -3) == "."){
				if(url.toLowerCase().indexOf("pcx") != -1){
					url = url.substring(-1, url.length -3) + pcxConvert;
				}
				trace("Material source: "+url+". Pass pcxConvert:'gif' or 'png' to load other file types. Filename remains unchanged");
				mesh.material = new BitmapFileMaterial(url);
			}

            // UV coordinates
            md2.position = offset_st;
            for (i = 0; i < num_st; i++)
                uvs.push(new UV(md2.readShort() / skinwidth, 1 - ( md2.readShort() / skinheight) ));

            // Faces
            md2.position = offset_tris;
			// export requirement
			mesh.indexes = new Array();
			
            for (i = 0; i < num_tris; i++)
            {
                var a:int = md2.readUnsignedShort();
                var b:int = md2.readUnsignedShort();
                var c:int = md2.readUnsignedShort();
                var ta:int = md2.readUnsignedShort();
                var tb:int = md2.readUnsignedShort();
                var tc:int = md2.readUnsignedShort();
				
				mesh.indexes.push([a,b,c,ta,tb,tc]);
                
                mesh.addFace(new Face(vertices[a], vertices[b], vertices[c], null, uvs[ta], uvs[tb], uvs[tc]));
            }
            
            // Frame animation md2
            //      This part is a little funky.
            md2.position = offset_frames;
            readFrames(md2, vertices, num_frames);
            
            mesh.type = ".Md2";
        }
        
        private var md2:ByteArray;
        private var ident:int;
        private var version:int;
        private var skinwidth:int;
        private var skinheight:int;
        private var framesize:int;
        private var num_skins:int;
        private var num_vertices:int;
        private var num_st:int;
        private var num_tris:int;
        private var num_glcmds:int;
        private var num_frames:int;
        private var offset_skins:int;
        private var offset_st:int;
        private var offset_tris:int;
        private var offset_frames:int;
        private var offset_glcmds:int;
        private var offset_end:int;
    	private var mesh:Mesh;
        
        private function readFrames(data:ByteArray, vertices:Array, num_frames:int):void
        {
            mesh.geometry.frames = new Dictionary();
            mesh.geometry.framenames = new Dictionary();
            for (var i:int = 0; i < num_frames; i++)
            {
                var frame:Frame = new Frame();
                
                var sx:Number = data.readFloat();
                var sy:Number = data.readFloat();
                var sz:Number = data.readFloat();
                
                var tx:Number = data.readFloat();
                var ty:Number = data.readFloat();
                var tz:Number = data.readFloat();

                var name:String = "";
                for (var j:int = 0; j < 16; j++)
                {
                    var char:int = data.readUnsignedByte();
                    if (char != 0)
                        name += String.fromCharCode(char);
                }
				trace("[ "+name+" ]");
                mesh.geometry.framenames[name] = i;
                mesh.geometry.frames[i] = frame;
                for (var h:int = 0; h < vertices.length; h++)
                {
                    var vp:VertexPosition = new VertexPosition(vertices[h]);
                    vp.x = -((sx * data.readUnsignedByte()) + tx) * scaling;
                    vp.z = ((sy * data.readUnsignedByte()) + ty) * scaling;
                    vp.y = ((sz * data.readUnsignedByte()) + tz) * scaling;
                    data.readUnsignedByte(); // "vertex normal index"
                    frame.vertexpositions.push(vp);
                }
                if (i == 0)
                    frame.adjust();
            }
        }
        
    	/**
    	 * Extension to use if .pcx format encountered. Defaults to jpg.
    	 */
        public var pcxConvert:String;
        
    	/**
    	 * A scaling factor for all geometry in the model. Defaults to 1.
    	 */
        public var scaling:Number;
        
    	/**
    	 * Overrides all materials in the model.
    	 */
        public var material:ITriangleMaterial;
        
		/**
		 * Creates a new <code>Md2</code> object. Not intended for direct use, use the static <code>parse</code> or <code>load</code> methods.
		 * 
		 * @param	data				The binary data of a loaded file.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 * 
		 * @see away3d.loaders.Md2#parse()
		 * @see away3d.loaders.Md2#load()
		 */
        public function Md2(init:Object = null)
        {
            super(init);
            
			pcxConvert = ini.getString("pcxConvert", "jpg");
            scaling = ini.getNumber("scaling", 1) * 100;
			material = ini.getMaterial("material") as ITriangleMaterial;
			
            mesh = (container = new Mesh(ini)) as Mesh;
            
            binary = true;
        }

		/**
		 * Creates a 3d mesh object from the raw binary data of an md2 file.
		 * 
		 * @param	data				The binary data of a loaded file.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 * 
		 * @return						A 3d mesh object representation of the md2 file.
		 */
        public static function parse(data:*, init:Object = null):Mesh
        {
            return Loader3D.parseGeometry(data, Md2, init).handle as Mesh;
        }
    	
    	/**
    	 * Loads and parses an md2 file into a 3d mesh object.
    	 * 
    	 * @param	url					The url location of the file to load.
    	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
    	 * @return						A 3d loader object that can be used as a placeholder in a scene while the file is loading.
    	 */
        public static function load(url:String, init:Object = null):Loader3D
        {
            return Loader3D.loadGeometry(url, Md2, init);
        }
    }
}
﻿package away3d.loaders
{
    import away3d.containers.ObjectContainer3D;
    import away3d.arcane;
    import away3d.core.base.*;
    import away3d.core.utils.*;
    import away3d.materials.BitmapFileMaterial;
	 
    import flash.events.*;
    import flash.net.*;
	
	use namespace arcane;
	
    /**
    * File loader for the OBJ file format.<br/>
    * <br/>
	* note: Multiple objects support and autoload mtls are supported since Away v 2.1.<br/>
	* Class tested with the following 3D apps:<br/>
	* - Strata CX mac 5.5<br/>
	* - Biturn ver 0.87b4 PC<br/>
	* - LightWave 3D OBJ Export v2.1 PC<br/>
	* - Max2Obj Version 4.0 PC<br/>
	* - AC3D 6.2.025 mac<br/>
	* - Carrara (file provided)<br/>
	* - Hexagon (file provided)<br/>
	* - geometry supported tags: f,v,vt, g<br/>
	* - geometry unsupported tags:vn,ka, kd r g b, kd, ks r g b,ks,ke r g b,ke,d alpha,d,tr alpha,tr,ns s,ns,illum n,illum,map_Ka,map_Bump<br/>
	* - mtl unsupported tags: kd,ka,ks,ns,tr<br/> 
	* <br/>
	* export from apps as polygon group or mesh as .obj file.<br/>
	* added support for 3dmax negative vertexes references
    */
    public class Obj extends AbstractParser
    {
    	/** @private */
        arcane override function prepareData(data:*):void
        {
        	obj = Cast.string(data);
        	
			var lines:Array = obj.split('\n');
			if(lines.length == 1) lines = obj.split(String.fromCharCode(13));
			var trunk:Array;
			var isNew:Boolean = true;
			var group:ObjectContainer3D;
			 
			vertices = [new Vertex()];
            uvs = [new UV()];
			
			var isNeg:Boolean;
			var myPattern:RegExp = new RegExp("-","g");
			var face0:Array;
			var face1:Array;
			var face2:Array;
			var face3:Array;
			 
            for each (var line:String in lines)
            {
                trunk = line.replace("  "," ").replace("  "," ").replace("  "," ").split(" ");
				 
                switch (trunk[0])
                {
					case "g":
						group = new ObjectContainer3D();
						group.name = trunk[1];
						
						if (container == null) {
							if(aMeshes.length == 1){
								container = new ObjectContainer3D(aMeshes[0].mesh);
							} else{
								container = new ObjectContainer3D();
							}
						}
						
						(container as ObjectContainer3D).addChild(group);
						isNew = true;
						
                        break;
						
					case "usemtl":
						aMeshes[aMeshes.length-1].materialid = trunk[1];
						break;
						
                    case "v": 
						if(isNew) {
							generateNewMesh();
							isNew = false;
							if(group != null){
								group.addChild(mesh);
							}
						}
						 
                        vertices.push(new Vertex(-parseFloat(trunk[1]) * scaling, parseFloat(trunk[2]) * scaling, -parseFloat(trunk[3]) * scaling));
						
                        break;
						
                    case "vt":
                        uvs.push(new UV(parseFloat(trunk[1]), parseFloat(trunk[2])));
                        break;
						
                    case "f":
						isNew = true;
						
						if(trunk[1].indexOf("-") == -1) {
							
							face0 = trysplit(trunk[1], "/");
							face1 = trysplit(trunk[2], "/");
							face2 = trysplit(trunk[3], "/");
							
							if (trunk[4] != null){
								face3 = trysplit(trunk[4], "/");
							}else{
								face3 = null;
							}
							
							isNeg = false;
							
						} else {
							
							face0 = trysplit(trunk[1].replace(myPattern, "") , "/");
							face1 = trysplit(trunk[2].replace(myPattern, "") , "/");
							face2 = trysplit(trunk[3].replace(myPattern, "") , "/");
							
							if (trunk[4] != null){
								face3 = trysplit(trunk[4].replace(myPattern, "") , "/");
							} else{
								face3 = null;
							}
							
							isNeg = true;
						}
						
						
						try{
							
							if (face3 != null && face3.length>0 && !isNaN(parseInt(face3[0])) ){
								
								if(isNeg){
									
									mesh.addFace(new Face(vertices[vertices.length - parseInt(face1[0])], vertices[vertices.length - parseInt(face0[0])], vertices[vertices.length - parseInt(face3[0])], 
													 null, checkUV(1, uvs[uvs.length - parseInt(face1[1])]), checkUV(2, uvs[uvs.length - parseInt(face0[1])]), checkUV(3, uvs[uvs.length - parseInt(face3[1])])  ));
		
									mesh.addFace(new Face(vertices[vertices.length - parseInt(face2[0])], vertices[vertices.length - parseInt(face1[0])], vertices[vertices.length - parseInt(face3[0])], 
													 null, checkUV(1, uvs[uvs.length - parseInt(face2[1])]), checkUV(2, uvs[uvs.length - parseInt(face1[1])]), checkUV(3, uvs[uvs.length - parseInt(face3[1])]) ));
									
								} else {
									
									mesh.addFace(new Face(vertices[parseInt(face1[0])], vertices[parseInt(face0[0])], vertices[parseInt(face3[0])], 
													 null, checkUV(1, uvs[parseInt(face1[1])]), checkUV(2, uvs[parseInt(face0[1])]), checkUV(3, uvs[parseInt(face3[1])]) ));
		
									mesh.addFace(new Face(vertices[parseInt(face2[0])], vertices[parseInt(face1[0])], vertices[parseInt(face3[0])], 
													 null, checkUV(1, uvs[parseInt(face2[1])]), checkUV(2, uvs[parseInt(face1[1])]), checkUV(3, uvs[parseInt(face3[1])]) ));
								}
								
							} else {
								
								if(isNeg){
									
									mesh.addFace(new Face(vertices[vertices.length - parseInt(face2[0])], vertices[vertices.length- parseInt(face1[0])], vertices[vertices.length- parseInt(face0[0])], 
													 null, checkUV(1, uvs[uvs.length - parseInt(face2[1])]), checkUV(2, uvs[uvs.length - parseInt(face1[1])]), checkUV(3, uvs[uvs.length - parseInt(face0[1])]) ));
								} else {
									 
									mesh.addFace(new Face(vertices[parseInt(face2[0])], vertices[parseInt(face1[0])], vertices[parseInt(face0[0])], 
												 	null, checkUV(1, uvs[parseInt(face2[1])]), checkUV(2, uvs[parseInt(face1[1])]), checkUV(3, uvs[parseInt(face0[1])]) ));
								}
								
							}
							
							
						}catch(e:Error){
							trace("Error while parsing obj file: unvalid face f "+face0+","+face1+","+face2+","+face3);
						}
						
                        break;
					 
                }
            }
			 
			vertices = null;
            uvs = null;
			
			if (container == null)
				container = mesh;
			
			//check materials
			var index:int = obj.indexOf("mtllib");
			if(index != -1){
				aSources = [];
				loadMtl (parseUrl(index, obj));
			}
        }
        
    	private var obj:String;
        public var mesh:Mesh;
		private var mtlPath:String;
        private var aMeshes:Array = [];
		private var aSources:Array;
		private var aMats:Array;
		private var vertices:Array = [];
        private var uvs:Array = [];
        private var scaling:Number;
      	
		private function checkUV(id:int, uv:UV = null):UV
        {
			if(uv == null){
				switch(id){
					case 1:
						return new UV(0, 1);
						break;
					case 2:
						return new UV(.5, 0);
						break;
					case 3:
						return new UV(1, 1);
						break;
				}
					
			}
			
			return uv;
		}
		
        private static function trysplit(source:String, by:String):Array
        {
            if (source == null)
                return null;
            if (source.indexOf(by) == -1)
                return [source];
				
            return source.split(by);
        }
		 
		private function errorMtl (event:Event):void
		{
			trace("Obj MTL LOAD ERROR: unable to load .mtl file at "+mtlPath);
		}
		
		private function mtlProgress (event:Event):void
		{
			 //NOT BUILDED IN YET
			 //trace( (event.target.bytesLoaded / event.target.bytesTotal) *100);
		}
		
		private function loadMtl(url:String):void
        {
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, parseMtl);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorMtl);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorMtl);
			loader.addEventListener(ProgressEvent.PROGRESS, mtlProgress);
			loader.load(new URLRequest(mtlPath+url));
        }
		
		private function parseUrl(index:Number, data:String):String
		{
			return data.substring(index+7,data.indexOf(".mtl")+4);
		}
		  
		private function parseMtl(event:Event):void
		{
			var lines:Array = event.target["data"].split('\n');
			if(lines.length == 1) lines = event.target["data"].split(String.fromCharCode(13));
			var trunk:Array;
			var i:int;
			var j:int;
			var _face:Face;
			var mat:BitmapFileMaterial;
			aMats = [];
			
            for each (var line:String in lines)
            {
				trunk = line.split(" ");
				switch (trunk[0])
				{				
					case "newmtl":
						aSources.push({material:null, materialid:trunk[1]});
						break;
					case "map_Kd":
						mat = checkDoubleMaterials(mtlPath+trunk[1]); 
						aSources[aSources.length-1].material = mat;
						//aSources[aSources.length-1].material = new BitmapFileMaterial(baseUrl+trunk[1]);
						break;
				}
			}
			
			for(j = 0;j<aMeshes.length; ++j){
				for(i = 0;i<aSources.length;++i){
					if(aMeshes[j].materialid == aSources[i].materialid){
						mat = aSources[i].material;
						aMeshes[j].mesh.material = mat;
						/*for each(_face in aMeshes[j].mesh.faces)
							_face.material = mat;*/
					}
				}
			}
			
			aSources = null;
			aMats = null;
		}
		
		private function checkDoubleMaterials(url:String):BitmapFileMaterial
		{
			var mat:BitmapFileMaterial;
			for(var i:int = 0;i<aMats.length;++i){
				if(aMats[i].url == url){
					mat = aMats[i].material;
					aMats.push({url:url, material:mat});
					return mat;
				}
			}
			
			mat = new BitmapFileMaterial(url.replace(String.fromCharCode(13),"") );
			aMats.push({url:url, material:mat});
			return mat;
		}
		
		private function generateNewMesh():void
		{
			mesh = new Mesh(ini);
			mesh.name = "obj_"+aMeshes.length;
			mesh.type = ".Obj";
			
			if(aMeshes.length == 1 && container == null)
				container = new ObjectContainer3D(aMeshes[0].mesh);
				
			aMeshes.push({materialid:"", mesh:mesh});

			if(aMeshes.length > 1 || container != null)
				(container as ObjectContainer3D).addChild(mesh);
		}
       
		/**
		 * Creates a new <code>Obj</code> object.
		 * 
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 * 
		 * @see away3d.loaders.Obj#parse()
		 * @see away3d.loaders.Obj#load()
		 */
		public function Obj(init:Object = null)
        {	
			super(init);
			
			mtlPath = ini.getString("mtlPath", "");
			scaling = ini.getNumber("scaling", 1) * 10;
			
			binary = false;
        }

		/**
		 * Creates a 3d mesh object from the raw ascii data of a obj file.
		 * 
		 * @param	data				The ascii data of a loaded file.
		 * @param	init				[optional]	An initialisation object for specifying default instance properties.
		 * 
		 * @return						A 3d mesh object representation of the obj file.
		 */
        public static function parse(data:*, init:Object = null):Object3D
        {
            return Loader3D.parseGeometry(data, Obj, init).handle;
        }
    	
    	/**
    	 * Loads and parses a obj file into a 3d mesh object.
    	 * 
    	 * @param	url					The url location of the file to load.
    	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
    	 * 
    	 * @return						A 3d loader object that can be used as a placeholder in a scene while the file is loading.
    	 */
        public static function load(url:String, init:Object = null):Loader3D
        {
			//mtlPath as model folder
			if (url)
			{
				var _pathArray:Array = url.split("/");
				_pathArray.pop();
				var _mtlPath:String = (_pathArray.length>0)?_pathArray.join("/")+"/":_pathArray.join("/");
				if (init){
					init["mtlPath"] = (init["mtlPath"])?init["mtlPath"]:_mtlPath;
				}else {
					init = { mtlPath:_mtlPath };
				}
			}
            return Loader3D.loadGeometry(url, Obj, init);
        }
    }
}
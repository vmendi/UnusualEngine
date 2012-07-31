﻿package away3d.primitives
{
	import away3d.arcane;
	import away3d.core.base.*;
	import away3d.core.utils.*;
	import away3d.events.*;
	import away3d.materials.*;
	import away3d.primitives.data.*;
    
	use namespace arcane;
	
    /**
    * Creates a 3d Cube primitive.
    */ 
    public class Cube extends AbstractPrimitive
    {	
    	private var _width:Number;
    	private var _height:Number;
    	private var _depth:Number;
		private var _segmentsW:int;
        private var _segmentsH:int;
		private var _flip:Boolean;
    	private var _cubeMaterials:CubeMaterialsData;
    	private var _leftFaces:Array;
    	private var _rightFaces:Array;
    	private var _bottomFaces:Array;
    	private var _topFaces:Array;
    	private var _frontFaces:Array;
    	private var _backFaces:Array;
    	private var _cubeFaceArray:Array;
		private var _map6:Boolean;
		private var _offset:Number = 1/3;
		private var _dbv:Array;
		private var _dbu:Array;
    	
    	private function onCubeMaterialChange(event:MaterialEvent):void
    	{
    		switch (event.extra) {
    			case "left":
    				_cubeFaceArray = _leftFaces;
    				break;
    			case "right":
    				_cubeFaceArray = _rightFaces;
    				break;
    			case "bottom":
    				_cubeFaceArray = _bottomFaces;
    				break;
    			case "top":
    				_cubeFaceArray = _topFaces;
    				break;
    			case "front":
    				_cubeFaceArray = _frontFaces;
    				break;
    			case "back":
    				_cubeFaceArray = _backFaces;
    		}
    		
    		for each (var _cubeFace:Face in _cubeFaceArray)
    			_cubeFace.material = event.material as ITriangleMaterial;
    	}
		
		private function makeVertex(x:Number, y:Number, z:Number):Vertex
		{
			for(var i:int = 0;i<_dbv.length; ++i)
				if( _dbv[i].x == x && _dbv[i].y == y && _dbv[i].z == z)
					return _dbv[i];
				 
			var v:Vertex = createVertex(x, y, z);
			_dbv[_dbv.length] = v;
			
			return v; 
		}
		
		private function makeUV(u:Number, v:Number):UV
		{
			for(var i:int = 0;i<_dbu.length; ++i)
				if( _dbu[i].u == u && _dbu[i].v == v)
					return _dbu[i];
				 
			var uv:UV = createUV(u,v);
			_dbu[_dbu.length] = uv;
			
			return uv; 
		}
			
		private function buildSide(aVs:Array, material:ITriangleMaterial, aFs:Array, side:String):void
		{	
			var uvlength:int = aVs.length-1;
			for(var i:int = 0;i<uvlength;++i)
				generateFaces(aVs[i], aVs[i+1], (1/uvlength)*i, uvlength, material, aFs, side);
		}
		
		private function generateFaces(aPt1:Array, aPt2:Array, vscale:Number, indexv:int, material:ITriangleMaterial, aFs:Array, side:String):void
		{			
			var varr:Array = [];
			var i:int;
			var j:int;
			var stepx:Number;
			var stepy:Number;
			var stepz:Number;
			
			var uva:UV;
			var uvb:UV;
			var uvc:UV;
			var uvd:UV;
			
			var va:Vertex;
			var vb:Vertex;
			var vc:Vertex;
			var vd:Vertex;
			
			var u1:Number;
			var u2:Number;
			var index:int = 0;

			var bu:Number = 0;
			var bincu:Number = 1/(aPt1.length-1);
			var v1:Number = 0;
			var v2:Number = 0;
			 
			for( i = 0; i < aPt1.length; ++i){
				stepx = (aPt2[i].x - aPt1[i].x) / _segmentsH;
				stepy = (aPt2[i].y - aPt1[i].y) / _segmentsH;
				stepz = (aPt2[i].z - aPt1[i].z)  / _segmentsH;
				
				for( j = 0; j < _segmentsH+1; ++j){
					varr.push( makeVertex( aPt1[i].x+(stepx*j) , aPt1[i].y+(stepy*j), aPt1[i].z+(stepz*j)) );
				}
			}
			
			for( i = 0; i < aPt1.length-1; ++i){
				u1 = bu;
				bu += bincu;
				u2 = bu;
				
				if(_map6){
					 switch(side){
						 case "b":
							u1*= _offset;
							u2*= _offset;
						 	break;
						 case "l":
							u1*= _offset;
							u2*= _offset;
						 	break;
						 default:
							u1 = (u1 * _offset) +_offset;
							u2 = (u2 * _offset) +_offset;
					 }
				} 
					
				for( j = 0; j < _segmentsH; ++j){
					
					v1 = vscale+((j/_segmentsH)/indexv);
					v2 =  vscale+(( (j+1)/_segmentsH)/indexv);
					
					if(_map6){
						 switch(side){
							 case "b":
							 	v1*= .5;
								v2*= .5;
							 break;
							 case "l":
							 	v1 = (v1* .5) + .5;
								v2 = (v2* .5) + .5;
							 break;
							 case"t":
							 	v1*= .5;
								v2*= .5;
							 break;
						 }
					}
					
					uva = makeUV( u1 , v1);
					uvb = makeUV( u1 , v2 );
					uvc = makeUV( u2 , v2 );
					uvd = makeUV( u2 , v1 );
					 
					va = varr[index+j];
					vb = varr[(index+j) + 1];
					vc = varr[((index+j) + (_segmentsH + 2))];
					vd = varr[((index+j) + (_segmentsH + 1))];
					 
					if(_flip){
						addFace(createFace(va,vb,vc, material, uva, uvb, uvc ));
						addFace(createFace(va,vc,vd, material, uva, uvc, uvd));
					}else{
						addFace(createFace(vb,va,vc, material, uvb, uva, uvc ));
						addFace(createFace(vc,va,vd, material, uvc, uva, uvd));						
					}
					
					aFs.push(faces[faces.length-2], faces[faces.length-1]);
				}
				
				index += _segmentsH +1;
			}
		}
		
		/**
		 * @inheritDoc
		 */
    	protected override function buildPrimitive():void
    	{
    		super.buildPrimitive();
    		
        	_leftFaces = [];
			_rightFaces = [];
			_bottomFaces = [];
			_topFaces = [];
			_frontFaces = [];
			_backFaces = [];
        	
			var aVs:Array = [];
			var aVds:Array = [];
			var hw:Number = _width*.5;
			var hh:Number = _height*.5;
			var hd:Number = _depth*.5;
			var i:int;
			_dbv = [];
			_dbu = [];
			var v0:Vertex;
			var v1:Vertex;
			var v2:Vertex;
			var uv0:UV;
			var uv1:UV;
			var uv2:UV;
			var face:Face;
			 
			var stepW:Number = _width/_segmentsW;
			 
			for(i = 0;i<=_segmentsW;++i){
				aVs[i] = createVertex(-hw+(i*stepW), hh, -hd);
				aVds[i] = createVertex(-hw+(i*stepW), -hh, -hd);
			}
			
			buildSide([aVds,aVs], _cubeMaterials.back, _backFaces, "b");
			aVds = [];
			aVs = [];
			
			var offU:Number = (_map6)? _offset : 0;
			var offV:Number = (_map6)? .5 : 0;
			
			for(i = 0;i<_backFaces.length;++i){
				face = _backFaces[i];
				v0 = makeVertex(face.v0.x, face.v0.y, -face.v0.z);
				v1 = makeVertex(face.v1.x, face.v1.y, -face.v1.z);
				v2 = makeVertex(face.v2.x, face.v2.y, -face.v2.z);
				uv0 = makeUV(1-(face.uv0.u+offU), face.uv0.v+offV);
				uv1 = makeUV(1-(face.uv1.u+offU), face.uv1.v+offV);
				uv2 = makeUV(1-(face.uv2.u+offU), face.uv2.v+offV);
				addFace(createFace(v1,v0,v2, _cubeMaterials.front, uv1, uv0,  uv2 ));
				_frontFaces.push(faces[faces.length-1]);
			}
			
			stepW = _depth/_segmentsW;
			
			for(i = 0;i<=_segmentsW;++i){
				aVs[i] = makeVertex(hw, hh, -hd+(i*stepW));
				aVds[i] = makeVertex( hw, -hh, -hd+(i*stepW));
			}
			 
			buildSide([aVds,aVs], _cubeMaterials.left, _leftFaces, "l");
			aVs = [];
			aVds = [];
			offU = (_map6)? .5 : 0;
			
			for(i = 0;i<_leftFaces.length;++i){
				face = _leftFaces[i];
				v0 = makeVertex(-face.v0.x, face.v0.y, face.v0.z);
				v1 = makeVertex(-face.v1.x, face.v1.y, face.v1.z);
				v2 = makeVertex(-face.v2.x, face.v2.y, face.v2.z);
				uv0 = makeUV((1-face.uv0.u), face.uv0.v);
				uv1 = makeUV((1-face.uv1.u), face.uv1.v);
				uv2 = makeUV((1-face.uv2.u), face.uv2.v);
				addFace(createFace(v1,v0,v2, _cubeMaterials.right, uv1, uv0,  uv2 ));
				_rightFaces.push(faces[faces.length-1]);
			}
			 
			stepW = (_map6)? _depth/_segmentsW : _width/_segmentsW;
			
			for(i = 0;i<=_segmentsW;++i){
				if(_map6){
					aVs[i] = makeVertex(-hw, hh, hd-(i*stepW));
					aVds[i] = makeVertex(hw, hh, hd-(i*stepW));
				} else{
					aVs[i] = makeVertex(hw-(i*stepW), hh, hd);
					aVds[i] = makeVertex(hw-(i*stepW), hh, -hd);
				}
			}
			buildSide([aVs, aVds], _cubeMaterials.top, _topFaces, "t");
			
			offU = (_map6)? _offset : 0;
			
			for(i = 0;i<_topFaces.length;++i){
				face = _topFaces[i];
				v0 = makeVertex(face.v0.x, -face.v0.y, face.v0.z);
				v1 = makeVertex(face.v1.x, -face.v1.y, face.v1.z);
				v2 = makeVertex(face.v2.x, -face.v2.y, face.v2.z);
				uv0 = makeUV((1-face.uv0.u)+offU, face.uv0.v);
				uv1 = makeUV((1-face.uv1.u)+offU, face.uv1.v);
				uv2 = makeUV((1-face.uv2.u)+offU, face.uv2.v);
				
				addFace(createFace(v1,v0,v2, _cubeMaterials.bottom, uv1, uv0,  uv2 ));
				_bottomFaces.push(faces[faces.length-1]);
			}
			 
			aVs = aVds =_dbv = _dbu = null;
    	}
    	
    	/**
    	 * Defines the width of the cube. Defaults to 100.
    	 */
    	public function get width():Number
    	{
    		return _width;
    	}
    	
    	public function set width(val:Number):void
    	{
    		if (_width == val)
    			return;
    		
    		_width = val;
    		_primitiveDirty = true;
    	}
    	
    	/**
    	 * Defines the height of the cube. Defaults to 100.
    	 */
    	public function get height():Number
    	{
    		return _height;
    	}
    	
    	public function set height(val:Number):void
    	{
    		if (_height == val)
    			return;
    		
    		_height = val;
    		_primitiveDirty = true;
    	}
    	
    	/**
    	 * Defines the depth of the cube. Defaults to 100.
    	 */
    	public function get depth():Number
    	{
    		return _depth;
    	}
    	
    	public function set depth(val:Number):void
    	{
    		if (_depth == val)
    			return;
    		
    		_depth = val;
    		_primitiveDirty = true;
    	}
    	
		/**
    	 * Defines the number of horizontal segments that make up the cube. Defaults 1.
    	 */
    	public function get segmentsW():Number
    	{
    		return _segmentsW;
    	}
    	
    	public function set segmentsW(val:Number):void
    	{
    		if (_segmentsW == val)
    			return;
    		
    		_segmentsW = val;
    		_primitiveDirty = true;
    	}
		
		/**
    	 * Defines if the cube should use a single (3 cols/2 rows) map spreaded over the whole cube.
		 * topleft: left, topcenter:front, topright:right
		 * downleft:back, downcenter:top, downright: bottom
		 * Default is false.
    	 */
    	public function get map6():Boolean
    	{
    		return _map6;
    	}
    	
    	public function set map6(b:Boolean):void
    	{
    		_map6 = b;
    	}
		
		/**
    	 * Defines if the cube faces should be reversed, like a skybox. Default is false.
    	 */
    	public function get flip():Boolean
    	{
    		return _flip;
    	}
    	
    	public function set flip(b:Boolean):void
    	{
    		_flip = b;
    	}
    	
    	/**
    	 * Defines the number of vertical segments that make up the cube. Defaults 1.
    	 */
    	public function get segmentsH():Number
    	{
    		return _segmentsH;
    	}
    	
    	public function set segmentsH(val:Number):void
    	{
    		if (_segmentsH == val)
    			return;
    		
    		_segmentsH = val;
    		_primitiveDirty = true;
    	}
    	/**
    	 * Defines the face materials of the cube.
    	 */
    	public function get cubeMaterials():CubeMaterialsData
    	{
    		return _cubeMaterials;
    	}
    	
    	public function set cubeMaterials(val:CubeMaterialsData):void
    	{
    		if (_cubeMaterials == val)
    			return;
    		
    		if (_cubeMaterials)
    			_cubeMaterials.addOnMaterialChange(onCubeMaterialChange);
    		
    		_cubeMaterials = val;
    		
    		_cubeMaterials.addOnMaterialChange(onCubeMaterialChange);
    	}
		/**
		 * Creates a new <code>Cube</code> object.
		 *
		 * @param	init			[optional]	An initialisation object for specifying default instance properties.
		 * Properties of the init object: width, height, depth, segmentsH, segmentsW, flip, map6, material or faces (as CubeMaterialsData)
		 */
        public function Cube(init:Object = null)
        {
            super(init);
            _width  = ini.getNumber("width",  100, {min:0});
            _height = ini.getNumber("height", 100, {min:0});
            _depth  = ini.getNumber("depth",  100, {min:0});
			_flip = ini.getBoolean("flip", false);
            _cubeMaterials  = ini.getCubeMaterials("faces");
			_segmentsW = ini.getInt("segmentsW", 1, {min:1});
            _segmentsH = ini.getInt("segmentsH", 1, {min:1});
			_map6 = ini.getBoolean("map6", false);
			     
			if (!_cubeMaterials)
				_cubeMaterials  = ini.getCubeMaterials("cubeMaterials");
			
			if (!_cubeMaterials)
				_cubeMaterials = new CubeMaterialsData();
			
			_cubeMaterials.addOnMaterialChange(onCubeMaterialChange);
			
			type = "Cube";
			url = "primitive";
        }
    } 
}
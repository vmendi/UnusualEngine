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
    * Creates a 3d roundedcube primitive.
    */ 
    public class RoundedCube extends AbstractPrimitive
    {	
    	private var _width:Number;
		private var _radius:Number;
		private var _subdivision:int;
    	private var _height:Number;
    	private var _depth:Number;
    	private var _cubeMaterials:CubeMaterialsData;
    	private var _leftFaces:Array;
    	private var _rightFaces:Array;
    	private var _bottomFaces:Array;
    	private var _topFaces:Array;
    	private var _frontFaces:Array;
    	private var _backFaces:Array;
		private var _doubles:Array;
    	private var _cubeFaceArray:Array;
		private var _rad:Number = Math.PI / 180;
		private var _offcubic:Number;
		private var _cubicmapping:Boolean;
		
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
    				break;
    			default:
    		}
    		
			var cubeFace:Face;
    		for each (cubeFace in _cubeFaceArray)
    			cubeFace.material = event.material as ITriangleMaterial;
    	}
		
		private function generate(aVertexes:Array, material:ITriangleMaterial, arrayside:Array, prop:int):void
		{	
			for(var i:int = 0;i<aVertexes.length-1; ++i){
				generateFaces(aVertexes[i], aVertexes[i+1], prop, material, arrayside);
			}
		}
			 
		private function generateFaces(points1:Array, points2:Array,  prop:int,  material:ITriangleMaterial, arrayside:Array):void
		{
			var i:int;
			var uva:UV;
			var uvb:UV;
			var uvc:UV;
			var uvd:UV;
			
			var va:Vertex;
			var vb:Vertex;
			var vc:Vertex;
			var vd:Vertex;
			
			var propu:Number;
			var propv:Number;
			var p1:String;
			var p2:String;
			
			function getDouble(v:Vertex):Vertex
			{
				for(var i:int = 0;i<_doubles.length; ++i){
					if( _doubles[i].x == v.x && _doubles[i].y == v.y && _doubles[i].z == v.z){
						return _doubles[i];
					}
				}
				_doubles[_doubles.length] = v;
				return v; 
			}
			
			switch (prop){
				case 0:
					propu = _depth;
					propv = _height;
					p1 = "z";
					p2 = "y";
					break;
				case 1:
					propu = _width;
					propv = _height;
					p1 = "x";
					p2 = "y";
					break;
				case 2:
					propu = _width;
					propv = _depth;
					p1 = "x";
					p2 = "z";
					break;
			}
			 
			if(!_cubicmapping){
				
				propu -= _offcubic;
				propv -= _offcubic;
			}
			
			var offsetu:Number = (propu * .5);
			var offsetv:Number = (propv * .5);
			 
			for( i = 0; i < points1.length-1; ++i){
				
				va = getDouble(points1[i+1]);
				vb = getDouble(points1[i]);
				vc = getDouble(points2[i]);
				vd = getDouble(points2[i+1]);
				
				if( vb != va && va != vc && vc != vd && vd != va && vc != vb){
					uva = createUV(  (1/(propu/(va[p1]+offsetu))) , 1/(propv/(va[p2]+offsetv)) );
					uvb = createUV(  (1/(propu/(vb[p1]+offsetu))) , 1/(propv/(vb[p2]+offsetv)) );
					uvc = createUV(  (1/(propu/(vc[p1]+offsetu))) , 1/(propv/(vc[p2]+offsetv)) );
					uvd = createUV(  (1/(propu/(vd[p1]+offsetu))) , 1/(propv/(vd[p2]+offsetv)) );
					
					addFace(createFace(vb,va,vc, material, uvb, uva, uvc ));
					addFace(createFace(vc,va,vd, material, uvc, uva, uvd));
					
					arrayside.push(faces[faces.length-2], faces[faces.length-1]);
				}
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
			
			function rotatePoint(v:Vertex, rotation:Number):Vertex
			{
				var x1:Number;
				var roty:Number = rotation * _rad;
				var siny:Number = Math.sin(roty);
				var cosy:Number = Math.cos(roty);
				x1 = v.x;
				v.x = x1*cosy+v.z*siny;
				v.z = x1*-siny+v.z*cosy;
				
				return v;
			}
			 
			_radius = Math.min(_radius, _width, _height, _depth);
			
			if(!_cubicmapping)
				_offcubic = _radius/3.6;
				
			_doubles = [];
			var prof:Array = [];
			var h:Number = _height-_radius;
			var w:Number = _width-_radius;
			var d:Number = _depth-_radius;
			var steph:Number = h/_subdivision;
			var linear:int = _subdivision;
			var pt:Vertex;
			var nRot:Number = 90;
			var even:int = (_subdivision%2 == 0)? 0 : 1;
			var rayon:Number = _radius*.5;
			var halfsub:int = (_subdivision+even)*.5;
			var i:int;
			var j:int;
			var inv:int;
			
			for( i = 0; i<=90;i+=90/(_subdivision+even)){
				pt = createVertex();
				pt.x = Math.cos(-i/180*Math.PI) * rayon;
				pt.y = (Math.sin(i/180*Math.PI) * rayon)+ (h*.5);
				pt.z = 0;
				prof.push(pt);
			}
			
			var tmpy:Number = prof[0].y;
			prof.reverse();
			inv = prof.length;
			
			prof[0].x = prof[0].z = 0;
			
			for(i = 1; i <_subdivision;++i){
				pt = createVertex();
				pt.x = rayon;
				pt.y = tmpy - (i*steph);
				pt.z = 0;
				prof.push(pt);
			}
			 
			var index:int;
			for(i = 0; i <inv;++i){
				index = inv-1-i;
				prof.push( createVertex(prof[index].x, -prof[index].y, prof[index].z) );
			}
			
			var profilecount:int = prof.length;

			var atmp:Array  = [];
			var atmp2:Array = [];
			var atmp3:Array = [];
			var atmp4:Array = [];
			
			var step:Number =  (45/(linear+1))*2;
			var step2:Number = step;
			var cornerdub:Array = [];
			var acol1:Array;
			var acol2:Array;
			var acol3:Array;
			var acol4:Array;
			_subdivision+= even;
			
			for(i =0; i< ((_subdivision)*.5)+1; ++i){
				nRot = 45-( i*step);
				acol1 = [];
				acol2 = [];
				acol3 = [];
				acol4 = [];
				for(j = 0; j<(_subdivision*.5)+1; ++j){
						
					pt = createVertex(prof[j].x, prof[j].y, prof[j].z);
					pt = rotatePoint(pt, nRot);
					pt.x += (_width*.5)-rayon;
					pt.z -= (_depth*.5)-rayon;
					atmp3.push(pt);

					pt = createVertex(pt.x, pt.y, -pt.z);
					acol3.push(pt);
					
					pt = createVertex(prof[j].x, prof[j].y, prof[j].z);
					pt = rotatePoint(pt, nRot);
					pt.x += (_depth*.5)-rayon;
					pt.z -= (_width*.5)-rayon;
					atmp4.push(pt);

					pt = createVertex(pt.x, pt.y, -pt.z);
					acol4.push(pt);
				}

				for(j = (_subdivision*.5); j<profilecount-(_subdivision*.5); ++j){
					 
					pt = createVertex(prof[j].x, prof[j].y, prof[j].z);
					pt = rotatePoint(pt, nRot);
					pt.x+= (_width*.5)-rayon;
					pt.z -= (_depth*.5)-rayon;
					atmp.push(pt);

					pt = createVertex(pt.x, pt.y, -pt.z);
					acol1.push(pt);
					
					pt = createVertex(prof[j].x, prof[j].y, prof[j].z);
					pt = rotatePoint(pt, nRot);
					pt.x += (_depth*.5)-rayon;
					pt.z -= (_width*.5)-rayon;
					atmp2.push(pt);

					pt = createVertex(pt.x, pt.y, -pt.z);
					acol2.push(pt);
					 
				}
				cornerdub.push(acol1, acol2, acol3, acol4);
			}
			
			//middlepart
			for(i =1; i< linear; ++i){
				
				step = (w/linear)*i;
				step2 = (d/linear)*i;
				
				for(j = 0; j<halfsub+1; ++j){
					pt = createVertex(prof[j].x, prof[j].y, prof[j].z);
					pt.x+= (_width*.5)-rayon;
					pt.z -= (_depth*.5)-rayon+ -(step2);
					atmp3.push(pt);
					
					pt = createVertex(prof[j].x, prof[j].y, prof[j].z);
					pt.x+= (_depth*.5)-rayon;
					pt.z -= (_width*.5)-rayon+ -(step) ;
					atmp4.push(pt);
				}
				
				for(j = halfsub; j<profilecount-halfsub; ++j){
					
					pt = createVertex(prof[j].x, prof[j].y, prof[j].z);
					pt.x+= (_width*.5)-rayon;
					pt.z -= (_depth*.5)-rayon+ -(step2);
					atmp.push(pt);
					
					pt = createVertex(prof[j].x, prof[j].y, prof[j].z);
					pt.x+= (_depth*.5)-rayon;
					pt.z -= (_width*.5)-rayon+ -(step) ;
					atmp2.push(pt);
					  
				}
			}
			 
			for(i =cornerdub.length-1; i>=0 ; --i){
				atmp4 = atmp4.concat(cornerdub[i]);
				atmp3 = atmp3.concat(cornerdub[i-1]);
				atmp2 = atmp2.concat(cornerdub[i-2]);
				atmp = atmp.concat(cornerdub[i-3]);
				
				cornerdub[i] = null;
				cornerdub[i-1] = null;
				cornerdub[i-2] = null;
				cornerdub[i-3] = null;
				
				i-= 3;
			}
			
			nRot = 90;
			var face1:Array = [];
			var face2:Array = [];
			var face3:Array = [];
			var face4:Array = [];
			var face5:Array = [];
			var face6:Array = [];
			var topplane:Array = [];
			
			var segs1:Array = [];
			var segs2:Array = [];
			var segs3:Array = [];
			var segs4:Array = [];
			var segs5:Array = [];
			var segs6:Array = [];
			
			j = 0;
			
			for(i = 0; i<atmp3.length;++i){
				segs3.push(atmp3[i]);
				
				pt = createVertex(-atmp3[i].x, atmp3[i].y, atmp3[i].z);
				segs4.push(pt);
				
				pt = createVertex(atmp4[i].x, atmp4[i].y, atmp4[i].z);
				pt = rotatePoint(pt, nRot);
				segs5.push(pt);
				
				pt = createVertex(pt.x, pt.y, -pt.z);
				segs6.push(pt);
				++j;
		
				if(j == (_subdivision*.5)+1) {
					
					face3.push(segs3);
					face4.push(segs4.reverse());
					face5.push(segs5);
					face6.push(segs6.reverse());
					
					j= 0;
					if(i<atmp3.length-1){
						segs3 = [];
						segs4 = [];
						segs5 = [];
						segs6 = [];
					}
				}
			}
			 
			var tmp:Array;
			var stepx:Number;
			var stepz:Number;
			
			var l:int = face4[0].length-1;
			for( i = 0; i < face4.length; ++i){
				stepx = ( face3[i][0].x - face4[i][l].x ) / linear;
				stepz = (face3[i][0].z - face4[i][l].z ) / linear;
				tmp = [];
				for( j =0; j <= linear; ++j){
					tmp.push( createVertex( face4[i][l].x+(stepx*j) , _height *.5, face4[i][l].z+(stepz*j)) );
				}
				topplane.push(tmp);
			}
			 
			
			j = 0;
			for(i = 0; i<atmp.length;++i){
				segs1.push(atmp[i]);
				atmp2[i] = rotatePoint(atmp2[i], nRot);
				segs2.push(atmp2[i]);
				++j;
				if(j == profilecount-_subdivision) {
					face1.push(segs1);
					face2.push(segs2);
					j= 0;
					if(i<atmp.length-1){
						segs1 = [];
						segs2 = [];
					}
				}
			}
			
			generate(face1, (_cubeMaterials.right == null)? faceMaterial : _cubeMaterials.right, _rightFaces, 0);
			generate(face2, (_cubeMaterials.front == null)? faceMaterial : _cubeMaterials.front, _frontFaces, 1);
			var topmat:ITriangleMaterial = (_cubeMaterials.top == null)? faceMaterial : _cubeMaterials.top;
			generate(face3, topmat, _topFaces, 2);
			generate(face4, topmat, _topFaces, 2);
			generate(face5, topmat, _topFaces, 2);
			generate(face6, topmat, _topFaces, 2);
			generate(topplane, topmat, _topFaces, 2);
			
			//star points at corners
			var uva:UV;
			var uvb:UV;
			var uvc:UV;
			 
			var va:Vertex;
			var vb:Vertex;
			var vc:Vertex;
			
			var propu:Number = _width;
			var propv:Number = _depth;
			
			if(!_cubicmapping){
				propu -= _offcubic;
				propv -= _offcubic;
			}
			
			var offsetu:Number = propu * .5;
			var offsetv:Number = propv * .5;
			 
			for(i =0; i< ((_subdivision)*.5); ++i){
				
				for(j = 0; j<2; ++j){
					vb = (j ==0)? face3[0][0] : face5[0][0];
					vc = (j ==0)? face3[i][1] : face5[i][1];
					va = (j ==0)? face3[i+1][1] : face5[i+1][1];
					uva = createUV(  (1/(propu/(va.x+offsetu))) , 1/(propv/(va.z+offsetv)) );
					uvb = createUV(  (1/(propu/(vb.x+offsetu))) , 1/(propv/(vb.z+offsetv)) );
					uvc = createUV(  (1/(propu/(vc.x+offsetu))) , 1/(propv/(vc.z+offsetv)) );
					addFace(createFace(va,vb,vc, topmat, uva, uvb, uvc ));
					_topFaces.push(faces[faces.length-2], faces[faces.length-1]);
					
					vb = createVertex(vb.x, vb.y, -vb.z);
					vc = createVertex(vc.x, vc.y, -vc.z);
					va = createVertex(va.x, va.y, -va.z);
					uva = createUV(  (1/(propu/(va.x+offsetu))) , 1/(propv/(va.z+offsetv)) );
					uvb = createUV(  (1/(propu/(vb.x+offsetu))) , 1/(propv/(vb.z+offsetv)) );
					uvc = createUV(  (1/(propu/(vc.x+offsetu))) , 1/(propv/(vc.z+offsetv)) );
					addFace(createFace(vb,va,vc, topmat, uvb, uva,uvc ));
					_topFaces.push(faces[faces.length-2], faces[faces.length-1]);
					
					vb = createVertex(-vb.x, vb.y, -vb.z);
					vc = createVertex(-vc.x, vc.y, -vc.z);
					va = createVertex(-va.x, va.y, -va.z);
					uva = createUV(  (1/(propu/(va.x+offsetu))) , 1/(propv/(va.z+offsetv)) );
					uvb = createUV(  (1/(propu/(vb.x+offsetu))) , 1/(propv/(vb.z+offsetv)) );
					uvc = createUV(  (1/(propu/(vc.x+offsetu))) , 1/(propv/(vc.z+offsetv)) );
					addFace(createFace(vb,va,vc, topmat, uvb, uva,uvc ));
					_topFaces.push(faces[faces.length-2], faces[faces.length-1]);
					
					vb = createVertex(vb.x, vb.y, -vb.z);
					vc = createVertex(vc.x, vc.y, -vc.z);
					va = createVertex(va.x, va.y, -va.z);
					uva = createUV(  (1/(propu/(va.x+offsetu))) , 1/(propv/(va.z+offsetv)) );
					uvb = createUV(  (1/(propu/(vb.x+offsetu))) , 1/(propv/(vb.z+offsetv)) );
					uvc = createUV(  (1/(propu/(vc.x+offsetu))) , 1/(propv/(vc.z+offsetv)) );
					addFace(createFace(va,vb,vc, topmat, uva, uvb, uvc ));
					_topFaces.push(faces[faces.length-2], faces[faces.length-1]);
				}
				
			}

			var v0:Vertex;
			var v1:Vertex;
			var v2:Vertex;
			var uv0:UV;
			var uv1:UV;
			var uv2:UV;
			var face:Face;
			 
			for(i = 0;i<_rightFaces.length;++i){
				face = _rightFaces[i];
				v0 = createVertex(-face.v0.x, face.v0.y, face.v0.z);
				v1 = createVertex(-face.v1.x, face.v1.y, face.v1.z);
				v2 = createVertex(-face.v2.x, face.v2.y, face.v2.z);
				uv0 = new UV(1-face.uv0.u, face.uv0.v);
				uv1 = new UV(1-face.uv1.u, face.uv1.v);
				uv2 = new UV(1-face.uv2.u, face.uv2.v);
				addFace(createFace(v1,v0,v2, (_cubeMaterials.left == null)? faceMaterial : _cubeMaterials.left, uv1, uv0, uv2 ));
				_leftFaces.push(faces[faces.length-1]);
			}
			
			for(i = 0;i<_frontFaces.length;++i){
				face = _frontFaces[i];
				v0 = createVertex(face.v0.x, face.v0.y, -face.v0.z);
				v1 = createVertex(face.v1.x, face.v1.y, -face.v1.z);
				v2 = createVertex(face.v2.x, face.v2.y, -face.v2.z);
				uv0 = new UV(1-face.uv0.u, face.uv0.v);
				uv1 = new UV(1-face.uv1.u, face.uv1.v);
				uv2 = new UV(1-face.uv2.u, face.uv2.v);
				addFace(createFace(v1,v0,v2, (_cubeMaterials.back == null)? faceMaterial : _cubeMaterials.back, uv1, uv0,  uv2 ));
				_backFaces.push(faces[faces.length-1]);
			}
			
			for(i = 0;i<_topFaces.length;++i){
				face = _topFaces[i];
				v0 = createVertex(face.v0.x, -face.v0.y, face.v0.z);
				v1 = createVertex(face.v1.x, -face.v1.y, face.v1.z);
				v2 = createVertex(face.v2.x, -face.v2.y, face.v2.z);
				uv0 = new UV(1-face.uv0.u, face.uv0.v);
				uv1 = new UV(1-face.uv1.u, face.uv1.v);
				uv2 = new UV(1-face.uv2.u, face.uv2.v);
				addFace(createFace(v1,v0,v2, (_cubeMaterials.bottom == null)? faceMaterial : _cubeMaterials.bottom, uv1, uv0,  uv2 ));
				_bottomFaces.push(faces[faces.length-1]);
			}
			
			_doubles = null;
			face1 = face2 = face3 = face4 = face5 = face6 = topplane = null;
			 _subdivision-= even;
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
    	 * Defines the radius of the corners of the cube. Defaults to 1/3 of the height.
		 * if the radius is found greater than width, height or depth. the radius is set the lowest value of those 3 variables.
    	 */
    	public function get radius():Number
    	{
    		return _radius;
    	}
    	
    	public function set radius(val:Number):void
    	{
    		if (_radius == val)
    			return;
    		
    		_radius = val;
    		_primitiveDirty = true;
    	}
		
		/**
    	 * Defines the geometrical subdivision of the roundedcube. Defaults to 2. Note that corners have an even subdivision to allow 6 materials evently spreaded.
    	 */
    	public function get subdivision():Number
    	{
    		return _subdivision;
    	}
    	
    	public function set subdivision(val:Number):void
    	{
    		if (_subdivision == val)
    			return;
    		
    		_subdivision = val;
    		_primitiveDirty = true;
    	}
		
		/**
    	 * Defines if the textures are projected considering the whole cube or adjusting per sides depending on radius. Default is false.
    	 */
    	public function get cubicmapping():Boolean
    	{
    		return _cubicmapping;
    	}
    	
    	public function set cubicmapping(b:Boolean):void
    	{
    		_cubicmapping = b;
    		 
    	}
    	
    	/**
    	 * Defines the face materials of the cube. For single material, use 
    	 */
    	public function get cubeMaterials():CubeMaterialsData
    	{
    		return _cubeMaterials;
    	}
    	
    	public function set cubeMaterials(val:CubeMaterialsData):void
    	{
    		if (_cubeMaterials == val)
    			return;
			
            _cubeMaterials = val;
            	
            if (!_cubeMaterials)
            	_cubeMaterials = new CubeMaterialsData();
    		
    		if (_cubeMaterials)
    			_cubeMaterials.addOnMaterialChange(onCubeMaterialChange);
    		
    		_cubeMaterials.addOnMaterialChange(onCubeMaterialChange);
    	}
		/**
		 * Creates a new <code>RoundedCube</code> object.
		 *
		 * @param	init			[optional]	An initialisation object for specifying default instance properties.
		 *  Properties are: width, height, depth, radius, subdivision, cubicmapping, material and faces(6 different materials as cubeMaterials object) ;
		 */
        public function RoundedCube(init:Object = null)
        {

          
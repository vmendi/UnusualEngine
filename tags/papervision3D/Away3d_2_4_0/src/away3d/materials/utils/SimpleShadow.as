﻿package away3d.materials.utils
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.filters.BlurFilter;
	
	import away3d.core.base.Vertex;
	import away3d.core.base.Object3D;
	import away3d.core.base.Mesh;
	import away3d.core.math.Number3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.primitives.Plane;
	import away3d.materials.BitmapMaterial;
	import away3d.containers.Scene3D;
	
	/**
	* This class generates a top projection shadow from vertex information of a given Object3D,
	* Most suitable for still objects. Can be updated at runtime but will offer very poor performance.
	*/
	public class SimpleShadow
	{
		private var _graphic:Graphics;
		private var _color:uint;		
		private var _alpha:Number;
		private var _distalpha:Number;
		private var _blur:Number;
		private var _object3d:Object3D;
		private var _shadesprite:Sprite;
		private var _shadebmd:BitmapData;
		private var _offsetx:Number;
		private var _offsety:Number;
		private var _scaleX:Number =  1;
		private var _scaleY:Number =  1;
		private var _range:Number;
		private var _base:Number;
		private var _rad:Number = Math.PI / 180;
		private var _plane:Plane;
		private var _scene:Scene3D;
		private var _width:Number = 0;
		private var _height:Number = 0;
		
		 
		private function parse(childObj:Object3D = null):BitmapData
		{
			var myObj:Object3D = (childObj == null)? _object3d : childObj;
			
			if(myObj is ObjectContainer3D){
					
					var obj:ObjectContainer3D = (myObj as ObjectContainer3D);
					
					for(var i:int =0;i<obj.children.length; ++i){
						if(obj.children[i] is ObjectContainer3D){
							parse(obj.children[i]);
						} else if(obj.children[i] is Mesh){
							drawObject(obj.children[i], obj.children[i].scenePosition.x, -obj.children[i].scenePosition.z);
						}
					}
					
			} else {
				
				drawObject();
			}
			
			 
			_shadebmd.draw( _shadesprite);
			 
			return _shadebmd;
			
		}
		
		private function drawObject(childObj:Mesh = null, offX:Number = 0, offZ:Number = 0 ):void
		{ 
			var myObj:Mesh = (childObj == null)? _object3d as Mesh : childObj;
			
			if(!_range){
				_distalpha = _alpha;
			} else {
				var dist:Number = (myObj.scenePosition.y - Math.abs(myObj.minY)) - _base;
				 
				if(dist> _range) return;
				 
				_distalpha = 1-(dist/_range);

			}
			
			 
			if(myObj.rotationX ==0 && myObj.rotationY ==0 && myObj.rotationZ ==0){
				 
				var v0:Vertex;
				var v1:Vertex;
				var v2:Vertex;
				
				for(var i:int;i<myObj.faces.length;++i){
					
					v0 = myObj.faces[i].v0;
					v1 = myObj.faces[i].v1;
					v2 = myObj.faces[i].v2;
					 
					drawTri(v0.x+offX, -(v0.z-offZ), v1.x+offX, -(v1.z-offZ), v2.x+offX, -(v2.z-offZ)); 
				}
				
			} else {
				 
				applyRotations(myObj, offX, offZ);
				
			}
			 
		}
		
		private function generatePlane(scene:Scene3D):void
		{
			var w:int = (_width <= 200)? 4 : 4 + Math.round((_width/ (100%_width)*.5));
			var h:int = (_height <= 200)? 4 : 4 + Math.round((_height/ (100%_height)*.5));
			
			if(_plane != null){
				scene.removeChild(_plane);
				_plane = null;
			}
			
			var mat:BitmapMaterial = new BitmapMaterial(_shadebmd, {smooth:false, debug:false});
			_plane = new Plane({material:mat, segmentsH:h,segmentsW:w, width:_width*_scaleX, height:_height*_scaleY, bothsides:true});
			scene.addChild(_plane);
			
			positionPlane();
		}
		
		private function applyRotations(myObj:Mesh, offX:Number = 0, offZ:Number = 0 ):void
		{
			var x:Number;
			var y:Number;
			var z:Number;
			var x1:Number;
			var y1:Number;
			
			var rotx:Number = myObj.rotationX * _rad;
			var roty:Number = myObj.rotationY * _rad;
			var rotz:Number = myObj.rotationZ * _rad;
			var sinx:Number = Math.sin(rotx);
			var cosx:Number = Math.cos(rotx);
			var siny:Number = Math.sin(roty);
			var cosy:Number = Math.cos(roty);
			var sinz:Number = Math.sin(rotz);
			var cosz:Number = Math.cos(rotz);
			
			var v0:Vertex;
			var v1:Vertex;
			var v2:Vertex;
			
			var n0:Number3D = new Number3D();
			var n1:Number3D = new Number3D();
			var n2:Number3D = new Number3D();
			
			var trifaces:Array = [];
			 
			var j:int;
			for(var i:int;i<myObj.faces.length;++i){
					
				v0 = myObj.faces[i].v0;
				v1 = myObj.faces[i].v1;
				v2 = myObj.faces[i].v2;
				
				n0.x = v0.x;
				n0.y = v0.y;
				n0.z = v0.z;
				
				n1.x = v1.x;
				n1.y = v1.y;
				n1.z = v1.z;
				
				n2.x = v2.x;
				n2.y = v2.y;
				n2.z = v2.z;
				
				trifaces[0] = n0;
				trifaces[1] = n1;
				trifaces[2] = n2;
				
				for(j= 0;j<trifaces.length;++j){
				 
					x = trifaces[j].x;
					y = trifaces[j].y;
					z = trifaces[j].z;
	
					y1 = y;
					y = y1*cosx+z*-sinx;
					z = y1*sinx+z*cosx;
					
					x1 = x;
					x = x1*cosy+z*siny;
					z = x1*-siny+z*cosy;
				
					x1 = x;
					x = x1*cosz+y*-sinz;
					y = x1*sinz+y*cosz;
					
					trifaces[j].x = x;
					trifaces[j].y = y;
					trifaces[j].z = z;
					
				}
				
				drawTri(trifaces[0].x+offX, -(trifaces[0].z-offZ), trifaces[1].x+offX, -(trifaces[1].z-offZ), trifaces[2].x+offX, -(trifaces[2].z-offZ));
			}

		}
		
		private function check32(color:uint):Number
		{
			_color = color;
			if((_color >> 24 & 0xFF) == 0) {
				addAlpha();
			}
			
			return (_color >> 24 & 0xFF)/255;
		}
		
		private function addAlpha():void
		{
			_color = 255 << 24 | _color;
		}
		
		private function drawTri(x1:Number,y1:Number,x2:Number,y2:Number,x3:Number,y3:Number):void
		{
			_graphic.beginFill(_color, _distalpha );
			_graphic.moveTo((x1+_offsetx)/_scaleX, (y1+_offsety)/_scaleY);
			_graphic.lineTo((x2+_offsetx)/_scaleX, (y2+_offsety)/_scaleY );
			_graphic.lineTo((x3+_offsetx)/_scaleX, (y3+_offsety)/_scaleY );
			_graphic.lineTo((x1+_offsetx)/_scaleX, (y1+_offsety)/_scaleY);
		}
		
		private function buildSource():void
		{
			if(_width > 2790){
				_scaleX = _width/2790;
				_width /= _scaleX;
			}
			 
			if(_height > 2790){
				_scaleY = _height/2790;
				_height /= _scaleY;
			}
			
			if(_shadebmd != null){
				
				if(_shadebmd.width != _width || _shadebmd.height != _height){
					_shadebmd.dispose();
					_shadebmd = new BitmapData(_width, _height, true, 0x00FFFFFF);
				} else{
					_shadebmd.fillRect(_shadebmd.rect, 0x00FFFFFF);
				}
				
			} else {
				_shadebmd = new BitmapData(_width, _height, true, 0x00FFFFFF);
			}
			 
		}
		
		private function updateSizes():void
		{
			if(_object3d is Mesh){
			_width =  (_object3d as Mesh).objectWidth +(_blur*2);
			_height = (_object3d as Mesh).objectDepth+(_blur*2);
			_offsetx =  Math.abs((_object3d as Mesh).minX)+_blur;
			_offsety =  Math.abs((_object3d as Mesh).maxZ)+_blur;
			
			} else if(_object3d is ObjectContainer3D){
				_width = 0;
				_height = 0;
				getSizesChildren(_object3d);
				_width += _blur*2;
				_height += _blur*2;
				_offsetx = (_width*.5)+_blur;
				_offsety = (_height*.5)+_blur;
			}
		}
		
		private function getSizesChildren(childObj:Object3D):void
		{
			var myObj:Object3D = (childObj == null)? _object3d : childObj;
			if(myObj is ObjectContainer3D){
					var obj:ObjectContainer3D = (myObj as ObjectContainer3D);
					for(var i:int =0;i<obj.children.length; ++i){
						if(obj.children[i] is ObjectContainer3D){
							getSizesChildren(obj.children[i]);
						} else if(obj.children[i] is Mesh){
							_width = Math.max(_width, obj.children[i].objectWidth);
							_height = Math.max(_height, obj.children[i].objectDepth);
						}
					}
			} else {
				_width = Math.max(_width, obj.children[i].objectWidth);
				_height = Math.max(_height, obj.children[i].objectDepth);
			}
		}
		 
		/**
		* Creates a new <code>SimpleShadow</code> object.
		* 
		* this class generate a projected shadow. Not suitable if shadows need to be updated at runtime in scenes with lots of polygons. 
		* 
		* @param	object3d				Object3D: The object3d that will generate the shadow. Nested object3ds in ObjectContainer3Ds are also supported.
		* @param	color 	[optional]	uint: The color for the shadow.  Note that the value must have alpha. Default value is 0xFF333333.
		* @param	blur 		[optional]	Number: The blur value that defines the sharpness of the shadow. Default value is 4.
		* @param	base 		[optional]	Number: The y value the shadow must be calculated from. Default value is the lowest y value of the object3d in the scene.
		* @param	range	[optional]	Number: The range value affects the blur and alpha according to distance. Default value is undefined.
		*/
		
		function SimpleShadow(object3d:Object3D, color:uint = 0xFF666666, blur:Number = 4, base:Number = NaN, range:Number = NaN)
		{
			_object3d = object3d;
			_object3d.applyPosition((_object3d.minX+_object3d.maxX)*.5, 0, (_object3d.minZ+_object3d.maxZ)*.5);
			
			
			_blur = (blur <0 )? 0 : blur;
			_range = (range <0 )? 0 : range;
			_base = (isNaN(base))?  object3d.y - Math.abs(object3d.minY) : base;
			
			_shadesprite = new Sprite();
			_graphic = _shadesprite.graphics;
			_graphic.beginFill(0x00FFFFFF,1);
	
			updateSizes();
			 
			_graphic.drawRect(0,0, _width, _height);
			_graphic.endFill();
			
			if(_blur > 0)
				_shadesprite.filters = [new BlurFilter(_blur, _blur)];
				
			buildSource();
			
			this.color = color;
			 
		}
		 
		/**
		* return the generated shadow projection BitmapData;
		* 
		* @return A BitmapData: the generated shadow projection bitmapdata;
		*/
		public function get source():BitmapData
		{ 
			return _shadebmd;
		}
		/**
		* return the plane where the shadow is set as Material
		* 
		* @return A Plane: the plane where the shadow is set as Material
		*/
		public function get plane():Plane
		{ 
			return _plane;
		}
		
		/**
		* return the color set for the shadow generation
		* 
		* @return the color set for the shadow generation
		*/
		public function get color():uint
		{ 
			return _color;
		}
		
		public function set color(val:uint):void
		{ 
			_alpha = check32(val);
		}

		/**
		* generates the shadow projection
		* 
		*/
		public function apply(scene:Scene3D = null):BitmapData
		{ 
			_graphic.clear();
			_shadebmd.fillRect(_shadebmd.rect, 0x00FFFFFF);

			if(_plane == null && (scene != null || _scene != null) ){
				_scene = scene;
				generatePlane(_scene);
			}
			 
			return parse();
		}
		
		/**
		* generates the shadow projection
		* 
		*/
		public function update(color:Number = NaN):void
		{ 
			_graphic.clear();
	
			updateSizes();
			 
			_graphic.drawRect(0,0, _width, _height);
			_graphic.endFill();
			
			if(_blur > 0 && _shadesprite.filters.length == 0)
				_shadesprite.filters = [new BlurFilter(_blur, _blur)];
				
			if(_blur == 0 && _shadesprite.filters.length > 0)
				_shadesprite.filters = [];
			
			buildSource();
			
			if(!isNaN(color))
				this.color = color;
				
			generatePlane(_scene);
			
			parse();
		}
		
		/**
		* adjusts the shadow position to the model according to pivot of the object
		* 
		*/ 
		public function positionPlane():void
		{
			_plane.y = _base;
			_plane.x = _object3d.x;
			_plane.z = _object3d.z;
		}
		
		/**
		* Defines the object3d that will be used for the projection
		* Note that the update method is automaticaly called when set. The handler is only to be used if the previous class object3d was nulled.
		*/ 
		public function set object(object3d:Object3D):void
		{
			_object3d = object3d;
			_object3d.applyPosition((_object3d.minX+_object3d.maxX)*.5, 0, (_object3d.minZ+_object3d.maxZ)*.5);
			update();
		}
		
		/**
		* Defines the amount of blur for the projection
		* @param	val  Blur value
		*/ 
		public function set blur(val:int):void
		{
			_blur = (val <0 )? 0 : val;
		}
		public function get blur():int
		{
			return _blur;
		}
		
		/**
		* Defines the range for the projection, the greater, the more alpha. when distance vertice to projection base is exceeded, no trace occurs.
		* @param	val  Range value
		*/ 
		public function set range(val:Number):void
		{
			_range = (val <0 )? 0 : val;
		}
		public function get range():Number
		{
			return _range;
		}
		
		/**
		* Defines the base for the projection. It defines the y position of the plane object
		* By default the plane is located at the base of the object
		* @param	val  Base value
		*/ 
		public function set base(val:Number):void
		{
			_base = (isNaN(base))?  _object3d.y - Math.abs(_object3d.minY) : val;
		}
		public function get base():Number
		{
			return _base;
		}
		 
	}
}
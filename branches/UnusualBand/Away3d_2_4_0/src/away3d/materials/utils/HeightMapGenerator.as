﻿package away3d.materials.utils
{
   	import flash.display.BitmapData;
	import flash.filters.BlurFilter;
	import flash.filters.ConvolutionFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import away3d.core.math.Number3D;
	import away3d.core.base.*;
	import away3d.containers.ObjectContainer3D;
	import away3d.arcane;
	import away3d.events.TraceEvent;
	import away3d.materials.utils.data.Grow;
	 
	use namespace arcane;
	
	/**
	* Class HeightMapGenerator generates a heightmap from a given Object3D. Ideal for surface tracking or collision detection purposes.<HeightMapGenerator></code>
	* 
	*/
	
	/**
	 * Dispatched while the class is busy tracing. Note that the source can already be used for a Material
	 * 
	 * @eventType away3d.events.TraceEvent
	 */
	[Event(name="tracecomplete",type="away3d.events.TraceEvent")]
    
	/**
	 * Dispatched full trace is done.
	 * 
	 * @eventType away3d.events.TraceEvent
	 */
	[Event(name="traceprogress",type="away3d.events.TraceEvent")]
	  
	public class HeightMapGenerator extends EventDispatcher{
		
		private var _width:int;
		private var _height:int;
		private var _heightmap:BitmapData;
		private var _object3d:Object3D;
		private var _lines:Array;
		private var _growpixels:Boolean;
		private var _blur:int = 0;
		private var _state:int = 0;
		private var _step:int = 50;
		private var _intPt0:Point = new Point();
		private var _intPt1:Point = new Point();
		private var _intPt2:Point = new Point();
		private var _rect:Rectangle = new Rectangle(0,0,1,1);
		private var _useVertex:Boolean;
		private var _minX:Number;
		private var _minY:Number;
		private var _minZ:Number;
		private var _offsetX:Number;
		private var _offsetY:Number;
		private var _offsetZ:Number;
		private var _offwidth:Number;
		private var _offdepth:Number;
		private var _offheight:Number;
		private var _faces:Array;
		private var _tmpvertices:Array;
		private var _isContainer:Boolean;
		 
		private function generate(from:int, to:int):void
		{
			var i:int;
			var j:int;
			
			var p0:Point;
			var p1:Point;
			var p2:Point;
			 
			var col0:int;
			var col1:int;
			var col2:int;
			
			var line0:Array;
			var line1:Array;
			var line2:Array;
			
			var per0:Number;
			var per1:Number;
			var per2:Number;
			
			var face:Face;
			var row:int;
			var s:int;
			var e:int;
						 
			var colorpt:Point = new Point();
			
			function meet(pt:Point, x1:int,  y1:int, x2:int, y2:int, x3:int, y3:int, x4:int, y4:int):Point
			{ 
				var d:int = (x1-x2)*(y3-y4) - (y1-y2)*(x3-x4);
				if (d == 0)  return null;
				
				pt.x = ((x3-x4)*(x1*y2-y1*x2)-(x1-x2)*(x3*y4-y3*x4))/d;
				pt.y = ((y3-y4)*(x1*y2-y1*x2)-(y1-y2)*(x3*y4-y3*x4))/d;
				
				return pt;
			} 
			
			function applyColorAt(x:int, y:int):void
			{
				if(_heightmap.getPixel(x, y) == 0){
					colorpt.x = x;
					colorpt.y = y;
					 
					var cross0:Point = meet(_intPt0, line1[0].x,line1[0].y, line1[1].x, line1[1].y, p0.x, p0.y, x, y);
					var cross1:Point = meet(_intPt1, line2[0].x,line2[0].y, line2[1].x, line2[1].y, p1.x, p1.y, x, y);
					var cross2:Point = meet(_intPt2, line0[0].x,line0[0].y, line0[1].x, line0[1].y, p2.x, p2.y, x, y);
					 
					per0 = (cross0 == null)? 1 : Point.distance(cross0, colorpt) / Point.distance(p0, cross0 ) ; 
					per1 = (cross1 == null)? 1 : Point.distance(cross1, colorpt) / Point.distance(p1, cross1 ) ;
					per2 = (cross2 == null)? 1 : Point.distance(cross2, colorpt) / Point.distance(p2, cross2 ) ;
					 
					var col:int =  (per0*col0) + (per1*col1) + (per2*col2);
					col = (col>255)? 255 : col;
					_heightmap.setPixel(x, y,	col << 16 );
					 
				}
			}
			 
			_heightmap.lock();
			
			for(i = from;i<to;++i){
				
				face = _faces[i];
				
				if(_useVertex){
					p0 = new Point( ((face.v0.x+_offsetX)/_offwidth)* _width,  (1 - ((face.v0.z+_offsetZ)/_offdepth)) * _height);
					p1 = new Point( ((face.v1.x+_offsetX)/_offwidth)* _width,  (1 - ((face.v1.z+_offsetZ)/_offdepth)) * _height);
					p2 = new Point( ((face.v2.x+_offsetX)/_offwidth)* _width,  (1 - ((face.v2.z+_offsetZ)/_offdepth)) * _height);
					
				} else{
					p0 = new Point( face.uv0.u * _width,  (1 - face.uv0.v) * _height);
					p1 = new Point( face.uv1.u * _width ,  (1 - face.uv1.v) * _height);
					p2 = new Point( face.uv2.u * _width , (1 - face.uv2.v) * _height);
				}
				
				col0 = 255 *((face.v0.y+_offsetY)/_offheight);
				col1 = 255 *((face.v1.y+_offsetY)/_offheight);
				col2 = 255 *((face.v2.y+_offsetY)/_offheight);
				
				 _lines = [];
				
				setBounds(p0.x, p0.y, p1.x, p1.y, col0, col1, Point.distance(p0, p1));
				setBounds(p1.x, p1.y, p2.x, p2.y, col1, col2, Point.distance(p1, p2));
				setBounds(p2.x, p2.y, p0.x, p0.y, col2, col0, Point.distance(p2, p0));
				 
				line0 = [p0, p1];
			 	line1 = [p1, p2];
				line2 = [p2, p0];
				 
				_lines.sortOn("y", 16);
				
				row = 0;
				_rect.x = _lines[0].x;
				_rect.y = _lines[0].y;
				_rect.width = 1;
				
				for(j = 0;j < _lines.length; ++j)
				{
					if(row == _lines[j].y ){
						if(s > _lines[j].x){
							s = _lines[j].x;
							_rect.x = s;
						} 
						if(e < _lines[j].x){
							e = _lines[j].x;
						}
						_rect.width = e-s;
						 
					} else{
						for(var k:int = _rect.x;k<_rect.x+_rect.width;++k){
							applyColorAt(k, _rect.y);
						}
						s = _lines[j].x;
						e = _lines[j].x;
						row = _lines[j].y;
						_rect.x = _lines[j].x;
						_rect.y = _lines[j].y;
						_rect.width =1;
					}
				}
			}
			
			_heightmap.unlock();
			_state = i;
			
			var te:TraceEvent;
			if(_state >= _faces.length){
				
				if(_growpixels)
					grow();
					
				if(_blur != 0)
					applyBlur(_heightmap);
				 
				_lines = null;
				
				if(hasEventListener(TraceEvent.TRACE_COMPLETE)){
					te = new TraceEvent(TraceEvent.TRACE_COMPLETE);
					te.percent = 100;
					dispatchEvent(te);
				}
				
				_rect = null;
				_faces = null;
				_tmpvertices = [];
				
			} else{
				
				if(hasEventListener(TraceEvent.TRACE_PROGRESS)){
					te = new TraceEvent(TraceEvent.TRACE_PROGRESS);
					te.percent = (_state / _faces.length) *100;
					dispatchEvent(te);
				}
				
				setTimeout(generate, 1, _state, (_state+_step>_faces.length )? _faces.length : _state+_step);
			}
			
		}
		
		private function applyBlur(map:BitmapData):void
		{
				var bf:BlurFilter = new BlurFilter(_blur, _blur);
				var pt:Point = new Point(0,0);
				map.applyFilter(map, map.rect, pt ,bf);
				bf = null;
				pt = null;
		}
		 
		
		private function setBounds(x1:int,y1:int,x2:int,y2:int, c0:Number, c1:Number, dist:Number):void
		{
			var line:Array = [x1, y1];
			var dist2:Number;
			var scale:Number;
			
			var col:Number;
			
			var o:Object;
			o = {x:x1, y:y1, col: c0 << 16| 0 << 8| 0};
			_lines[_lines.length] = o;
			o = {x:x2, y:y2, col: c1 << 16| 0 << 8| 0};
			_lines[_lines.length] = o;
			var error:int;
			var dx:int;
			var dy:int;
			if (x1 > x2) {
				var tmp:int = x1;
				x1 = x2;
				x2 = tmp;
				tmp = y1;
				y1 = y2;
				y2 = tmp;
			}
			dx = x2 - x1;
			dy = y2 - y1;
			var yi:int = 1;
			if (dx < dy) {
				x1 ^= x2;
				x2 ^= x1;
				x1 ^= x2;
				y1 ^= y2;
				y2 ^= y1;
				y1 ^= y2;
			}
			if (dy < 0) {
				dy = -dy;
				yi = -yi;
			}
			if (dy > dx) {
				error = -(dy >> 1);
				for (; y2 < y1; ++y2) {
					dist2 = Math.sqrt((x2 - line[0]) * (x2 - line[0]) + (y2 - line[1]) * (y2 - line[1]));
					scale = dist2/dist;
					col =  (c1*scale)+(c0*(1-scale));
					o = {x:x2, y:y2, col: col << 16| 0 << 8| 0};
					_lines[_lines.length] = o;
					error += dx;
					if (error > 0) {
						x2 += yi;
						dist2 = Math.sqrt((x2 - line[0]) * (x2 - line[0]) + (y2 - line[1]) * (y2 - line[1]));
						scale = dist2/dist;
						col =  (c1*scale)+(c0*(1-scale));
						o = {x:x2, y:y2, col: col << 16| 0 << 8| 0};
						_lines[_lines.length] = o;
						error -= dy;
					}
				}
			} else {
				error = -(dx >> 1);
				for (; x1 < x2; ++x1) {
					dist2 = Math.sqrt((x1 - line[0]) * (x1 - line[0]) + (y1 - line[1]) * (y1 - line[1]));
					scale = dist2/dist;
					col =  (c1*scale)+(c0*(1-scale));
					o = {x:x1, y:y1, col: col << 16| 0 << 8| 0};
					_lines[_lines.length] = o;
					error += dy;
					if (error > 0) {
						y1 += yi;
						dist2 = Math.sqrt((x1 - line[0]) * (x1 - line[0]) + (y1 - line[1]) * (y1 - line[1]));
						scale = dist2/dist;
						col =  (c1*scale)+(c0*(1-scale));
						o = {x:x1, y:y1, col: col << 16| 0 << 8| 0};
						_lines[_lines.length] = o;
						error -= dx;
					}
				}
			}
		}
		
		private function grow():void
		{
			_heightmap = Grow.apply(_heightmap, 10);
		}
		
		private function meshInfo(object3d:Object3D):void
		{
			if(object3d as ObjectContainer3D){
				var obj:ObjectContainer3D = (object3d as ObjectContainer3D);
				
				for(var i:int =0;i<obj.children.length;++i){
					 
					if(obj.children[i] is ObjectContainer3D){
						meshInfo(obj.children[i]);
					} else{
						parseMesh(obj.children[i] as Mesh);
						_faces = _faces.concat((obj.children[i] as Mesh).faces);
						_tmpvertices = _tmpvertices.concat((obj.children[i] as Mesh).vertices);
					}
				}
				
			}else{
				parseMesh(object3d as Mesh);
				_faces = _faces.concat((object3d as Mesh).faces);
				_tmpvertices = _tmpvertices.concat((object3d as Mesh).vertices);
			}
			 
		}
		
		private function sortFaces():void
		{
			
			var tempfaces:Array = [];
			_tmpvertices.sortOn("y", 16);
			
			var i:int;
			var j:int;
			var innerloop:int = _faces.length;
			var reffaces:Dictionary = new Dictionary();
			
			var rememberFace:Function = function(face:Face):void
            {
				if (reffaces[face] == null){
					reffaces[face] = tempfaces.length;
					tempfaces.push(face);
				}
			};
			
			for (i = 0 ;i<_tmpvertices.length;++i){
				for(j = 0;j<innerloop;++j){
					if(_faces[j].v0 == _tmpvertices[i] || _faces[j].v1 == _tmpvertices[i] || _faces[j].v2 == _tmpvertices[i]){
						rememberFace(_faces[j]);
					}
				}
			}
			_faces = [];
			_faces = _faces.concat(tempfaces);
		}
		
		private function parseMesh(mesh:Mesh):void
		{
			var maxY:Number = -Infinity;
			var offposix:Number = (_isContainer)? mesh.scenePosition.x : 0;
			if(_useVertex){
				var offposiy:Number = (_isContainer)? mesh.scenePosition.y : 0;
				var offposiz:Number = (_isContainer)? mesh.scenePosition.z : 0;
				var maxX:Number = -Infinity;
				var maxZ:Number = -Infinity;
			}
				
			for(var i:int = 0;i<mesh.vertices.length;++i){
				_minY = Math.min(mesh.vertices[i].y+offposiy, _minY);
				maxY = Math.max(mesh.vertices[i].y+offposiy, maxY);
				if(_useVertex){
					_minX = Math.min(mesh.vertices[i].x+offposix, _minX);
					maxX = Math.max(mesh.vertices[i].x+offposix, maxX);
					_minZ = Math.min(mesh.vertices[i].z+offposiz, _minZ);
					maxZ = Math.max(mesh.vertices[i].z+offposiz, maxZ);
				}
			}
			_offsetY = Math.abs(_minY);
			_offheight = maxY-_minY;
			if(_useVertex){
				_offsetX = Math.abs(_minX);
				_offwidth = maxX-_minX;
				_offsetZ = Math.abs(_minZ);
				_offdepth = maxZ-_minZ;
			}
			 
		}
		/**
		* Class HeightMapGenerator generates a heightmap from a given Object3D.
		*
		* @param	object3d				Object3D. The Object3D to be traced. Can be of type Mesh or type ObjectContainer3D. 
		* @param	width						[optional] int. The width of the generated heightmap. Default is 512.
		* @param	useVertex				[optional] Boolean. The heightmap respects the uv or the vertexes of the mesh. Default is true.
		* @param	growpixels				[optional] Boolean. To avoid some artefacts cause by the pixel trace. adds pixels at the edges of the trace.
		* @param	blur						[optional] int. Blur value if applyed, the surface of the object becomes smoother. Default is 0;
		* @param	growpixels				[optional] Boolean. To avoid some artefacts cause by the pixel trace. adds pixels at the edges of the trace. Default is false.
		* @param	maxfaces				[optional] int. To avoid that the player generates a timout error, the class handles the trace of faces stepwize. Default is 50 faces.
		*/
		public function HeightMapGenerator(object3d:Object3D, width:int = 512, height:int = 512, useVertex:Boolean = true, blur:int = 0, growpixels:Boolean = false, maxfaces:int = 50)
        {
			_object3d = object3d;
			_width = width;
			_height = height;
			_state = 0;
			_growpixels = growpixels;
			_useVertex = useVertex;
			_step = maxfaces * (1-(1/(2800/Math.max(_width, _height))));
			_blur = blur;
			_heightmap = new BitmapData(_width, _height, false, 0x000000);
			
			_minX = Infinity;
			_minY = Infinity;
			_minZ = Infinity;
			_tmpvertices = [];
			_faces = [];
			_isContainer = object3d is ObjectContainer3D;
			meshInfo(object3d);
			sortFaces();
			generate(0, (_step > _faces.length)? _faces.length : _step);
			
		}
		
		 /**
		* Returns the heightmap generated by the class
		*
		* @return	heightmap		BitmapData. the heightmap generated by the class
		*/
		public function get heightmap():BitmapData
		{
			return _heightmap;
		}
		
		/**
		 * Default method for adding a traceprogress event listener
		 * 
		 * @param	listener		The listener function
		 */
		public function addOnTraceProgress(listener:Function):void
        {
			addEventListener(TraceEvent.TRACE_PROGRESS, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a traceprogress event listener
		 * 
		 * @param	listener		The listener function
		 */
		public function removeOnTraceProgress(listener:Function):void
        {
            removeEventListener(TraceEvent.TRACE_PROGRESS, listener, false);
        }
		/**
		 * Default method for adding a tracecomplete event listener
		 * 
		 * @param	listener		The listener function
		 */
		public function addOnTraceComplete(listener:Function):void
        {
			addEventListener(TraceEvent.TRACE_COMPLETE, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a tracecomplete event listener
		 * 
		 * @param	listener		The listener function
		 */
		public function removeOnTraceComplete(listener:Function):void
        {
            removeEventListener(TraceEvent.TRACE_COMPLETE, listener, false);
        }
		
	}
}
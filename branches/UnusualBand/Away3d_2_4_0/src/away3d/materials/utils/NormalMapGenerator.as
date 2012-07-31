﻿package away3d.materials.utils
{
   	import flash.display.BitmapData;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.utils.setTimeout;
	import flash.events.EventDispatcher;
	
	import away3d.core.math.Number3D;
	import away3d.materials.utils.data.Grow;
	import away3d.core.base.*;
	import away3d.arcane;
	import away3d.events.TraceEvent;
	import away3d.materials.utils.data.LScan;
	 
	use namespace arcane;
	
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
	  
	public class NormalMapGenerator extends EventDispatcher{
		
		private var _width:int;
		private var _height:int;
		private var _type:int;
		private var _normalmap:BitmapData;
		private var _bumpsource:BitmapData;
		private var _maxfaces:int;
		private var _mesh:Mesh;
		private var _lines:Array;
		private var _bumpmap:BitmapData;
		private var _growpixels:Boolean;
		private var _blur:int = 0;
		private var _state:int = 0;
		private var _step:int = 50;
		private var n0:Number3D = new Number3D();
		private var n1:Number3D = new Number3D();
		private var n2:Number3D = new Number3D();
		private var intPt0:Point = new Point();
		private var intPt1:Point = new Point();
		private var intPt2:Point = new Point();
		private var rect:Rectangle = new Rectangle(0,0,1,1);
		private var _canceled:Boolean;
		 
		private function generate(from:int, to:int):void
		{
			var i:int;
			var j:int;
			
			var p0:Point;
			var p1:Point;
			var p2:Point;
			 
			var col0r:int;
			var col0g:int;
			var col0b:int;
			var col1r:int;
			var col1g:int;
			var col1b:int;
			var col2r:int;
			var col2g:int;
			var col2b:int;
			
			var line0:Array;
			var line1:Array;
			var line2:Array;
			
			var per0:Number;
			var per1:Number;
			var per2:Number;
			
			var face:Face;
			var fn:Number3D;
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
				if(_normalmap.getPixel(x, y) == 0){
					colorpt.x = x;
					colorpt.y = y;
					 
					var cross0:Point = meet(intPt0, line1[0].x,line1[0].y, line1[1].x, line1[1].y, p0.x, p0.y, x, y);
					var cross1:Point = meet(intPt1, line2[0].x,line2[0].y, line2[1].x, line2[1].y, p1.x, p1.y, x, y);
					var cross2:Point = meet(intPt2, line0[0].x,line0[0].y, line0[1].x, line0[1].y, p2.x, p2.y, x, y);
					 
					per0 = (cross0 == null)? 1 : Point.distance(cross0, colorpt) / Point.distance(p0, cross0 ) ; 
					per1 = (cross1 == null)? 1 : Point.distance(cross1, colorpt) / Point.distance(p1, cross1 ) ;
					per2 = (cross2 == null)? 1 : Point.distance(cross2, colorpt) / Point.distance(p2, cross2 ) ;
					
					if(per0+per1+per2 < 1.2){
						var r:int =  (per0*col0r) + (per1*col1r) + (per2*col2r);
						var g:int = (per0*col0g) + (per1*col1g) + (per2*col2g);
						var b:int = (per0*col0b) + (per1*col1b) + (per2*col2b);
						 
						_normalmap.setPixel(x, y,	((r>255)? 255 : r) << 16 | 
																((g>255)? 255 : g)  << 8 | 
																((b>255)? 255 : b) );
					}
				}
			}
			
			if(_normalmap != null)
				_normalmap.lock();
			
			for(i = from;i<to;++i){
				
				if(_canceled)
					break;
					
				face = _mesh.faces[i];
				fn = face.normal;
				n0 = averageNormals(face.v0, n0, fn);
				p0 = new Point( face.uv0.u * _width,  (1 - face.uv0.v) * _height);
				col0r = 255 - ((127*n0.x)+127);
			 	col0g = 255 - ((127*n0.y)+127);
			 	col0b = (127*n0.z)+127;
				 
				n1 = averageNormals(face.v1, n1, fn);
				p1 = new Point( face.uv1.u * _width ,  (1 - face.uv1.v) * _height);
				col1r = 255 - ((127*n1.x)+127);
			 	col1g = 255 - ((127*n1.y)+127);
			 	col1b = (127*n1.z)+127;
				 
				n2 = averageNormals(face.v2, n2, fn);
				p2 = new Point( face.uv2.u * _width , (1 - face.uv2.v) * _height);
				col2r = 255 - ((127*n2.x)+127);
			 	col2g = 255 - ((127*n2.y)+127);
			 	col2b = (127*n2.z)+127;
				
				_lines = [];
				
				p0.x = Math.ceil(p0.x);
				p1.x = Math.ceil(p1.x);
				p2.x = Math.ceil(p2.x);
				
				p0.y = Math.ceil(p0.y);
				p1.y = Math.ceil(p1.y);
				p2.y = Math.ceil(p2.y);
				
				setBounds(p0.x, p0.y, p1.x, p1.y, col0r, col0g, col0b, col1r, col1g, col1b, Point.distance(p0, p1));
				setBounds(p1.x, p1.y, p2.x, p2.y, col1r, col1g, col1b, col2r, col2g, col2b, Point.distance(p1, p2));
				setBounds(p2.x, p2.y, p0.x, p0.y, col2r, col2g, col2b, col0r, col0g, col0b, Point.distance(p2, p0));
				 
				line0 = [p0, p1];
			 	line1 = [p1, p2];
				line2 = [p2, p0];
				 
				_lines.sortOn("y", 16);
				
				row = 0;
				rect.x = _lines[0].x;
				rect.y = _lines[0].y;
				rect.width = 1;
				
				for(j = 0;j < _lines.length; ++j)
				{
					if(row == _lines[j].y ){
						if(s > _lines[j].x){
							s = _lines[j].x;
							rect.x = s;
						} 
						if(e < _lines[j].x){
							e = _lines[j].x;
						}
						rect.width = e-s;
						 
					} else{
						//if(rect.width> 1){//2
						for(var k:int = rect.x;k<rect.x+rect.width;++k){//k = rect.x+1+1
							applyColorAt(k, rect.y);
						}
						//}
						s = _lines[j].x;
						e = _lines[j].x;
						row = _lines[j].y;
						rect.x = _lines[j].x;
						rect.y = _lines[j].y;
						rect.width =1;
					}
				}
				 
				for(j = 0;j< _lines.length; ++j)
				{
					if(_lines[j].color !=0){
						_normalmap.setPixel(_lines[j].x, _lines[j].y, _lines[j].color);
						_lines[j] = null;
					}
				}
				  
			}
			
			
			var te:TraceEvent;
			
			if(!_canceled){
				_normalmap.unlock();
				_state = i;
			
				
				if(_state == _mesh.faces.length){
					 
					if(_growpixels)
						grow();
					 
					if(_bumpsource != null) 
							applyBump(_bumpsource, _normalmap);
							
					if(_blur != 0)
						applyBlur(_normalmap);
					 
					_lines = null;
					
					if(hasEventListener(TraceEvent.TRACE_COMPLETE)){
						te = new TraceEvent(TraceEvent.TRACE_COMPLETE);
						te.percent = 100;
						dispatchEvent(te);
					}
					
				} else{
					
					if(hasEventListener(TraceEvent.TRACE_PROGRESS)){
						te = new TraceEvent(TraceEvent.TRACE_PROGRESS);
						te.percent = (_state / _mesh.faces.length) *100;
						dispatchEvent(te);
					}
					
					setTimeout(generate, 1, _state, (_state+_step>_mesh.faces.length )? _mesh.faces.length : _state+_step);
				}
				
			} else{
				trace("XXXXXXX trace normalmap canceled XXXXXXX");
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
		 
		private function averageNormals(v:Vertex, n:Number3D, fn:Number3D):Number3D
		{
			n.x = 0;
			n.y = 0;
			n.z = 0;
			var m0:int = 0;
			var m1:int = 0;
			var m2:int = 0;
			var f:Face;
			var norm:Number3D;
			 
			for(var i:int = 0;i<_mesh.faces.length;++i){
				f = _mesh.faces[i];
				if((f.v0.x == v.x && f.v0.y == v.y && f.v0.z == v.z) || (f.v1.x == v.x && f.v1.y == v.y && f.v1.z == v.z )|| (f.v2.x == v.x && f.v2.y == v.y && f.v2.z == v.z)){
					norm = f.normal;
					
					if((Math.max(fn.x, norm.x) - Math.min(fn.x, norm.x) < .8)){
						n.x += norm.x;
						m0++;
					}
					
					if((Math.max(fn.y, norm.y) - Math.min(fn.y, norm.y) < .8)){
						n.y += norm.y;
						m1++;
					}
					
					if(_type == 0){
						if((Math.max(fn.z, norm.z) - Math.min(fn.z, norm.z) < .8)){
							n.z += norm.z;
							m2++;
						}
					} else{
						n.z ++;
						m2++;
					}
				}
			}
			 
			n.x /= m0;
			n.y /= m1;
			n.z /= m2;
			
			n.normalize();
			 
			return n;
		}
		 
		private function setBounds(x1:int,y1:int,x2:int,y2:int, r0:Number, g0:Number, b0:Number, r1:Number, g1:Number, b1:Number, dist:Number):void
		{
			var line:Array = [x1, y1];
			var dist2:Number;
			var scale:Number;
			var invscl:Number = 1-scale;
			
			var r:Number;
			var g:Number;
			var b:Number;
				 
			_lines[_lines.length] = new LScan(x1, y1,  r0 << 16| g0 << 8| b0);
			_lines[_lines.length] = new LScan(x2, y2,  r1 << 16| g1 << 8| b1);
			
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
					r =  (r1*scale)+(r0*invscl);
					g =  (g1*scale)+(g0*invscl);
					b =  (b1*scale)+(b0*invscl);
					_lines[_lines.length] = new LScan(x2, y2,  r << 16| g << 8| b);
					error += dx;
					if (error > 0) {
						x2 += yi;
						dist2 = Math.sqrt((x2 - line[0]) * (x2 - line[0]) + (y2 - line[1]) * (y2 - line[1]));
						scale = dist2/dist;
						r =  (r1*scale)+(r0*invscl);
						g =  (g1*scale)+(g0*invscl);
						b =  (b1*scale)+(b0*invscl);
						_lines[_lines.length] = new LScan(x2, y2,  r << 16| g << 8| b);
						error -= dy;
					}
				}
			} else {
				error = -(dx >> 1);
				for (; x1 < x2; ++x1) {
					dist2 = Math.sqrt((x1 - line[0]) * (x1 - line[0]) + (y1 - line[1]) * (y1 - line[1]));
					scale = dist2/dist;
					r =  (r1*scale)+(r0*invscl);
					g =  (g1*scale)+(g0*invscl);
					b =  (b1*scale)+(b0*invscl);
					_lines[_lines.length] = new LScan(x1, y1,  r << 16| g << 8| b);
					error += dy;
					if (error > 0) {
						y1 += yi;
						dist2 = Math.sqrt((x1 - line[0]) * (x1 - line[0]) + (y1 - line[1]) * (y1 - line[1]));
						scale = dist2/dist;
						r =  (r1*scale)+(r0*invscl);
						g =  (g1*scale)+(g0*invscl);
						b =  (b1*scale)+(b0*invscl);
						_lines[_lines.length] = new LScan(x1, y1,  r << 16| g << 8| b);
						error -= dx;
					}
				}
			}
		}
		
		private function grow():void
		{
			_normalmap = Grow.apply(_normalmap, 10);
		}
		
		/**
		* Applys a bump to a given normal map. If you do not generate the map from a mesh, just pass null in the constructor.
		*
		* @param	bm						BitmapData. The source bumpmap.
		* @param	nm						BitmapData. The source normalmap.
		*
		*@ return BitmapData. The source normalmap with the bump applied to it
		*/
		public function applyBump(bm:BitmapData, nm:BitmapData):BitmapData
        {
				if(nm.width != bm.width || nm.height != bm.height){
					var gs:BitmapData = bm.clone();
					var sclmat:Matrix = new Matrix();
					var Wscl:Number = nm.width/gs.width;
					var Hscl:Number = nm.height/gs.height;
					sclmat.scale(Wscl, Hscl);
					_bumpmap = new BitmapData(gs.width * Wscl, gs.height * Hscl, false, 0);
					_bumpmap.draw(gs, sclmat, null, "normal", _bumpmap.rect, true);
					
				} else{
					_bumpmap = new BitmapData(bm.width, bm.height, false, 0x000000);
					_bumpmap.copyPixels(bm, bm.rect, new Point(0,0));
				}
				
				var zero:Point = new Point(0,0);
				
				var ct:ColorMatrixFilter = new ColorMatrixFilter([0.33,0.33,0.33,0,0,0.33,0.33,0.33,0,0,0.33,0.33,0.33,0,0]);
				_bumpmap.applyFilter(_bumpmap, nm.rect, zero, ct);
            	var cf:ConvolutionFilter = new ConvolutionFilter(3, 6, null, 1, 127);
            	
            	var dumX:BitmapData = new BitmapData(nm.width, nm.height, false, 0x000000);
            	cf.matrix = [0,0,0,-1,0,1,0,0,0];
            	dumX.applyFilter(_bumpmap, nm.rect, zero, cf);
            	_bumpmap.copyChannel(dumX, nm.rect, zero, 1, 1);
            	
            	var dumY:BitmapData = new BitmapData(nm.width, nm.height, false, 0x000000);
            	cf.matrix = new Array(0,-1,0,0,0,0,0,1,0);
            	dumY.applyFilter(_bumpmap, nm.rect, zero, cf);
            	_bumpmap.copyChannel(dumY, nm.rect, zero, 2, 2);
				
				dumX.dispose();
				dumY.dispose();
				
				var dp:DisplacementMapFilter = new DisplacementMapFilter();
						dp.mapBitmap = _bumpmap;
						dp.mapPoint = zero;
						dp.componentX = 1;
						dp.componentY = 2;
						dp.scaleX =  -127;
						dp.scaleY =  -127;
						dp.mode = "wrap";
						dp.color = 0;
						dp.alpha = 0;
				 
				nm.applyFilter(nm, _bumpmap.rect, zero, dp);
				
				return nm;
        }
		 
		
		/**
		* Class NormalMapGenerator generates a normalmap from a given Mesh object and merge an additionl bump information to it.
		*
		* @param	mesh						[optional] Mesh. The Mesh object to be traced.
		* @param	width						[optional] int. The width of the generated normalmap. Default is 512.
		* @param	height					[optional] int. The height of the generated normalmap. Default is 512.
		* @param	bumpsource			[optional] BitmapData. The source bitmapdata for an additional bump information. Default is null;
		* @param	blur						[optional] int. Blur value if applyed, the surface of the object becomes smoother. Default is 0;
		* @param	growpixels				[optional] Boolean. To avoid some artefacts cause by the pixel trace. adds pixels at the edges of the trace.
		* @param	maxfaces				[optional] int. To avoid that the player generates a timeout error, the class handles the trace of faces stepwize. Default is 50 faces.
		* @param	type						[optional] String. If the map is of type objectspace or tangent. Default = objectspace;
		*
		* It is a good practice to render the map with great size and eventually reduce after its rendered, since Flash doesn't allow to draw smaller than a pixel while the uv information might ask a smaller draw.
		* The mesh MUST have a unique mapping. Any overlapping face area will result in artefacts.
		*/
		public function NormalMapGenerator(mesh:Mesh = null, width:int = 512, height:int = 512, bumpsource:BitmapData = null, blur:int = 0, growpixels:Boolean = false, maxfaces:int = 50, type:String = "objectspace")
        {
			_mesh = mesh;
			_width = width;
			_height = height;
			_type = (type == "tangent")? 1 : 0;
			_state = 0;
			_maxfaces = maxfaces;
			_step = maxfaces * (1-(1/(2800/Math.max(_width, _height))));
			_bumpsource = bumpsource;
			_growpixels = growpixels;
			_blur = blur;
		}
		/**
		 * Starts the rendering of the normal map if a mesh object has been defined
		 * 
		 */
		public function apply():void
		{
			_canceled = false;
			if(_mesh != null && (_mesh as Mesh).vertices != null){
				
				if(_normalmap != null)
					_normalmap.dispose();
					
				_normalmap = new BitmapData(_width, _height, false, 0x000000);
				generate(0, (_step > _mesh.faces.length)? _mesh.faces.length : _step);
				
			} else{
				
				throw new Error("--> No valid Mesh set yet: NormalMapGenerator.mesh = MeshObject");
			}
		}
		
		/**
		 * The mesh Object3D to be traced.
		 * 
		 * @param	m		Mesh. The Mesh object to be traced.
		 */
		public function set mesh(m:Mesh):void
		{
			if(m != null && m.vertices != null)
				_mesh = m;
		}
		/**
		 * An optional bump information can be burned into the normalmap
		 * 
		 * @param	bmap	BitmapData. The source bitmapdata for an additional bump information. Default is null;
		 */
		public function set bumpsource(bmap:BitmapData):void
		{
			_bumpsource = bmap;
		}
		
		/**
		 * Cancels the trace
		 */
		public function cancel():void
        {
			_canceled = true;
			if(_bumpsource != null){
				_bumpsource.dispose();
				_bumpsource = null;
			}
        }
		
		/**
		 * @param	val		int. The width of the generated normalmap. Default is 512.
		 * 
		 */
		public function set width(val:int):void
		{
			_width = val;
			_step = _maxfaces * (1-(1/(2800/Math.max(_width, _height))));
		}
		
		/**
		 * @param	val		int. The height of the generated normalmap. Default is 512.
		 * 
		 */
		public function set height(val:int):void
		{
			_height = val;
			_step = _maxfaces * (1-(1/(2800/Math.max(_width, _height))));
		}
		
		/**
		 * @param	strType	 String. If the map is of type 'objectspace' or 'tangent'. Default = 'objectspace';
		 * 
		 */
		public function set type(strType:String):void
		{
			_type = (strType == "tangent")? 1 : 0;
		}
		
		/**
		 * @param	b	 Boolean. To avoid some artefacts cause by the pixel trace. adds pixels at the edges of the trace.
		 * 
		 */
		public function set growpixels(b:Boolean):void
		{
			_growpixels = b;
		}
		
		/**
		* @param	val	 int. To avoid that the player generates a timeout error, the class handles the trace of faces stepwize. Default is 50 faces.
		* 
		*/
		public function set maxfaces(val:int):void
		{
			_maxfaces =  (val <1 )? 1 : val;
		}
		
		/**
		* @param	val	 int. Blur value if applyed, the surface of the object becomes smoother. Default is 0;
		* 
		*/
		public function set blur(val:int):void
		{
			_blur =  (val <0 )? 0 : val;
		}
		
		 /**
		* Returns the normalMap generated by the class
		*
		* @return	normalmap		BitmapData. the normalMap generated by the class
		*/
		public function get normalmap():BitmapData
		{
			return _normalmap;
		}
		 /**
		* Returns the generated bump source for a displacementfilter generated by the class
		*
		* @return	bumpMap		BitmapData. The bumpMap generated by the class
		*/
		public function get bumpmap():BitmapData
		{
			return _bumpmap;
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
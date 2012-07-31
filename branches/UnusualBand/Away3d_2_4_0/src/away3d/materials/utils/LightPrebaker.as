﻿package away3d.materials.utils {
	
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Face;
	import away3d.core.base.Mesh;
	import away3d.core.base.Object3D;
	import away3d.core.base.UV;
	import away3d.core.base.Vertex;
	import away3d.core.math.Number3D;
	import away3d.events.TraceEvent;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.utils.data.Ray;
	import away3d.materials.utils.data.Grow;
	import away3d.materials.utils.data.LightData;
	import away3d.materials.utils.data.MeshData;
	import away3d.materials.utils.data.LScan;
	import away3d.materials.utils.data.RenderData;
	
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.events.EventDispatcher;
	import flash.filters.ConvolutionFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.utils.setTimeout;   	
	import flash.filters.BlurFilter;
	import flash.utils.getTimer;
	
	/**
	 * Dispatched while the class is busy tracing. Note that the source can already be used for a Material
	 * 
	 * @eventType away3d.events.TraceEvent
	 */
	[Event(name="tracecomplete",type="away3d.events.TraceEvent")]
	
	/**
	 * Dispatched each time one bitmapdata is traced if more than one.
	 * 
	 * @eventType away3d.events.TraceEvent
	 */
	[Event(name="tracecount",type="away3d.events.TraceEvent")]
    
	/**
	 * Dispatched when trace is done.
	 * 
	 * @eventType away3d.events.TraceEvent
	 */
	[Event(name="traceprogress",type="away3d.events.TraceEvent")]
	  
	public class LightPrebaker extends EventDispatcher{
		
		private var _width:int;
		private var _height:int;
		private var _maxW:int;
		private var _maxH:int;
		private var _sourcemap:BitmapData;
		private var _tracemap:BitmapData;
		private var _backsourcemap:BitmapData;
		private var _tracebackmap:BitmapData;
		private var _rayTrace:Boolean;
		private var _object3d:Object3D;
		private var _mesh:Mesh;
		private var _meshid:int = 0;
		private var _lines:Array;
		private var _bf:BlurFilter;
		private var _blur:int;
		private var _time:Number;
		private var _totalmesh:int =0;
		private var _totalfaces:int =0;
		private var _processedfaces:int =0;
		private var _meshes:Array = [];
		private var _proxmeshes:Array = [];
		private var _bitmaps:Array = [];
		private var n0:Number3D = new Number3D();
		private var n1:Number3D = new Number3D();
		private var n2:Number3D = new Number3D();
		private var intPt0:Point = new Point();
		private var intPt1:Point = new Point();
		private var intPt2:Point = new Point();
		private var rect:Rectangle = new Rectangle(0,0,1,1);
		private var _canceled:Boolean;
		private var _noneinrange:Boolean;
		
		private var _aLights:Array;
		private var _sceneAmbient:Number;

		private var d0:Number3D = new Number3D();
		private var d1:Number3D = new Number3D();
		private var d2:Number3D = new Number3D();
		
		//RayTrace
		private var _ray:Ray;
		private var _pixpos:Number3D;
		private var _sV0:Number3D;
		private var _sV1:Number3D;
		private var _sV2:Number3D;
		private var _halfPI:Number = Math.PI*.5;
		private var _half2PI:Number = 2/Math.PI;
		private var _lightVect:Number3D;
		private var _normalInterpol:Number3D;
		private var _lightloop:int;
		private var dl:Number;
		private var lfr:Number;
		private var calc:Number;
		private var calcPercent:Number;
		private var intersectP:Number3D;
		private var scenePx:Number;
		private var scenePy:Number;
		private var scenePz:Number;
		
		private function generate(from:int, to:int):void
		{
			var i:int;
			var j:int;
			var k:int;
			
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
			
			var aVColors:Array;
			 
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
			var lightFactor:Number;
			
			
			function meet(pt:Point, x1:int,  y1:int, x2:int, y2:int, x3:int, y3:int, x4:int, y4:int):Point
			{ 
				var d:int = (x1-x2)*(y3-y4) - (y1-y2)*(x3-x4);
				if (d == 0)  return null;
				
				var c:Number = (x1*y2-y1*x2);
				var e:Number = (x3*y4-y3*x4);
				pt.x = ((x3-x4)*c-(x1-x2)*e)/d;
				pt.y = ((y3-y4)*c-(y1-y2)*e)/d;
				
				return pt;
			}
			
			function setVertexColor(d:Number3D, n:Number3D, colr:int, colg:int, colb:int):Array
			{
				var dl:Number;
				var factl:Number;
				for(j = 0;j<_aLights.length;++j){
					dl = d.distance(_aLights[j].lightposition);
					percentFalloff =   (_aLights[j].lightfalloff- dl)/_aLights[j].lightfalloff;
					lightFactor = _aLights[j].lightposition.getAngle(n);
					 
					if(percentFalloff > 0 && dl <_aLights[j].lightfalloff){
						factl = lightFactor*percentFalloff;
						colr += _aLights[j].lightR *factl;
						colg += _aLights[j].lightG *factl;
						colb += _aLights[j].lightB *factl;
					}
				}
				
				return [colr, colg, colb];
				 
			}
			 
			function applyColorAt(x:int, y:int, d0:Number3D,d1:Number3D, d2:Number3D, n0:Number3D, n1:Number3D, n2:Number3D, Tface:Face):void {

				if (_tracemap.getPixel(x, y) == 0) {
					colorpt.x = x;
					colorpt.y = y;

					var cross0:Point = meet(intPt0, line1[0].x,line1[0].y, line1[1].x, line1[1].y, p0.x, p0.y, x, y);
					var cross1:Point = meet(intPt1, line2[0].x,line2[0].y, line2[1].x, line2[1].y, p1.x, p1.y, x, y);
			
					per0 = (cross0 == null)? 1 : Point.distance(cross0, colorpt) / Point.distance(p0, cross0 ) ;
					per1 = (cross1 == null)? 1 : Point.distance(cross1, colorpt) / Point.distance(p1, cross1 ) ;
					per2 =  -(per0+per1)+1;
					 
					var pixcolor:uint = _sourcemap.getPixel(x, y);
					var colPixR:int = pixcolor >> 16 & 0xFF;
					var colPixG:int = pixcolor >> 8 & 0xFF;
					var colPixB:int = pixcolor & 0xFF;
					
					if(_backsourcemap != null){
						var Bpixcolor:uint = _backsourcemap.getPixel(x, y);
						var BcolPixR:int = Bpixcolor >> 16 & 0xFF;
						var BcolPixG:int = Bpixcolor >> 8 & 0xFF;
						var BcolPixB:int = Bpixcolor & 0xFF;
						
						var br:int;
						var bg:int;
						var bb:int;
					}
					
					var r:int;
					var g:int;
					var b:int;
					
					if (per0+per1+per2 <= 1) {
					
						var backmat:Boolean = (_backsourcemap == null)? false: true;
						
						if (_rayTrace) {

							var k:int;
							var l:int;
							var m:int;
							var n:int;
							var hit:Boolean;
							var face:Face;
							var ms:Mesh;
							var lhits:Boolean;
							var cr:int;
							var cg:int;
							var cb:int;
							var spec:Number;
							
							if(backmat){
								var bcr:int;
								var bcg:int;
								var bcb:int;
							}
					 
							_pixpos.x =  (per0*d0.x)+ (per1*d1.x) + (per2*d2.x);
							_pixpos.y = (per0*d0.y) + (per1*d1.y) + (per2*d2.y);
							_pixpos.z = (per0*d0.z) + (per1*d1.z) + (per2*d2.z);
							
							_normalInterpol.x =  (per0*n0.x)+ (per1*n1.x) + (per2*n2.x);
							_normalInterpol.y = (per0*n0.y) + (per1*n1.y) + (per2*n2.y);
							_normalInterpol.z = (per0*n0.z) + (per1*n1.z) + (per2*n2.z);
							
							var lightData:LightData;
							var inverseshade:Number;
							
							for(k=0;k<_lightloop;++k){
								_aLights[k].hit = 0;
							}
							
							for (l=0; l<_proxmeshes.length; ++l) {
								ms = _meshes[_proxmeshes[l].index].mesh;
								
								//all lights have hitted, no need continue
								if(lhits)
									break;
									
								//to be avoid own compare, we be enabled later on, see artefacts comment below
								// is already done at beginning loop
								/*if ( ms == _mesh)
									continue;*/
								
								for (m= 0; m<ms.faces.length; ++m) {
								
									face = ms.faces[m];
									/*
									//--> give artefacts at extremities.
									//avoid compare with own face and neighbours... works for own shadowing
									if(ms == _mesh){
										
										if(face == Tface)
											continue;
											
										if(face.v0 == Tface.v0 || face.v0 == Tface.v1 || face.v0 == Tface.v2 || face.v1 == Tface.v0 || face.v1 == Tface.v1 || face.v1 == Tface.v2 || face.v2 == Tface.v2)
											continue;
										
									}
									*/
									scenePx = ms.scenePosition.x;
									scenePy = ms.scenePosition.y;
									scenePz = ms.scenePosition.z;
									
									_sV0.x = face.v0.x+scenePx;
									_sV0.y = face.v0.y+scenePy;
									_sV0.z = face.v0.z+scenePz;
			
									_sV1.x = face.v1.x+scenePx;
									_sV1.y = face.v1.y+scenePy;
									_sV1.z = face.v1.z+scenePz;
									
									_sV2.x = face.v2.x+scenePx;
									_sV2.y = face.v2.y+scenePy;
									_sV2.z = face.v2.z+scenePz;
			
									for (k= 0; k<_lightloop; ++k) {
										lightData = _aLights[k] as LightData;
										//object not in range of this light or light has a hit already
										if(!lightData.ranges[l] || lightData.hit == 1)
											continue;
											
										//distance pixel to light
										dl = lightData.lightposition.distance(_pixpos);
										//not in range falloff
										if(dl > lightData.lightfalloff)
											continue;

										//check on collision
										intersectP = _ray.getIntersect(_pixpos, lightData.lightposition, _sV0, _sV1, _sV2);
										
										//collision true if not null
										if (intersectP != null) {
											lightData.hit = 1;
											hit = true;
											lhits = true;
											//moet in intersect = true and use a while loop
											if(_lightloop>1){
												for (n= 0; n<_lightloop; ++n) {
													if((_aLights[n] as LightData).hit == 0){
														lhits = false;
														break;
													}
												}
											}
											
										}
										 
									}
									
									//we have a hit or all lights got a hit
									if (hit)
										break;
									
								}
							}
							
							//color build
							cr = colPixR *_sceneAmbient;
							cg = colPixG *_sceneAmbient;
							cb = colPixB *_sceneAmbient;
							 
							if(backmat){
								bcr = BcolPixR *_sceneAmbient;
								bcg = BcolPixG *_sceneAmbient;
								bcb = BcolPixB *_sceneAmbient;
							}
							 
							for(k = 0;k<_lightloop;++k){
								lightData = _aLights[k];
								dl = lightData.lightposition.distance(_pixpos);
								
								//check for gel base on angle
								//check for bump
								 
								if(lightData.hit == 1 || dl > lightData.lightfalloff){
									
										/*inverseshade = dl/lightData.lightfalloff;
										r += cr*inverseshade;
										g += cg*inverseshade;
										b += cb*inverseshade;*/
										r += cr;
										g += cg;
										b += cb;
										
										if(backmat){
											br += bcr;
											bg += bcg;
											bb += bcb;
										}

								} else{
									
									percentFalloff =  (lightData.lightfalloff - dl)/lightData.lightfalloff;
									_lightVect.sub(_pixpos, lightData.lightposition);
									lfr = _lightVect.getAngle(_normalInterpol);
									calc = (_halfPI - lfr)*_half2PI;
									
										if(calc > 0){
											
											calcPercent = calc*percentFalloff;
											
											r +=  (lightData.lightR*calcPercent)/255 + cr;
											g += (lightData.lightG*calcPercent)/255 + cg;
											b +=  (lightData.lightB*calcPercent)/255 + cb;
											
										} else {
											r += cr;
											g += cg;
											b += cb;
										}
									
									if(calc != 0 && lightData.specular>1 && lfr<1.5){

										spec = lightData.specular*(1- (lfr/Math.PI)) * calcPercent;
										r += cr*spec;
										g += cg*spec;
										b += cb*spec;
									}
									 
									if(backmat){
										
										if(calc > 0){
											_normalInterpol.x = -_normalInterpol.x;
											_normalInterpol.y = -_normalInterpol.y;
											_normalInterpol.z = -_normalInterpol.z;
											lfr = _lightVect.getAngle(_normalInterpol);
											calc = (_halfPI - lfr)*_half2PI;
										
											if(calc > 0){
												calcPercent = calc*percentFalloff;
												br += (lightData.lightR*calcPercent)/255 + bcr;
												bg += (lightData.lightG*calcPercent)/255 + bcg;
												bb += (lightData.lightB*calcPercent)/255 + bcb;
												
											} else {
												
												br += bcr;
												bg += bcg;
												bb += bcb;
											}
										
										}
									}
									 
								}
							}
							 
						//interpolating trace
						} else {
							r =  (per0*col0r)+ (per1*col1r) + (per2*col2r);
							g = (per0*col0g) + (per1*col1g) + (per2*col2g);
							b = (per0*col0b) + (per1*col1b) + (per2*col2b);
							
							if(backmat){
								br = r;
								bg = g;
								bb = b;
								br += BcolPixR*_sceneAmbient;
								bg += BcolPixG*_sceneAmbient;
								bb += BcolPixB*_sceneAmbient;
							}
							
							r += colPixR*_sceneAmbient;
							g += colPixG*_sceneAmbient;
							b += colPixB*_sceneAmbient;
							 
						}
						
						//apply final pixel color
						_tracemap.setPixel(x, y,  ((r>255)? 255 : r) << 16 | 
															((g>255)? 255 : g)  << 8 | 
															((b>255)? 255 : b) );
						
						//we apply to back material as well if any
						if(backmat){
							_tracebackmap.setPixel(x, y,  ((br>255)? 255 : br) << 16 | 
															((bg>255)? 255 : bg)  << 8 | 
															((bb>255)? 255 : bb) );
							
						}
						
					}
				}
			
			}
			 
			_sourcemap.lock();
			var percentFalloff:Number = 1;
			var timeout:Boolean;
			var nowtime:Number;
			
			for(i = from;i<to;++i){
				if(_canceled)
					break;
				
				if(!_meshes[_meshid].render){
					i = to;
					break;
				}
				
				col0r = col0g = col0b = col1r = col1g = col1b = col2r = col2g = col2b = 0;
				face = _mesh.faces[i];
				fn = face.normal;
				n0 = averageNormals(face.v0, n0, fn);
				p0 = new Point( face.uv0.u * _width,  (1 - face.uv0.v) * _height);
				d0.x = face.v0.x+_mesh.scenePosition.x;
				d0.y = face.v0.y+_mesh.scenePosition.y;
				d0.z = face.v0.z+_mesh.scenePosition.z;
				  
				n1 = averageNormals(face.v1, n1, fn);
				p1 = new Point( face.uv1.u * _width ,  (1 - face.uv1.v) * _height);
				d1.x = face.v1.x+_mesh.scenePosition.x;
				d1.y = face.v1.y+_mesh.scenePosition.y;
				d1.z = face.v1.z+_mesh.scenePosition.z;
				 
				n2 = averageNormals(face.v2, n2, fn);
				p2 = new Point( face.uv2.u * _width , (1 - face.uv2.v) * _height);
				d2.x = face.v2.x+_mesh.scenePosition.x;
				d2.y = face.v2.y+_mesh.scenePosition.y;
				d2.z = face.v2.z+_mesh.scenePosition.z;
				  
				if(!_rayTrace){
					aVColors = setVertexColor(d0, n0, col0r, col0g, col0b);
					col0r = aVColors[0];
					col0g = aVColors[1];
					col0b = aVColors[2];
					
					aVColors = setVertexColor(d1, n1, col1r, col1g, col1b);
					col1r = aVColors[0];
					col1g = aVColors[1];
					col1b = aVColors[2];
					
					aVColors = setVertexColor(d2, n2, col2r, col2g, col2b);
					col2r = aVColors[0];
					col2g = aVColors[1];
					col2b = aVColors[2];
				
					if(_aLights.length>1){
						col0r /= _aLights.length;
						col0g /= _aLights.length;
						col0b /= _aLights.length;
						col1r /= _aLights.length;
						col1g /= _aLights.length;
						col1b /= _aLights.length;
						col2r /= _aLights.length;
						col2g /= _aLights.length;
						col2b /= _aLights.length;
					}
					
				} 
				
				_lines = [];
				 
				p0.x = Math.ceil(p0.x);
				p1.x = Math.ceil(p1.x);
				p2.x = Math.ceil(p2.x);
				p0.y = Math.ceil(p0.y);
				p1.y = Math.ceil(p1.y);
				p2.y = Math.ceil(p2.y); 
				
				setBounds(p0.x, p0.y, p1.x, p1.y);
				setBounds(p1.x, p1.y, p2.x, p2.y);
				setBounds(p2.x, p2.y, p0.x, p0.y);
				
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
							k = rect.x = s;
						} 
						if(e < _lines[j].x){
							e = _lines[j].x;
						}
						rect.width = e-s;
						 
					} else{
						k = rect.x;
						while(k++ <rect.x+rect.width){
							applyColorAt(k, rect.y, d0, d1, d2, n0, n1, n2, face);
						}
						s = _lines[j].x;
						e = _lines[j].x;
						row = _lines[j].y;
						rect.x = _lines[j].x;
						rect.y = _lines[j].y;
						rect.width =0;
					}
				}
				
				nowtime = getTimer();
				if(i<to-1 && nowtime -_time > 2000){
					timeout = true;
					_time = nowtime;
					break;
				}
				
			}
			
			_sourcemap.unlock();
			 
			var te:TraceEvent;
			if(!_canceled){
				 
				if(i == _mesh.faces.length){
					_lines = null;
					grow(_tracemap);
					
					if(_blur> 0)
						applyBlur(_tracemap, _meshes[_meshid].id);
					 
					if(_sourcemap.transparent)
							restoreAlpha(0);
					//to do: replicating all other materials vars...
					_mesh.material = new BitmapMaterial(_tracemap, {});
					
					if(_meshes[_meshid].frontcloned)
							_meshes[_meshid].sourcemap.dispose();
					
					if(_backsourcemap != null){
						grow(_tracebackmap);
						if(_blur> 0)
							applyBlur(_tracebackmap, _meshes[_meshid].id);
						 
						if(_backsourcemap.transparent)
							restoreAlpha(1);
							
						_mesh.back = new BitmapMaterial(_tracebackmap, {});
						
						if(_meshes[_meshid].backcloned)
							_meshes[_meshid].backsourcemap.dispose();
						
					}
					 
					_totalmesh--;
					
					if(_totalmesh == 0){

						if(hasEventListener(TraceEvent.TRACE_COMPLETE)){
							te = new TraceEvent(TraceEvent.TRACE_COMPLETE);
							te.percent = 100;
							te.percentPart = 100;
							te.count = 0;
							te.totalParts = _meshes.length;
							dispatchEvent(te);
						}
						 
						 //cleanups
						 for(i = 0; i<_meshes.length;++i){
							 _meshes[i] = null;
						 }
						 for(i = 0; i<_aLights.length;++i){
							 _aLights[i] = null;
						 }
						_meshes = _aLights = null;
						_sourcemap = _tracemap = _backsourcemap = _tracebackmap = null;
						  
					} else {
						
						_processedfaces += i;
						if(hasEventListener(TraceEvent.TRACE_COUNT)){
							te = new TraceEvent(TraceEvent.TRACE_COUNT);
							te.count = _meshes.length-_totalmesh + 1;
							te.totalParts = _meshes.length;
							dispatchEvent(te);
						}
						 
						_meshid = _meshes.length-_totalmesh;
						draw(_meshes[_meshid].mesh);
					}
					
				} else{
					
					if(hasEventListener(TraceEvent.TRACE_PROGRESS)){
						te = new TraceEvent(TraceEvent.TRACE_PROGRESS);
						te.percentPart = ( i / _mesh.faces.length) *100;
						te.percent = ( (_processedfaces+i) / _totalfaces) *100;
						te.count = _meshes.length-_totalmesh + 1;
						te.totalParts = _meshes.length;
						dispatchEvent(te);
					}
					
					if(timeout)
						setTimeout(generate, 50, i, _mesh.faces.length);
					 
				}
			} else{
				trace("XXXXXXX process pre-baking canceled XXXXXXX");
			}
		}
		
		private function grow(bmd:BitmapData):void
		{			
			bmd = Grow.apply(bmd, 10);
		}
		
		private function applyBlur(map:BitmapData, id:int):void
		{
				if(!_bf)
					_bf = new BlurFilter(_blur, _blur);
				
				intPt0.x = intPt0.y = 0;
				
				map.applyFilter(map, map.rect, intPt0 ,_bf);
				
				if(id == _bitmaps.length-1)
					_bf = null;
		}
		
		private function restoreAlpha(type:int):void
		{
			intPt0.x = intPt0.y = 0;
			if (type == 0){
				_tracemap.copyChannel( _sourcemap, _sourcemap.rect, intPt0, 8, 8 );
			} else{
				_tracebackmap.copyChannel( _backsourcemap, _backsourcemap.rect, intPt0, 8, 8 );
			}
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
					
					if((Math.max(fn.z, norm.z) - Math.min(fn.z, norm.z) < .8)){
						n.z += norm.z;
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
		
		private function setBounds(x1:int,y1:int,x2:int,y2:int):void
		{
			_lines[_lines.length] = new LScan(x1, y1);
			_lines[_lines.length] = new LScan(x2, y2);
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
					_lines[_lines.length] = new LScan(x2, y2);
					error += dx;
					if (error > 0) {
						x2 += yi;
						_lines[_lines.length] = new LScan(x2, y2);
						error -= dy;
					}
				}
			} else {
				error = -(dx >> 1);
				for (; x1 < x2; ++x1) {
					_lines[_lines.length] = new LScan(x1, y1);
					error += dy;
					if (error > 0) {
						y1 += yi;
						_lines[_lines.length] = new LScan(x1, y1);
						error -= dx;
					}
				}
			}
		}
		
		private function setProxymityList():void
		{
			_proxmeshes = [];
			var m:Mesh;
			for(var i:int= 0;i<_meshes.length;++i){
				if(_meshes[i].mesh != _mesh){
					m = _meshes[i].mesh;
					_meshes[i].proxdist = m.scenePosition.distance(_mesh.scenePosition);
					_proxmeshes.push(_meshes[i]);
				}
			}
			_proxmeshes.sortOn("proxdist", 16 );
			//avoid put active mesh in list
			//_proxmeshes.push(_meshes[_meshid]);
			
			/*trace("------------>  Handling now: "+_mesh.name);
			for(i= 0;i<_proxmeshes.length;++i){
				trace("-- "+i+", "+_proxmeshes[i].mesh.name+", index: "+_proxmeshes[i].index+", id: "+_proxmeshes[i].id);
			}*/
		}
		
		private function draw(mesh:Mesh):void
        {
			_mesh = mesh;
			_sourcemap = _meshes[_meshid].sourcemap;
			_tracemap = _meshes[_meshid].tracemap;
			
			if(_meshes[_meshid].backtracemap != null){
				_tracebackmap = _meshes[_meshid].backtracemap;
				_backsourcemap = _meshes[_meshid].backsourcemap;
			} else{
				_backsourcemap = null;
				_tracebackmap = null;
			}
			
			_width = _tracemap.width;
			_height = _tracemap.height;
			
			//sort by nearer other meshes
			if(_rayTrace){
				setProxymityList();
			}
			
			generate(0, _mesh.faces.length);
		}
		
		private function meshInfo(object3d:Object3D):void
		{
			if(object3d as ObjectContainer3D){
				var obj:ObjectContainer3D = (object3d as ObjectContainer3D);
				for(var i:int =0;i<obj.children.length;++i){
					 
					if(obj.children[i] is ObjectContainer3D){
						meshInfo(obj.children[i]);
					} else{
						registerMesh(obj.children[i] as Mesh);
					}
				}
			} else {
				registerMesh(object3d as Mesh);
			}
		}
		
		private function registerMesh(mesh:Mesh):void
		{
			var inrange:Boolean = checkMeshBounds(mesh);
			
			if(inrange){
				_noneinrange = false;
				var sclmat:Matrix;
				var W:Number;
				var H:Number;
				
				var oMesh:MeshData = new MeshData();
				
				var source:BitmapData;
				if(mesh.material is BitmapMaterial){
					 source= (mesh.material as BitmapMaterial).bitmap;
					checkMaxTrace(new RenderData(mesh.name, new BitmapData(source.width, source.height, source.transparent, (source.transparent)? 0xFF000000 : 0x00)));
				} else {
					source = new BitmapData((_maxW <256)? _maxW : 256, (_maxH <256)? _maxH : 256, false, 0x00); 
					checkMaxTrace( new RenderData(mesh.name, new BitmapData((_maxW <256)? _maxW : 256, (_maxH <256)? _maxH : 256, false, 0x00))); 
					oMesh.sourcemap = source;
				}
				
				_totalmesh++;
				_totalfaces += mesh.faces.length;
				 
				oMesh.tracemap = _bitmaps[_bitmaps.length-1].source;
				
				if(source.width != oMesh.tracemap.width || source.height != oMesh.tracemap.height){
					oMesh.frontcloned = true;
					W = oMesh.tracemap.width;
					H = oMesh.tracemap.height;
					var tmpsource:BitmapData = new BitmapData(W, H, oMesh.tracemap.transparent, (oMesh.tracemap.transparent)? 0x00FFFFFF : 0x000000);
					sclmat = new Matrix();
					W = _maxW/source.width;
					H = _maxH/source.height;
					sclmat.scale(W, H);
					
					tmpsource.draw(source, sclmat, null, "normal", source.rect, true);
					source = tmpsource.clone();
					tmpsource.dispose();
				}
				oMesh.sourcemap = source;
				
				//oMesh.imagename = "im"+_bitmaps.length+"_"+mesh.name;
				oMesh.scenePosition = mesh.scenePosition;
				oMesh.mesh = mesh;
				oMesh.id = _bitmaps.length;
				
				if(mesh.back != null && mesh.back is BitmapMaterial){
					var backsource:BitmapData = (mesh.back as BitmapMaterial).bitmap;
					if(backsource.width != source.width || backsource.height != source.height){
						sclmat = new Matrix();
						W = source.width/backsource.width;
						H = source.height/backsource.height;
						sclmat.scale(W, H);
						var tmpsource2:BitmapData = new BitmapData(backsource.width * W, backsource.height * H, backsource.transparent, (backsource.transparent)? 0xFF000000 : 0x00);
						checkMaxTrace(new RenderData(mesh.name, tmpsource2.clone(), true));
						tmpsource2.draw(backsource, sclmat, null, "normal", tmpsource2.rect, true);
						oMesh.backsourcemap = tmpsource2;
						oMesh.backcloned = true;
					} else{
						checkMaxTrace(new RenderData(mesh.name, new BitmapData(backsource.width, backsource.height, backsource.transparent, (backsource.transparent)? 0xFF000000 : 0x00), true));
						oMesh.backsourcemap = backsource;
					}
					
					oMesh.backtracemap = _bitmaps[_bitmaps.length-1].source;
				}
				
				if(mesh.rotationX != 0 || mesh.rotationY != 0 || mesh.rotationZ != 0){
					oMesh.rotations = new Number3D(mesh.rotationX, mesh.rotationY, mesh.rotationZ);
					oMesh.mesh.applyRotations();
				}
				oMesh.index = _meshes.length;
				_meshes.push(oMesh);
				
			} else{
				
				if(mesh.material is BitmapMaterial){
					applyOutOfRange(mesh);
				} else{
					var val:int = 255*_sceneAmbient;
					var bmd:BitmapData = new BitmapData((_maxW <256)? _maxW : 256, (_maxH <256)? _maxH : 256, false, val << 16 | val << 8 | val);
					checkMaxTrace(new RenderData(mesh.name, bmd)); 
				}
				
			}
			
		}
		private function checkMaxTrace(renderdata:RenderData):void
		{
			if((_maxW>1 || _maxH>1) && (renderdata.source.width >_maxW || renderdata.source.height >_maxH)){
				var W:Number = (_maxW < renderdata.source.width)? _maxW : renderdata.source.width;
				var H:Number = (_maxH < renderdata.source.height)? _maxH : renderdata.source.height;
				var tmp:BitmapData = new BitmapData(W, H, renderdata.source.transparent, (renderdata.source.transparent)? 0x00FFFFFF : 0x000000);
				 
				var sclmat:Matrix = new Matrix();
				W = _maxW/renderdata.source.width;
				H = _maxH/renderdata.source.height;
				sclmat.scale(W, H);
				tmp.draw(renderdata.source, sclmat, null, "normal", renderdata.source.rect, true);
				renderdata.source.dispose();
				renderdata.source = tmp; 
			}
			_bitmaps.push(renderdata);
			 
		}
		
		private function applyOutOfRange(mesh:Mesh):void
		{
			//--> colorize the whole texture with ambient settings because not in range of any light sources
			var bmd:BitmapData = (mesh.material as BitmapMaterial).bitmap;
			var ct:ColorTransform =new ColorTransform(_sceneAmbient,_sceneAmbient,_sceneAmbient,1,1,1,1,0);
			bmd.colorTransform(bmd.rect, ct); 
			(mesh.material as BitmapMaterial).bitmap = bmd;
			_bitmaps.push(new RenderData(mesh.name, bmd));
			
			if(mesh.back != null && (mesh.back is BitmapMaterial)){
				bmd = (mesh.material as BitmapMaterial).bitmap;
				ct = new ColorTransform(_sceneAmbient,_sceneAmbient,_sceneAmbient,1,1,1,1,0);
				bmd.colorTransform(bmd.rect, ct); 
				(mesh.material as BitmapMaterial).bitmap = bmd;
				_bitmaps.push(new RenderData(mesh.name, bmd, true));
			}
		}
		 
		//first elimination, all meshes returning false get default ambient value applied to their materials
		private function checkMeshBounds(mesh:Mesh):Boolean
		{
			//is mesh in range of at least one light?
			for(var i:int= 0;i<_aLights.length;++i)
				if(mesh.scenePosition.distance(_aLights[i].lightposition)-mesh.boundingRadius <_aLights[i].lightfalloff)
						return true;
			 
			return false;
		}
		
		private function checkMeshBoundsPerLight():void
		{
			//check per light which mesh is in range
			var ms:Mesh;
			var y:int;
			var loop:int = _meshes.length;
			var bRange:Boolean;
			var lightData:LightData;
			for(var i:int= 0;i<_aLights.length;++i){
				lightData = _aLights[i];
				
				for (y=0; y<loop; ++y) {
					ms = _meshes[y].mesh;
					bRange = ms.scenePosition.distance(_aLights[i].lightposition)-ms.boundingRadius <_aLights[i].lightfalloff;
					_aLights[i].ranges[y] = bRange;
				}
			}
					
		}
		
		
		/**
		* Class LightPrebaker traces and merge light information into a (series) Mesh object BitmapMaterials. 
		* If no material or of another type is found on a Mesh object, a default bitmapMaterial is generated and applied to it.
		*
		* @param	object3d				Object3D. The Mesh(es) materials to draw.
		* @param	lights						Array of PointLight3D objects. Support at this time of development just lights of type PointLight3D;
		* @param	sceneambient			[optional] Number. A number from 0 to 1. Defines the ambient value for the class. Light ambient values are not used. Default = .5.
		* @param	rayTrace				[optional] Boolean. Set to true, the pre-baking is traced using raytrace algorythm. Note that a much greater time will be required to render. Default = false;
		* @param	maxW					[optional] int. Defines the max width a map can have, to avoid too long render times. Default is 1, no width limit.
		* @param	maxH					[optional] int. Defines the max height a map can have, to avoid too long render times. Default is 1, no height limit.
		* @param	blur						[optional] int. Defines the amount of blur applied to the bitmaps after rendering. Default is 0, no blur is applied.
		*/
		
		public function LightPrebaker(object3d:Object3D, lights:Array, sceneambient:Number=.5, rayTrace:Boolean = false, maxW:int = 1, maxH:int = 1, blur:int = 0)
        {	
			_object3d = object3d;
			_sceneAmbient = sceneambient;
			_rayTrace = rayTrace;
			_blur = blur;
			_maxW = maxW;
			_maxH = maxH;
			_time = getTimer();
			_canceled = false;
			_noneinrange = true;
			_aLights = [];
			var oLight:LightData;
			var multi:Number;
			for(var i:int = 0; i<lights.length;++i){
				oLight = new LightData();
				oLight.lightfalloff = lights[i].fallOff;
				oLight.lightradius = lights[i].radius;
				oLight.lightcolor = lights[i].color;
				oLight.lightR = (lights[i].color >> 16 & 0xFF);
				oLight.lightG = (lights[i].color >> 8 & 0xFF);
				oLight.lightB = (lights[i].color & 0xFF);
				oLight.ranges = [];
				oLight.hit = 0;
				oLight.lightposition = new Number3D(lights[i].scenePosition.x, lights[i].scenePosition.y, lights[i].scenePosition.z);
				
				if(_rayTrace){
					multi = lights[i].diffuse*lights[i].brightness;
					oLight.brightness = lights[i].brightness;
					oLight.specular = lights[i].specular;
					oLight.lightR *= multi;
					oLight.lightG *= multi;
					oLight.lightB *= multi;
				}
				
				_aLights.push(oLight);
			}
			
			if(_rayTrace){
				_sV0 = new Number3D();
			 	_sV1 = new Number3D();
			 	_sV2 = new Number3D();
				_pixpos = new Number3D();
				_lightVect = new Number3D();
				_normalInterpol = new Number3D();
				_lightloop =_aLights.length;
				_ray = new Ray();
			}
				
			meshInfo(object3d);
			 
			if(_rayTrace){
				checkMeshBoundsPerLight();
			}
			 
		}
		
		/**
		 * Starts the trace
		 * 
		 * @param	 aRender	[optional] Array. A series of 0 and 1. defines if a mesh material needs to be rendered. This optional parameter is usefull for application
		 * where you would want to update only certain renderings instead of retrace everything. Length and order must be similar to Object3D structure. 
		 */
		public function apply(aRender:Array = null):void
        {
			if(!_noneinrange){
				if(aRender != null){
					for (var i:int = 0; i<aRender.length;++i){
						_meshes[i].render = (aRender[i] == true)? true : false;
					}
				}
				trace("startrender...");
				draw(_meshes[_meshid].mesh);
			
			} else {
				trace("No meshes were in range of (one of) the light(s)\nSceneambient value applied only");
				if(hasEventListener(TraceEvent.TRACE_COMPLETE)){
					var te:TraceEvent = new TraceEvent(TraceEvent.TRACE_COMPLETE);
					te.percent = 100;
					te.percentPart = 100;
					te.count = 0;
					te.totalParts = _meshes.length;
					dispatchEvent(te);
				}
			}
        }
		
		/**
		 * getter that returns an array of all generated BitmapData objects
		 * 
		 * @return	Array		An array holding all generated BitmapData objects in RenderData type. holds variable; source, name and is back material
		 */
		public function get renderdata():Array
        {
			return _bitmaps;
        }
		
		/**
		 * getter that returns an array of all generated BitmapData objects in RenderData type.
		 * 
		 * @return	Array		An array holding all generated BitmapData objects in order of generation.
		 */
		public function getBitmaps():Array
        {
			var arr:Array = [];
			for(var i:int = 0;i< _bitmaps.length;++i){
				arr.push(_bitmaps[i].source);
			}
			return arr;
        }
		
		/**
		 * Clears the array of BitmapData objects of the memory
		 */
		public function clearBitmaps():void
        {
			for(var i:int = 0;i< _bitmaps.length;++i){
				_bitmaps[i].source.dispose();
				_bitmaps[i] = null;
			}
			_bitmaps = null;
        }
		
		/**
		 * Clears the array of BitmapData objects of the memory
		 */
		public function cancel():void
        {
			_meshes = [];
			_canceled = true;
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
		
		/**
		 * Default method for adding a tracecount event listener
		 * 
		 * @param	listener		The listener function
		 */
		public function addOnTraceCount(listener:Function):void
        {
			addEventListener(TraceEvent.TRACE_COUNT, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a tracecount event listener
		 * 
		 * @param	listener		The listener function
		 */
		public function removeOnTraceCount(listener:Function):void
        {
            removeEventListener(TraceEvent.TRACE_COUNT, listener, false);
        }
		
		
	}
}
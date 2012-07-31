﻿package away3d.extrusions
{
    import away3d.core.base.*;
    import away3d.core.math.*;
    import away3d.core.utils.*;
    import flash.geom.Point;

	public class SegmentsExtrude extends Mesh
	{
		private var varr:Array = [];
		private var varr2:Array = [];
		private var uvarr:Array = [];
				
         public function SegmentsExtrude(aPoints:Array, init:Object = null)
        {
			
			if(init["material"] != null) init["materials"] = {defaultmaterial:init["material"]};
			if(init["material"] == null && init["materials"] != null) init["material"] = init["materials"].defaultmaterial;
			
		 	super(init);
 
            var axis:String = ini.getString("axis", "y");
            var offset:Number = ini.getNumber("offset", 10);
            var subdivision:int = ini.getInt("subdivision", 1, {min:1});
			var thickness:Number = Math.abs(ini.getNumber("thickness", 0));
			var thickness_subdivision:Number = ini.getInt("thickness_subdivision", 1, {min:1});
			var flip:Boolean = ini.getBoolean("flip", false);
			var scaling:Number = ini.getNumber("scaling", 1);
			var oMat:Object = ini.getObject("materials", null);
			var omit:String = ini.getString("omit", "");
			var coverall:Boolean = ini.getBoolean("coverall", false);
			var recenter:Boolean = ini.getBoolean("recenter", false);
			var closepath:Boolean = ini.getBoolean("closepath", false);
			
			if(closepath) omit += "left,right";
			
			if(aPoints[0] is Array){
				//in case more extrudes are done in one mesh
				for(var i:int = 0;i<aPoints.length;++i){
					
					if(aPoints[i].length > 1){
						varr = [];
						varr2 = [];
						uvarr = [];
						generate(aPoints[i], oMat, axis, offset, subdivision, thickness, thickness_subdivision, scaling, omit, coverall, closepath, flip);
					} else {
						trace("SegmentsExtrude error: at index "+i+" , at least 2 points are required per extrude!");
					}
				}
				
			}else{

				if(closepath)  aPoints.push(new Number3D(aPoints[0].x, aPoints[0].y, aPoints[0].z));
				if(aPoints.length > 1){
            		 generate(aPoints, oMat, axis, offset, subdivision, thickness, thickness_subdivision, scaling, omit, coverall, closepath, flip);
				} else {
					trace("SegmentsExtrude error: at least 2 points in an array are required per extrude!");
				}
				
			}
			 
			if(recenter) {
				applyPosition((this.minX+this.maxX)*.5, (this.minY+this.maxY)*.5, (this.minZ+this.maxZ)*.5);
			} else {
				var isArr:Boolean = (aPoints[0] is Array);
				x =  (isArr)? aPoints[0][0].x : aPoints[0].x;
				y =  (isArr)? aPoints[0][0].y : aPoints[0].y;
				z =  (isArr)? aPoints[0][0].z : aPoints[0].z;
			}
			
			varr = null;
			varr2 = null;
			uvarr = null;
			
			type = "SegmentsExtrude";
        	url = "Extrude";
        }
		
		private function generate(points:Array, oMat:Object = null, axis:String = "y", origoffset:Number = 0, subdivision:int = 1,  thickness:Number = 0, thickness_subdivision:int = 1, scaling:Number = 1, omit:String = "", coverall:Boolean = false, closepath:Boolean = false, flip:Boolean = false):void
		{					
			var i:int;
			var j:int;
			var increase:Number = (subdivision == 1)? origoffset : origoffset/subdivision;
			var basemaxX:Number  = points[0].x;
			var baseminX:Number = points[0].x;
			var basemaxY:Number = points[0].y;
			var baseminY:Number = points[0].y; 
			var basemaxZ:Number = points[0].z;
			var baseminZ:Number = points[0].z;
			 
			for (i = 0; i < points.length; i++) {
				
				if(scaling != 1){
					points[i].x *= scaling;
					points[i].y *= scaling;
					points[i].z *= scaling;
				}
				
 				basemaxX = Math.max(points[i].x, basemaxX);
				baseminX = Math.min(points[i].x, baseminX);
				basemaxY = Math.max(points[i].y, basemaxY);
				baseminY = Math.min(points[i].y, baseminY);
				basemaxZ = Math.max(points[i].z, basemaxZ);
				baseminZ = Math.min(points[i].z, baseminZ);
				 
			}
			 
			var basemax:Number;
			var basemin:Number;
			var offset:Number = 0;
			
			switch(axis){
				case "x":
					basemax = Math.abs(basemaxX) - Math.abs(baseminX);
					if(baseminZ >0 && basemaxZ >0){
						basemin =  basemaxZ - baseminZ;
						offset = -baseminZ;
					}else if(baseminZ <0 && basemaxZ <0){
						basemin =  Math.abs(baseminZ - basemaxZ);
						offset = -baseminZ;
					}else{					
						basemin =  Math.abs(basemaxZ) + Math.abs(baseminZ);
						offset = Math.abs(baseminZ)+((basemaxZ<0)? -basemaxZ: 0);
					}
					break;
					
				case "y":
					basemax = Math.abs(basemaxY) - Math.abs(baseminY);
					if(baseminX >0 && basemaxX >0){
						basemin =  basemaxX - baseminX;
						offset = -baseminX;
					}else if(baseminX <0 && basemaxX <0){
						basemin =  Math.abs(baseminX - basemaxX);
						offset = -baseminX;
					}else{					
						basemin =  Math.abs(basemaxX) + Math.abs(baseminX);
						offset = Math.abs(baseminX)+((basemaxX<0)? -basemaxX: 0);
					}
					break;
					
				case "z":
					basemax = Math.abs(basemaxZ) - Math.abs(baseminZ);
					if(baseminY >0 && basemaxY >0){
						basemin =  basemaxY - baseminY;
						offset = -baseminY;
					}else if(baseminY <0 && basemaxY <0){
						basemin =  Math.abs(baseminY - basemaxY);
						offset = -baseminY; 
					}else{					
						basemin =  Math.abs(basemaxY) + Math.abs(baseminY);
						offset = Math.abs(baseminY)+((basemaxY<0)? -basemaxY: 0);
					}
					break;
			}
			
			var Lines:Array;
			var prop1:String;
			var prop2:String;
			var prop3:String;
			
			var aListsides:Array = ["top","bottom", "right", "left", "front", "back"];
			
			if(thickness != 0) {
				
				var oRenderside:Object = {};
				for(i = 0;i<aListsides.length;i++){
					oRenderside[aListsides[i]] = (omit.indexOf(aListsides[i]) == -1);
				}
				 
				switch(axis){
					case"x":
						prop1 = "z";
						prop2 = "y";
						prop3 = "x";
					break;
					
					case"y":
						prop1 = "x";
						prop2 = "z";
						prop3 = "y";
					break;
					
					case"z":
						prop1 = "y";
						prop2 = "x";
						prop3 = "z";
				}
				
				Lines = buildThicknessPoints(points, thickness, prop1, prop2, closepath);
				 
				var oPoints:Object;
				var vector:Vertex;
				var vector2:Vertex;
				var vector3:Vertex;
				var vector4:Vertex;
				 
				for(i = 0;i<Lines.length;i++){
					
					oPoints = Lines[i];
					vector = new Vertex();
					vector2 = new Vertex();
					 
					if(i == 0){
						vector[prop1] = Number(oPoints["pt2"].x.toFixed(4));
						vector[prop2] = Number(oPoints["pt2"].y.toFixed(4));
						vector[prop3] = points[0][prop3];
						varr.push(new Vertex(vector.x,vector.y,vector.z));
						
						vector2[prop1] = Number(oPoints["pt1"].x.toFixed(4));
						vector2[prop2] = Number(oPoints["pt1"].y.toFixed(4));
						vector2[prop3] = points[0][prop3];
						varr2.push(new Vertex(vector2.x,vector2.y,vector2.z));
						  
						elevate(subdivision, axis, vector, vector2, basemin, basemax, increase);
						
						if(Lines.length == 1) {
							
						 	vector3 = new Vertex();
							vector4 = new Vertex();
							
							vector3[prop1] = Number(oPoints["pt4"].x.toFixed(4));
							vector3[prop2] = Number(oPoints["pt4"].y.toFixed(4));
							vector3[prop3] = points[0][prop3];
							varr.push(new Vertex(vector3.x,vector3.y,vector3.z));
							
							vector4[prop1] = Number(oPoints["pt3"].x.toFixed(4));
							vector4[prop2] = Number(oPoints["pt3"].y.toFixed(4));
							vector4[prop3] = points[0][prop3];						
							varr2.push(new Vertex(vector4.x,vector4.y,vector4.z));
							
							elevate(subdivision, axis, vector3, vector4, basemin, basemax, increase);
						} 
						 
					} else if (i == Lines.length-1) {
						 
						vector[prop1] = oPoints["pt2"].x;
						vector[prop2] = oPoints["pt2"].y;
						vector[prop3] = points[i][prop3];
						varr.push(new Vertex(vector.x,vector.y,vector.z));
						
						vector2[prop1] = oPoints["pt1"].x;
						vector2[prop2] = oPoints["pt1"].y;
						vector2[prop3] = points[i][prop3];
						varr2.push(new Vertex(vector2.x,vector2.y,vector2.z));
						
						elevate(subdivision, axis, vector, vector2, basemin, basemax, increase);
						vector3 = new Vertex();
						vector4 = new Vertex();
						
						vector3[prop1] = oPoints["pt4"].x;
						vector3[prop2] = oPoints["pt4"].y;
						vector3[prop3] = points[i][prop3];
						varr.push(new Vertex(vector3.x,vector3.y,vector3.z));
						
						vector4[prop1] = oPoints["pt3"].x;
						vector4[prop2] = oPoints["pt3"].y;
						vector4[prop3] = points[i][prop3];
						varr2.push(new Vertex(vector4.x,vector4.y,vector4.z));
						
						elevate(subdivision, axis, vector3, vector4, basemin, basemax, increase);
						
					 } else {
						 
						vector[prop1] = oPoints["pt2"].x;
						vector[prop2] = oPoints["pt2"].y;
						vector[prop3] = points[i][prop3];
						varr.push(new Vertex(vector.x,vector.y,vector.z));
						
						vector2[prop1] = oPoints["pt1"].x;
						vector2[prop2] = oPoints["pt1"].y;
						vector2[prop3] = points[i][prop3];						
						varr2.push(new Vertex(vector2.x,vector2.y,vector2.z));
						
						elevate(subdivision, axis, vector, vector2, basemin, basemax, increase);
						
					}
					
				}
			 
			 
			} else {
			 
					for (i = 0; i < points.length; i++) {
						vector.x = points[i].x;
						vector.y = points[i].y;
						vector.z = points[i].z;
						varr.push(new Vertex(vector.x,vector.y,vector.z));
						switch(axis){
							case "x":
								uvarr.push(new UV(Math.abs(vector.z%basemin), vector.x%basemax));
								break;
							case "y":
								uvarr.push(new UV(Math.abs(vector.x%basemin), vector.y%basemax));
								break;
							case "z":
								uvarr.push(new UV(Math.abs(vector.y%basemin), vector.z%basemax));
								break;
						}
		
						for(j = 0; j < subdivision; j++){
							vector[axis] += increase;
							switch(axis){
								case "x":
									uvarr.push(new UV(Math.abs(vector.z%basemin), vector.x%basemax));
									break;
								case "y":
									uvarr.push(new UV(Math.abs(vector.x%basemin), vector.y%basemax));
									break;
								case "z":
									uvarr.push(new UV(Math.abs(vector.y%basemin), vector.z%basemax));
									break;
							}
							varr.push(new Vertex(vector.x,vector.y,vector.z));
						}
						
					}
					
			}
			
			//axis switch for elevation
			switch(axis){
				case"x":
					axis = "z";
				break;
				
				case"y":
					axis = "x";
				break;
				
				case"z":
					axis = "y";
			}
			
			var index:int = 0;
			
			if(thickness != 0) {
				var mf:*;
				var mb:*;
				var mt:*;
				var mbo:*;
				var mr:*;
				var ml:*;
				
				if(oMat != null){
					mf = (oMat["front"] != null)? oMat["front"] : null;
					mb = (oMat["back"] != null)? oMat["back"] : null;
					mt = (oMat["top"] != null)? oMat["top"] : null;
					mbo = (oMat["bottom"] != null)? oMat["bottom"] : null;
					mr = (oMat["right"] != null)? oMat["right"] : null;
					ml = (oMat["left"] != null)? oMat["left"] : null;
				} 
			}
			
			var uva:UV; //downleft
			var uvb:UV; //topleft
			var uvc:UV; //topright
			var uvd:UV; //downright
			
			for (i = 0; i < points.length-1; ++i) {
				
				var pt1:Number = ( Math.abs(points[i][axis]+offset) / basemin )/1 ;
				var pt2:Number = ( Math.abs(points[i+1][axis]+offset) / basemin ) /1;
				
				for (j = 0; j < subdivision; ++j) {
						 
						if(coverall){
							uva = new UV(  pt1 , j/subdivision );
							uvb = new UV(  pt1  , (j+1)/subdivision );
							uvc = new UV(  pt2  , (j+1)/subdivision );
							uvd = new UV(  pt2  , j/subdivision );
						} else{
							uva = new UV( 0 , j/subdivision );
							uvb = new UV(  0  , (j+1)/subdivision );
							uvc = new UV(1  , (j+1)/subdivision );
							uvd = new UV(  1  , j/subdivision );
						}
						 
						if(thickness == 0){
							if(flip){
								addFace(new Face(varr[(index+j) + 1],varr[index+j],varr[((index+j) + (subdivision + 2))], null, uvb, uva, uvc  ));
								addFace(new Face(varr[((index+j) + (subdivision + 2))],varr[(index+j)],varr[((index+j) + (subdivision + 1))], null,  uvc, uva, uvd));
							} else{
								addFace(new Face(varr[index+j],varr[(index+j) + 1],varr[((index+j) + (subdivision + 2))], null, uva, uvb, uvc  ));
								addFace(new Face(varr[(index+j)],varr[((index+j) + (subdivision + 2))],varr[((index+j) + (subdivision + 1))], null, uva, uvc, uvd));
							}
						} else {
							//body side 1
							var v1a:Vertex = varr[index+j];
							var v1b:Vertex = varr[(index+j) + 1];
							var v1c:Vertex = varr[((index+j) + (subdivision + 2))];
							var v2a:Vertex = varr[(index+j)];
							var v2b:Vertex = varr[((index+j) + (subdivision + 2))];
							var v2c:Vertex = varr[((index+j) + (subdivision + 1))];
							
							//body side 2
							var v3a:Vertex = varr2[index+j];
							var v3b:Vertex = varr2[(index+j) + 1];
							var v3c:Vertex = varr2[((index+j) + (subdivision + 2))];
							var v4b:Vertex = varr2[((index+j) + (subdivision + 2))];
							var v4c:Vertex = varr2[((index+j) + (subdivision + 1))];
							
							//body + reversed uv's
							if(oRenderside["front"]){
								if(flip){
									addFace(new Face(v1b, v1a, v1c, mf, new UV(1-uvb.u, uvb.v), new UV(1-uva.u, uva.v) , new UV(1-uvc.u, uvc.v) ));
									addFace(new Face(v2b, v2a, v2c, mf, new UV(1-uvc.u, uvc.v), new UV(1-uva.u, uva.v) , new UV(1-uvd.u, uvd.v) ));
								}else{
									addFace(new Face(v1a, v1b, v1c, mf, new UV(1-uva.u, uva.v) , new UV(1-uvb.u, uvb.v), new UV(1-uvc.u, uvc.v) ));
									addFace(new Face(v2a, v2b, v2c, mf, new UV(1-uva.u, uva.v) , new UV(1-uvc.u, uvc.v), new UV(1-uvd.u, uvd.v) ));
								}
							}
							
							if(oRenderside["back"]){
								if(flip){
									addFace(new Face(v3b, v4c, v3a, mb, uvb, uvd, uva ));
									addFace(new Face(v4b, v4c, v3b, mb, uvc, uvd, uvb ));
								}else{
									addFace(new Face(v4c, v3b, v3a, mb, uvd, uvb, uva ));
									addFace(new Face(v4c, v4b, v3b, mb, uvd, uvc, uvb ));
								}
							}
							//bottom
							if(j == 0 && oRenderside["bottom"]){
								addThicknessSubdivision([v2c, v1a], [v4c, v3a], thickness_subdivision, uvd.u, uvb.u, mt , flip);	
							}
							
							//top
							if(j == subdivision-1 && oRenderside["top"]){
								addThicknessSubdivision([v1b, v1c], [v3b, v3c], thickness_subdivision, 1-uva.u, 1-uvc.u, mt , flip);									
							}
							
		 					//left
							if(i == 0 && oRenderside["left"]){
								if(flip){  
									addFace(new Face(v3b, v3a, v1b, mr, new UV(1-uvb.u, uvb.v), new UV(1-uva.u, uva.v), new UV(1-uvc.u, uvc.v) ));
									addFace(new Face(v1b, v3a, v1a, mr, new UV(1-uvc.u, uvc.v), new UV(1-uva.u, uva.v), new UV(1-uvd.u, uvd.v) ));
								} else {
									addFace(new Face(v3a, v3b, v1b, mr, new UV(1-uva.u, uva.v), new UV(1-uvb.u, uvb.v), new UV(1-uvc.u, uvc.v) ));
									addFace(new Face(v3a, v1b, v1a, mr, new UV(1-uva.u, uva.v), new UV(1-uvc.u, uvc.v), new UV(1-uvd.u, uvd.v) ));
								}
								 
							}
							 
							//right 
							if(i == points.length-2 && oRenderside["right"]){
								if(flip){  
									addFace(new Face(v2b, v2c, v3c, ml, new UV(1-uvb.u, uvb.v), new UV(1-uva.u, uva.v), new UV(1-uvc.u, uvc.v) ));
									addFace(new Face(v3c, v2c, v4c, ml, new UV(1-uvc.u, uvc.v), new UV(1-uva.u, uva.v), new UV(1-uvd.u, uvd.v) ));
								} else {
									addFace(new Face(v2c, v2b, v3c, ml, new UV(1-uva.u, uva.v), new UV(1-uvb.u, uvb.v), new UV(1-uvc.u, uvc.v) ));
									addFace(new Face(v2c, v3c, v4c, ml, new UV(1-uva.u, uva.v), new UV(1-uvc.u, uvc.v), new UV(1-uvd.u, uvd.v) ));
								}
								 
							}
							 
						}
					
				}
				
				index += subdivision+1;
				
			}
		}
		
		private function addThicknessSubdivision(points1:Array, points2:Array, subdivision:int, u1:Number, u2:Number, material:* = null, flip:Boolean = false):void
		{			
			var i:int;
			var j:int;
			var stepx:Number;
			var stepy:Number;
			var stepz:Number;
			
			var uva:UV; //downleft
			var uvb:UV; //topleft
			var uvc:UV; //topright
			var uvd:UV; //downright
			
			var va:Vertex;
			var vb:Vertex;
			var vc:Vertex;
			var vd:Vertex;
			var index:int = 0;
			var v1:Number = 0;
			var v2:Number = 0;
			var tmp:Array = [];
			 
			for( i = 0; i < points1.length; ++i){
				stepx = (points2[i].x - points1[i].x) / subdivision;
				stepy = (points2[i].y - points1[i].y) / subdivision;
				stepz = (points2[i].z - points1[i].z)  / subdivision;
				
				for( j = 0; j < subdivision+1; ++j){
					tmp.push( new Vertex( points1[i].x+(stepx*j) , points1[i].y+(stepy*j), points1[i].z+(stepz*j)) );
				}
			}
			
			for( i = 0; i < points1.length-1; ++i){
				 
				for( j = 0; j < subdivision; ++j){
					
					v1 = j/subdivision;
					v2 = (j+1)/subdivision;
					
					uva = new UV( u1 , v1);
					uvb = new UV( u1 , v2 );
					uvc = new UV( u2 , v2 );
					uvd = new UV( u2 , v1 );
						
					va = tmp[index+j];
					vb = tmp[(index+j) + 1];
					vc = tmp[((index+j) + (subdivision + 2))];
					vd = tmp[((index+j) + (subdivision + 1))];
					 
					if(flip){
						addFace(new Face(vb,va,vc, (material == null)? null : material, uvb, uva, uvc ));
						addFace(new Face(vc,va,vd, (material == null)? null : material, uvc, uva, uvd));
					}else{
						addFace(new Face(va,vb,vc, (material == null)? null : material, uva, uvb, uvc ));
						addFace(new Face(va,vc,vd, (material == null)? null : material, uva, uvc, uvd));
					}
				}
				index += subdivision +1;
			}
			
		}
		
		private function elevate(subdivision:int, axis:String, vector:Object, vector2:Object, basemin:Number, basemax:Number, increase:Number):void
		{
			switch(axis){
						case "x":
							uvarr.push(new UV(Math.abs(vector["z"]%basemin), vector["x"]%basemax));
							break;
						case "y":
							uvarr.push(new UV(Math.abs(vector["x"]%basemin), vector["y"]%basemax));
							break;
						case "z":
							uvarr.push(new UV(Math.abs(vector["y"]%basemin), vector["z"]%basemax));
							break;
			}
					
			var j:int;
			for(j = 0; j < subdivision; ++j){
				vector[axis] += increase;
				vector2[axis] += increase;
				 
				switch(axis){
					case "x":
						uvarr.push(new UV(Math.abs(vector["z"]%basemin), vector["x"]%basemax));
						break;
					case "y":
						uvarr.push(new UV(Math.abs(vector["x"]%basemin), vector["y"]%basemax));
						break;
					case "z":
						uvarr.push(new UV(Math.abs(vector["y"]%basemin), vector["z"]%basemax));
						break;
				}
				varr.push(new Vertex(vector["x"],vector["y"],vector["z"]));
				varr2.push(new Vertex(vector2["x"],vector2["y"],vector2["z"]));
				
			}
		}
					
		private function buildThicknessPoints(aPoints:Array, thickness:Number, prop1:String, prop2:String, closepath:Boolean):Array
		{
			var Anchors:Array = [];
			var Lines:Array = [];
			var i:int;
			
			for( i = 0;i<aPoints.length-1;++i){
				if(aPoints[i][prop1] == 0 && aPoints[i][prop2] == 0){
					aPoints[i][prop1] = .0001;
				}
				if(aPoints[i+1][prop2] != null && aPoints[i][prop2] == aPoints[i+1][prop2]){
					aPoints[i+1][prop2] += .0001;
				}
				if(aPoints[i][prop1] != null && aPoints[i][prop1]  == aPoints[i+1][prop1]){
					aPoints[i+1][prop1] += .0001;
				}
				Anchors.push(defineAnchors(aPoints[i], aPoints[i+1], thickness, prop1, prop2 ));
			}
			
			var totallength:int = Anchors.length;
			var oPointResult:Object;
			
			if(totallength>1){
				
				for(i = 0;i<totallength;++i){
					if(i < totallength){
						oPointResult = defineLines(i, Anchors[i], Anchors[i+1], Lines);
					} else{
						oPointResult = defineLines(i, Anchors[i], Anchors[i-1], Lines);
					}
					if(oPointResult != null) Lines.push(oPointResult);
				}
				
				if(closepath && Anchors.length > 2){
					Anchors.push(defineAnchors(aPoints[Anchors.length-1], aPoints[0], thickness, prop1, prop2 ));
					var tmparray:Array = [Anchors[Anchors.length-1], Anchors[0] , Anchors[1], Anchors[2] ];
					var tmplines:Array = [];
					for(i = 0;i<2;++i){	
						 oPointResult = defineLines(i, tmparray[i], tmparray[i+1], tmparray);
						 if(oPointResult != null) tmplines.push(oPointResult);
					}
					Lines[0]["pt1"] = tmplines[0]["pt3"];
					Lines[0]["pt2"] = tmplines[0]["pt4"];
					Lines[0]["pt3"] = tmplines[1]["pt1"];
					Lines[0]["pt4"] = tmplines[1]["pt2"];
					Lines[Lines.length-1]["pt3"] = tmplines[0]["pt3"];
					Lines[Lines.length-1]["pt4"] = tmplines[0]["pt4"];
				}
				
			} else{
				Lines = [{pt1:Anchors[0]["pt1"], pt2:Anchors[0]["pt2"], pt3:Anchors[0]["pt3"], pt4:Anchors[0]["pt4"]}];
			}
 
			return  Lines;
		}
		 
		
		private function defineLines(index:int, oPoint1:Object, oPoint2:Object = null, Lines:Array = null):Object
		{
			var tmppt:Object = Lines[index -1];
			if(oPoint2 == null)  return {pt1:tmppt["pt3"], pt2:tmppt["pt4"], pt3:oPoint1["pt3"], pt4:oPoint1["pt4"]}; 
			 
			var oLine1:Object = buildObjectLine(oPoint1["pt1"].x,oPoint1["pt1"].y,oPoint1["pt3"].x,oPoint1["pt3"].y);
			var oLine2:Object = buildObjectLine(oPoint1["pt2"].x,oPoint1["pt2"].y,oPoint1["pt4"].x,oPoint1["pt4"].y);
			var oLine3:Object = buildObjectLine(oPoint2["pt1"].x,oPoint2["pt1"].y,oPoint2["pt3"].x,oPoint2["pt3"].y);
			var oLine4:Object = buildObjectLine(oPoint2["pt2"].x,oPoint2["pt2"].y,oPoint2["pt4"].x,oPoint2["pt4"].y);
			
			var cross1:Point = lineIntersect (oLine3, oLine1);
			var cross2:Point = lineIntersect (oLine2, oLine4);
		
			if(cross1 != null && cross2 != null){
				
				if(index == 0)  return {pt1:oPoint1["pt1"], pt2:oPoint1["pt2"], pt3:cross1, pt4:cross2}; 
				return {pt1:tmppt["pt3"], pt2:tmppt["pt4"], pt3:cross1, pt4:cross2};
				
			} else {
				return null;
			} 
		}
		
		
		private function defineAnchors(base:Number3D, baseEnd:Number3D, thickness:Number, prop1:String, prop2:String):Object
		{
			var angle:Number =   (Math.atan2(base[prop2] - baseEnd[prop2], base[prop1] - baseEnd[prop1])* 180)/ Math.PI;
			angle -=270;
			var angle2:Number = angle+180;
			//origin points
			var pt1:Point = new Point(base[prop1], base[prop2]);
			var pt2:Point = new Point(base[prop1], base[prop2]);

			//dest points
			var pt3:Point = new Point(baseEnd[prop1], baseEnd[prop2]);
			var pt4:Point = new Point(baseEnd[prop1], baseEnd[prop2]);
			
			var radius:Number = thickness*.5;
			
			pt1.x = pt1.x+Math.cos(-angle/180*Math.PI)*radius;
			pt1.y = pt1.y+Math.sin(angle/180*Math.PI)*radius;
			
			pt2.x = pt2.x+Math.cos(-angle2/180*Math.PI)*radius;
			pt2.y = pt2.y+Math.sin(angle2/180*Math.PI)*radius;
			
			pt3.x = pt3.x+Math.cos(-angle/180*Math.PI)*radius;
			pt3.y = pt3.y+Math.sin(angle/180*Math.PI)*radius;
			
			pt4.x = pt4.x+Math.cos(-angle2/180*Math.PI)*radius;
			pt4.y = pt4.y+Math.sin(angle2/180*Math.PI)*radius;
			
			return {pt1:pt1, pt2:pt2, pt3:pt3, pt4:pt4};
		}
		
		
		private function buildObjectLine(origX:Number, origY:Number, endX:Number, endY:Number):Object
		{        
			return {ax:origX, ay:origY, bx:endX - origX, by:endY - origY};
		}
		
		
		private function lineIntersect (Line1:Object, Line2:Object):Point
		{
			Line1["bx"] = (Line1["bx"] == 0)? 0.0001 : Line1["bx"];
			Line2["bx"] = (Line2["bx"] == 0)? 0.0001 : Line2["bx"];
			
			var a1:Number = Line1["by"] / Line1["bx"];
			var b1:Number = Line1["ay"] - a1 * Line1["ax"];
			var a2:Number = Line2["by"] / Line2["bx"];
			var b2:Number = Line2["ay"] - a2 * Line2["ax"];
			var nzero:Number =  ((a1 - a2) == 0)? 0.0001 : a1 - a2;
			var ptx:Number = ( b2 - b1 )/(nzero);
			var pty:Number = a1 * ptx + b1;
			
			if(isFinite(ptx) && isFinite(pty)){
				return new Point(ptx, pty);
			} else {
				trace("infinity");
				return null;
			}
		}
		
	}
	
}
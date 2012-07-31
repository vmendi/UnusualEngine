﻿package away3d.extrusions
{
	import away3d.core.math.*;
	import away3d.core.base.*;
	import away3d.core.utils.*;
	import flash.geom.Point;

	/**
	* Class Lathe generates circular meshes such as donuts, pipes, pyramids etc.. from a series of Number3D's<Lathe></code>
	* 
	*/
	public class Lathe extends Mesh
	{
		private var varr:Array = [];
		private var varr2:Array = [];
		private var uvarr:Array = [];
		
		/**
		*  Class Lathe generates circular meshes such as donuts, pipes, pyramids etc.. from a series of Number3D's
		*
		* @param	aPoints		Array. An array of Number3D's. minimum 2 Number3D's required.
		* @param	init			[optional]	An initialisation object for specifying default instance properties.
		*
		* properties of the init object are:
		* material:IMaterial, material for the Lathe object.
		* materials:Object, if the Lathe object must have more materials: o.left, o.right, o.front, o.back, o.bottom, o.top and o.back. Default is null.
		* axis:String, the axis to rotate around, default is "y".
		* rotations:Number. The lath object can have less than one rotation, like 0.6 for a piechart or 3 if a tweek object is past. Default is 1, minimum is 0.01.
		* subdivision:int, howmany segments will compose the mesh in its rotational construction. default is 2, its the minimum as well.
		* offsetradius:Number. An offset radius for the Lathe object. Default is 0.
		* scaling:Number. A scale value. default is 1.
		* omit:String. If you want the bottom is not generated: omit:"bottom", both top and bottom: omit:"bottom, top"
		* tweek:Object. default is null; to build springs like shapes, rotation must be higher than 1. properties of the objects are x,y,z,radius and rotation
		* thickness:Number, if the shape must simulate a thickness. Default is 0.
		* coverall:Boolean, The way the mappig is done. true covers the entire side of the geometry, false, per segments. Default is true.
		* recenter:Boolean, If the geometry needs to be recentered in its own object space. Default is false.
		* flip:Boolean. If the faces must be reversed depending on number3D's orientation. default is false.
		*/
		public function Lathe(aPoints:Array, init:Object = null)
		{
			if (init["material"] != null) {
				init["materials"] = {defaultmaterial:init["material"]};
			}
			
			if (init["material"] == null && init["materials"] != null) {
				init["material"] = init["materials"].defaultmaterial;
			}
			
			super(init);

			var axis:String = ini.getString("axis", "y");
			var rotations:Number = ini.getNumber("rotations", 1, {min:0.01});
			var subdivision:int = ini.getInt("subdivision", 2, {min:2});
			var offsetradius:int = ini.getNumber("offsetradius", 0);
			var scaling:Number = ini.getNumber("scaling", 1);
			var omat:Object = ini.getObject("materials", null);
			var omit:String = ini.getString("omit", "");
			var tweek:Object = ini.getObject("tweek", null);
			var thickness:Number = ini.getNumber("thickness", 0, {min:0});
			var coverall:Boolean = ini.getBoolean("coverall", true);
			var recenter:Boolean = ini.getBoolean("recenter", false);
			var flip:Boolean = ini.getBoolean("flip", false);

			if (scaling != 1) {
				for (var i:int = 0; i < aPoints.length; ++i) {
					aPoints[i]["x"] *= scaling;
					aPoints[i]["y"] *= scaling;
					aPoints[i]["z"] *= scaling;
				}
			}
			
			if (aPoints.length > 1) {
				tweek = (tweek == null)? {x:0, y:0, z:0, radius:0, rotation:0} : tweek;

				if (thickness != 0) {

					var prop1:String;
					var prop2:String;
					var prop3:String;

					switch (axis) {
						case "x" :
							prop1 = "x";
							prop2 = "z";
							prop3 = "y";
							break;

						case "y" :
							prop1 = "y";
							prop2 = "x";
							prop3 = "z";
							break;

						case "z" :
							prop1 = "z";
							prop2 = "y";
							prop3 = "x";
					}
					var Lines:Array = buildThicknessPoints(aPoints, thickness, prop1, prop2);
					generateWithThickness(aPoints, Lines, axis, prop1, prop2, prop3, offsetradius, rotations, subdivision, tweek, coverall, omat, omit, flip);

				} else {
					generate(aPoints, axis, offsetradius, rotations, subdivision, tweek, coverall, flip);

				}
				
			} else {
				
				trace("Lathe error: at least 2 number3D are required!");
			}
			
			varr = null;
			varr2 = null;
			uvarr = null;

			if (recenter) {
				applyPosition( (this.minX+this.maxX)*.5,  (this.minY+this.maxY)*.5, (this.minZ+this.maxZ)*.5);
			} else {
				x =  aPoints[0]["x"];
				y =  aPoints[0]["y"];
				z =  aPoints[0]["z"];
			}
			
			type = "Lathe";
			url = "Extrude";
		}
		
		private function generateWithThickness(points:Array, Lines:Array, axis:String, prop1:String, prop2:String, prop3:String, offsetradius:Number, rotations:Number, subdivision:Number, tweek:Object, coverall:Boolean, oMat:Object = null, omit:String = "", flip:Boolean = false):void
		{		
			var i:int;
			
			var aListsides:Array = ["top","bottom", "right", "left", "front", "back"];
			var oRenderside:Object = {};
			for(i = 0;i<aListsides.length;++i){
				oRenderside[aListsides[i]] = (omit.indexOf(aListsides[i]) == -1);
			}
			
			var oPoints:Object;
			var vector:Number3D;
			var vector2:Number3D;
			var vector3:Number3D;
			var vector4:Number3D;
			var aPointlist1:Array = new Array();
			var aPointlist2:Array = new Array();
			
			for(i = 0;i<Lines.length;++i){
				
				oPoints = Lines[i];
				vector = new Number3D();
				vector2 = new Number3D();
				 
				if(i == 0){
					vector[prop1] = Number(oPoints["pt2"].x.toFixed(4));
					vector[prop2] = Number(oPoints["pt2"].y.toFixed(4));
					vector[prop3] = points[0][prop3];
					aPointlist1.push(vector);
					
					vector2[prop1] = Number(oPoints["pt1"].x.toFixed(4));
					vector2[prop2] = Number(oPoints["pt1"].y.toFixed(4));
					vector2[prop3] = points[0][prop3];
					aPointlist2.push(vector2);
					 
					if(Lines.length == 1) {
						vector3 = new Number3D();
						vector4 = new Number3D();
						
						vector3[prop1] = Number(oPoints["pt4"].x.toFixed(4));
						vector3[prop2] = Number(oPoints["pt4"].y.toFixed(4));
						vector3[prop3] = points[0][prop3];
						aPointlist1.push(vector3);
						
						vector4[prop1] = Number(oPoints["pt3"].x.toFixed(4));
						vector4[prop2] = Number(oPoints["pt3"].y.toFixed(4));
						vector4[prop3] = points[0][prop3];						
						aPointlist2.push(vector4);
						 
					} 
					 
				} else if (i == Lines.length-1) {
					 
					vector[prop1] = oPoints["pt2"].x;
					vector[prop2] = oPoints["pt2"].y;
					vector[prop3] = points[i][prop3];
					aPointlist1.push(vector);
					
					vector2[prop1] = oPoints["pt1"].x;
					vector2[prop2] = oPoints["pt1"].y;
					vector2[prop3] = points[i][prop3];
					aPointlist2.push(vector2);
					 
					vector3 = new Number3D();
					vector4 = new Number3D();
					
					vector3[prop1] = oPoints["pt4"].x;
					vector3[prop2] = oPoints["pt4"].y;
					vector3[prop3] = points[i][prop3];
					aPointlist1.push(vector3);
					
					vector4[prop1] = oPoints["pt3"].x;
					vector4[prop2] = oPoints["pt3"].y;
					vector4[prop3] = points[i][prop3];
					aPointlist2.push(vector4);
					
				} else {
					 
					vector[prop1] = oPoints["pt2"].x;
					vector[prop2] = oPoints["pt2"].y;
					vector[prop3] = points[i][prop3];
					aPointlist1.push(vector);
					
					vector2[prop1] = oPoints["pt1"].x;
					vector2[prop2] = oPoints["pt1"].y;
					vector2[prop3] = points[i][prop3];						
					aPointlist2.push(vector2);
				}
				
			}
			
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
				
			varr = new Array();
			generate(aPointlist1, axis, offsetradius, rotations, subdivision, tweek, coverall, false, mf, oRenderside["front"], flip);
			varr2 = new Array();
			varr2 = varr2.concat(varr);
			varr = new Array();
			generate(aPointlist2, axis, offsetradius, rotations, subdivision, tweek, coverall, true, mb, oRenderside["back"], flip);

			if (rotations != 1) {
				closeSides(points.length, coverall, mr, ml, oRenderside, flip);
			}
			
			closeTopBottom(points.length, coverall, mt, mbo, oRenderside, flip);
				
		}
		
		private function closeTopBottom(pointslength:int, coverall:Boolean, matTop:*, matBottom:*, oRenderside:Object, flip:Boolean):void
		{
			//add top and bottom
			var uva:UV;
			var uvb:UV;
			var uvc:UV;
			var uvd:UV;

			var facea:Vertex;
			var faceb:Vertex;
			var facec:Vertex;
			var faced:Vertex;
			var index:int = 0;
			
			var i:int;
			var j:int;
			var a:Number;
			var b:Number;

			var total:int = varr.length-(pointslength+1);
			var inc:int = pointslength;

			for (i = 0; i < total; i+= inc) {

				if (i!= 0) {
					
					if (coverall) {
						a = i/total;
						b = (i+inc)/total;
						uva = new UV(0, a );
						uvb = new UV(0, b );
						uvc = new UV(1, b );
						uvd = new UV(1, a );

					} else {
						uva = new UV(0, 0);//downleft
						uvb = new UV(0, 1 );//topleft
						uvc = new UV(1, 1);//topright
						uvd = new UV(1, 0);//downright
					}
					
					if (oRenderside["top"]) {
						facea = new Vertex(varr[i].x,varr[i].y,varr[i].z);
						faceb = new Vertex(varr[i+(inc)].x, varr[i+(inc)].y, varr[i+(inc)].z);
						facec = new Vertex(varr2[i+(inc)].x, varr2[i+(inc)].y, varr2[i+(inc)].z);
						faced =  new Vertex(varr2[i].x, varr2[i].y, varr2[i].z);

						if (flip) {
							addFace( new Face(facea, faceb, facec, matTop, uva, uvb, uvc ) );
							addFace( new Face(facea, facec, faced, matTop, uva, uvc, uvd ) );
						} else {
							addFace( new Face(faceb, facea, facec, matTop, uvb, uva, uvc ) );
							addFace( new Face(facec, facea, faced, matTop, uvc, uva, uvd ) );
						}
					}
					
					if (oRenderside["bottom"]) {
						j = i+inc-1;
						facea = new Vertex(varr[j].x,varr[j].y,varr[j].z);
						faceb = new Vertex(varr[j+(inc)].x, varr[j+(inc)].y, varr[j+(inc)].z);
						facec = new Vertex(varr2[j+(inc)].x, varr2[j+(inc)].y, varr2[j+(inc)].z);
						faced =  new Vertex(varr2[j].x,varr2[j].y,varr2[j].z);

						if (flip) {
							addFace( new Face(faceb, facea, facec, matBottom, uvb, uva, uvc ) );
							addFace( new Face(facec, facea, faced, matBottom, uvc, uva, uvd ) );
						} else {
							addFace( new Face(facea, faceb, facec, matBottom, uva, uvb, uvc ) );
							addFace( new Face(facea, facec, faced, matBottom, uva, uvc, uvd ) );
						}
					}
				}
				
				index += pointslength;
			}
		}
		
		private function closeSides(pointcount:int, coverall:Boolean, matRight:*, matLeft:*, oRenderside:Object, flip:Boolean):void
		{
			var uva:UV;
			var uvb:UV;
			var uvc:UV;
			var uvd:UV;
			var facea:Vertex;
			var faceb:Vertex;
			var facec:Vertex;
			var faced:Vertex;

			var offset:Number = varr.length - pointcount;
			var i:int;
			var j:int;
			var a:Number;
			var b:Number;
			
			var iter:int = pointcount-1;
			var step:Number = 1/iter;
			
			for (i = 0; i<iter; ++i) {

				if (coverall) {
					a = i/iter;
					b = a+step;
					uva = new UV(0, a );
					uvb = new UV(0, b );
					uvc = new UV(1, b );
					uvd = new UV(1, a );
				} else {
					uva = new UV(0, 0);
					uvb = new UV(0, 1 );
					uvc = new UV(1, 1);
					uvd = new UV(1, 0);
				}
				
				if (oRenderside["left"]) {
					facea = new Vertex(varr[i+1].x,varr[i+1].y,varr[i+1].z);
					faceb = new Vertex(varr[i].x, varr[i].y, varr[i].z);
					facec = new Vertex(varr2[i].x, varr2[i].y, varr2[i].z);
					faced = new Vertex(varr2[i+1].x, varr2[i+1].y, varr2[i+1].z);

					if (flip) {
						addFace( new Face(facea, faceb, facec, matLeft, uva, uvb, uvc ) );
						addFace( new Face(facea, facec, faced, matLeft, uva, uvc, uvd ) );
					} else {
						addFace( new Face(faceb, facea, facec, matLeft, uvb, uva, uvc ) );
						addFace( new Face(facec, facea, faced, matLeft, uvc, uva, uvd ) );
					}
				}
				
				if (oRenderside["right"]) {
					j = offset+i;
					facea = new Vertex(varr[j + 1].x,varr[j + 1].y,varr[j + 1].z);
					faceb = new Vertex(varr[j ].x, varr[j ].y, varr[j].z);
					facec = new Vertex(varr2[j].x, varr2[j].y, varr2[j].z);
					faced = new Vertex(varr2[j + 1].x, varr2[j + 1].y, varr2[j + 1].z);

					if (flip) {
						addFace( new Face(faceb, facea, facec, matRight, uvb, uva, uvc ) );
						addFace( new Face(facec, facea, faced, matRight, uvc, uva, uvd ) );
					} else {
						addFace( new Face(facea, faceb, facec, matRight, uva, uvb, uvc ) );
						addFace( new Face(facea, facec, faced, matRight, uva, uvc, uvd ) );
					}
				}
				
			}
		}

		private function generate(aPoints:Array, axis:String, offsetradius:Number, rotations:Number, subdivision:Number, tweek:Object, coverall:Boolean, inside:Boolean = false, mat:* = null, render:Boolean = true, flip:Boolean = false):void
		{
			
			if (isNaN(tweek["x"]) || !tweek["x"]) tweek["x"] = 0;
			if (isNaN(tweek["y"]) || !tweek["y"]) tweek["y"] = 0;
			if (isNaN(tweek["z"]) || !tweek["z"]) tweek["z"] = 0;
			if (isNaN(tweek["radius"]) || !tweek["radius"]) tweek["radius"] = 0;
			 
			var angle:Number = 0;
			var step:Number = 360 / subdivision;			 
			var j:int;
			
			var tweekX:Number = 0;
			var tweekY:Number = 0;
			var tweekZ:Number = 0;
			var tweekradius:Number = 0;
			var tweekrotation:Number = 0;
			
			var tmpPoints:Array;
			var aRads:Array = [];			
			
			var nuv1:Number;
			var nuv2:Number;
			
			for (var i:int = 0; i < aPoints.length; ++i) {
				varr.push(new Vertex(aPoints[i].x, aPoints[i].y, aPoints[i].z) );
				uvarr.push(new UV(0,1%i)); 
			}
			  
			//Vertex generation
			offsetradius = -offsetradius;
			var factor:Number = 0;
			
			for (i = 0; i <= subdivision * rotations; ++i) {
				
				tmpPoints = [];
				tmpPoints = aPoints.concat();
				
				for(j = 0;j<tmpPoints.length;++j){
					
					factor = ((rotations-1)/(varr.length+1));
				
					if(tweek["x"] != 0)
						tweekX += (tweek["x"] * factor)/rotations;
						
					if(tweek["y"] != 0)
						tweekY += (tweek["y"] * factor)/rotations;
						
					if(tweek["z"] != 0)
						tweekZ += (tweek["z"] * factor)/rotations;
						
					if(tweek["radius"] != 0)
						tweekradius += (tweek["radius"]/(varr.length+1));
						
					if(tweek["rotation"] != 0)
						tweekrotation +=  360/(tweek["rotation"]*subdivision);
						 
					if (axis == "x") {
							if(i==0) aRads[j] = offsetradius-Math.abs(tmpPoints[j].z);
							 
							tmpPoints[j].z = Math.cos(-angle/180*Math.PI) * (aRads[j] + tweekradius );
							tmpPoints[j].y = Math.sin(angle/180*Math.PI) * (aRads[j] + tweekradius );
							
							if(i == 0){
								varr[j].z += tmpPoints[j].z;
								varr[j].y += tmpPoints[j].y;
							}
							 
					} else if (axis == "y") {
							if(i==0) aRads[j] = offsetradius-Math.abs(tmpPoints[j].x);
							 
							tmpPoints[j].x = Math.cos(-angle/180*Math.PI) *  (aRads[j] + tweekradius );
							tmpPoints[j].z = Math.sin(angle/180*Math.PI) * (aRads[j] + tweekradius );
							 
							if(i == 0){
								varr[j].x = tmpPoints[j].x;
								varr[j].z = tmpPoints[j].z;
							}
							 
					} else {
							if(i==0) aRads[j] = offsetradius-Math.abs(tmpPoints[j].y);
							 
							tmpPoints[j].x = Math.cos(-angle/180*Math.PI) * (aRads[j] + tweekradius );
							tmpPoints[j].y = Math.sin(angle/180*Math.PI) * (aRads[j] + tweekradius );
							
							if(i == 0){
								varr[j].x = tmpPoints[j].x;
								varr[j].y = tmpPoints[j].y;
							}
							
					}
					
					tmpPoints[j].x += tweekX;
					tmpPoints[j].y += tweekY;
					tmpPoints[j].z += tweekZ;
					
					varr.push(new Vertex(tmpPoints[j].x, tmpPoints[j].y, tmpPoints[j].z) );
					
					if(coverall) {
						nuv1 =   angle/(360*rotations);
					} else {
						nuv1 =  (i%2 == 0)? 0 : 1;
					}
					nuv2 =1-(j/(tmpPoints.length-1));
					uvarr.push(new UV(nuv1, nuv2));
				 }
				 
				angle += step;
				
			}
			
			if (render) {

				var index:int;
				var inc:int = aPoints.length;
				var loop:int = varr.length - aPoints.length;

				for (i = 0; i < loop; i += inc) {
					index = 0;
					for (j = 1; j < aPoints.length; ++j) {

						if (i>0) {
							var uva:UV = uvarr[i + (index + 1)];
							var uvb:UV = uvarr[i + index];
							var uvc:UV = uvarr[i + index + aPoints.length];
							var uvd:UV = uvarr[i + index + aPoints.length + 1];

							var facea:Vertex = new Vertex(varr[i + (index + 1)].x,varr[i + (index + 1)].y,varr[i + (index + 1)].z);
							var faceb:Vertex = new Vertex(varr[i + index].x, varr[i + index].y, varr[i + index].z);
							var facec:Vertex = new Vertex(varr[i + index + aPoints.length].x, varr[i + index + aPoints.length].y, varr[i + index + aPoints.length].z);
							var faced:Vertex = new Vertex(varr[i + index + aPoints.length + 1].x, varr[i + index + aPoints.length + 1].y, varr[i + index + aPoints.length + 1].z);

							if (flip) {
								
								if (inside) {
									addFace( new Face(faceb, facea, facec, mat, new UV(1-uvb.u, uvb.v), new UV(1-uva.u, uva.v), new UV(1-uvc.u, uvc.v) ) );
									addFace( new Face(facec, facea, faced, mat, new UV(1-uvc.u, uvc.v), new UV(1-uva.u, uva.v), new UV(1-uvd.u, uvd.v)  ) );
								} else {
									addFace( new Face(facea, faceb, facec, mat, uva, uvb, uvc ) );
									addFace( new Face(facea, facec, faced, mat, uva, uvc, uvd ) );
								}
								
							} else {
								
								if (inside) {
									addFace( new Face(facea, faceb, facec, mat, new UV(1-uva.u, uva.v), new UV(1-uvb.u, uvb.v), new UV(1-uvc.u, uvc.v) ) );
									addFace( new Face(facea, facec, faced, mat, new UV(1-uva.u, uva.v), new UV(1-uvc.u, uvc.v), new UV(1-uvd.u, uvd.v)  ) );
								} else {
									addFace( new Face(faceb, facea, facec, mat, uvb, uva, uvc ) );
									addFace( new Face(facec, facea, faced, mat, uvc, uva, uvd ) );
								}
							}
						}
						
						index++;
					}
				}
			}
			
		}

		//
		private function buildThicknessPoints(aPoints:Array, thickness:Number, prop1:String, prop2:String):Array
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
			angle -= 270;
			var angle2:Number = angle+180;
			
			var pt1:Point = new Point(base[prop1], base[prop2]);
			var pt2:Point = new Point(base[prop1], base[prop2]);
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
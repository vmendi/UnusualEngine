﻿package away3d.extrusions
{
    import away3d.core.base.*;
    import away3d.core.utils.*;

	public class SkinExtrude extends Mesh
	{
		private var varr:Array;
				
        public function SkinExtrude(aPoints:Array, init:Object = null)
        {
		 	super(init);

            var subdivision:int = ini.getInt("subdivision", 1, {min:1});
			var coverall:Boolean = ini.getBoolean("coverall", false);
			var recenter:Boolean = ini.getBoolean("recenter", false);
			var closepath:Boolean = ini.getBoolean("closepath", false);
			var flip:Boolean = ini.getBoolean("flip", false);
			 
			if(aPoints[0] is Array && aPoints[0].length>1){
				if(closepath && aPoints.length <= 2) closepath = false;
				generate(aPoints, subdivision, coverall, closepath, flip);
			} else{
				trace("SkinExtrude, at least 2 series of minimum 2 points are required per extrude!");
			}
			 
			if(recenter) {
				applyPosition( (this.minX+this.maxX)*.5,  (this.minY+this.maxY)*.5, (this.minZ+this.maxZ)*.5);
			} else {
				x =  aPoints[0][0].x;
				y =  aPoints[0][0].y;
				z =  aPoints[0][0].z;
			}
			
			varr = null;

			type = "SkinExtrude";
        	url = "Extrude";
        }
		
		
		private function generate(aPoints:Array, subdivision:int = 1,  coverall:Boolean = false, closepath:Boolean = false, flip:Boolean = false):void
		{	
			var uvlength:int = (closepath)? aPoints.length : aPoints.length-1;
			for(var i:int = 0;i<aPoints.length-1;++i){
				varr = [];
				extrudePoints(aPoints[i], aPoints[i+1], subdivision, coverall, (1/uvlength)*i, uvlength, flip);
			}
			if(closepath){
				varr = [];
				extrudePoints(aPoints[aPoints.length-1], aPoints[0], subdivision, coverall, (1/uvlength)*i, uvlength, flip);
			}
		}
			 
		
		private function extrudePoints(points1:Array, points2:Array, subdivision:int, coverall:Boolean, vscale:Number, indexv:int, flip:Boolean):void
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
			
			var u1:Number;
			var u2:Number;
			var index:int = 0;

			var bu:Number = 0;
			var bincu:Number = 1/(points1.length-1);
			var v1:Number = 0;
			var v2:Number = 0;
			 
			for( i = 0; i < points1.length; ++i){
				stepx = (points2[i].x - points1[i].x) / subdivision;
				stepy = (points2[i].y - points1[i].y) / subdivision;
				stepz = (points2[i].z - points1[i].z)  / subdivision;
				
				for( j = 0; j < subdivision+1; ++j){
					varr.push( new Vertex( points1[i].x+(stepx*j) , points1[i].y+(stepy*j), points1[i].z+(stepz*j)) );
				}
			}
			
			
			for( i = 0; i < points1.length-1; ++i){
				u1 = bu;
				bu += bincu;
				u2 = bu;
				
				for( j = 0; j < subdivision; ++j){
					
					v1 = (coverall)? vscale+((j/subdivision)/indexv) :  j/subdivision;
					v2 = (coverall)? vscale+(( (j+1)/subdivision)/indexv) :  (j+1)/subdivision;
					
					uva = new UV( u1 , v1);
					uvb = new UV( u1 , v2 );
					uvc = new UV( u2 , v2 );
					uvd = new UV( u2 , v1 );
						
					va = varr[index+j];
					vb = varr[(index+j) + 1];
					vc = varr[((index+j) + (subdivision + 2))];
					vd = varr[((index+j) + (subdivision + 1))];
					 
					if(flip){
						addFace(new Face(va,vb,vc, null, uva, uvb, uvc ));
						addFace(new Face(va,vc,vd, null, uva, uvc, uvd));
					}else{
						addFace(new Face(vb,va,vc, null, uvb, uva, uvc ));
						addFace(new Face(vc,va,vd, null, uvc, uva, uvd));						
					}
				}
				index += subdivision +1;
			}
			
		}
		
	}
	
}
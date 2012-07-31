﻿package away3d.primitives{
	
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.math.*;
	import away3d.extrusions.Lathe;
	import away3d.materials.WireframeMaterial;
	import away3d.primitives.LineSegment;
    
    /**
    * Creates an axis trident.
    */ 
	public class Trident extends ObjectContainer3D
	{
		
		/**
		 * Creates a new <code>Trident</code> object.
		 *
		 * @param	 len				The length of the trident axes. Default is 1000.
		 * @param	 showLetters	If the Trident should display the letters X. Y and Z.
		 */
		 
		public function Trident(len:Number = 1000, showLetters:Boolean = false)
		{
			buildTrident(len, showLetters);
		}
		
		private function addArrowSegments(a:Vertex, b:Vertex, mat:WireframeMaterial, x:Number = 0, y:Number = 0, z:Number = 0):void
		{
			var line:LineSegment = new LineSegment({material:mat});
			line.start = new Vertex(a.x+x, a.y+y, a.z+z);
			line.end = new Vertex(b.x+x, b.y+y, b.z+z);
			addChild(line);
		}
		
		private function buildTrident(len:Number, showLetters:Boolean):void
		{
			var scaleH:Number = len/10;
			var scaleW:Number = len/20;
			var offset:Number = len-scaleW;
			
			var matx:WireframeMaterial = new WireframeMaterial( 0xFF0000, {width:0});
			var maty:WireframeMaterial = new WireframeMaterial( 0x00FF00, {width:1});
			var matz:WireframeMaterial = new WireframeMaterial( 0x0000FF, {width:0});
			var lineX:LineSegment = new LineSegment({material:matx});
			var lineY:LineSegment = new LineSegment({material:maty});
			var lineZ:LineSegment = new LineSegment({material:matz});
			
			var arrowx:Lathe = new Lathe([new Number3D(0,0,0), new Number3D(-scaleW,0,0), new Number3D(0,scaleH,0)], {recenter:true, subdivision:4, material:null});
			(arrowx as Mesh).rotationZ = -90;
			(arrowx as Mesh).applyRotations();
			
			addArrowSegments((arrowx as Mesh).vertices[5], (arrowx as Mesh).vertices[3], matx, offset, 0, 0);
			addArrowSegments((arrowx as Mesh).vertices[5], (arrowx as Mesh).vertices[4], matx, offset, 0, 0);
			addArrowSegments((arrowx as Mesh).vertices[4], (arrowx as Mesh).vertices[6], matx, offset, 0, 0);
			addArrowSegments((arrowx as Mesh).vertices[5], (arrowx as Mesh).vertices[11], matx, offset, 0, 0);
			addArrowSegments((arrowx as Mesh).vertices[6], (arrowx as Mesh).vertices[11], matx, offset, 0, 0);
			addArrowSegments((arrowx as Mesh).vertices[5], (arrowx as Mesh).vertices[19], matx, offset, 0, 0);
			addArrowSegments((arrowx as Mesh).vertices[19], (arrowx as Mesh).vertices[11], matx, offset, 0, 0);
			addArrowSegments((arrowx as Mesh).vertices[19], (arrowx as Mesh).vertices[4], matx, offset, 0, 0);
			
			var arrowy:Lathe = new Lathe([new Number3D(0,0,0), new Number3D(-scaleW,0,0), new Number3D(0,scaleH,0)], {recenter:true, subdivision:4, material:null});
			addArrowSegments((arrowy as Mesh).vertices[5], (arrowy as Mesh).vertices[3], maty, 0, offset, 0);
			addArrowSegments((arrowy as Mesh).vertices[5], (arrowy as Mesh).vertices[4], maty, 0, offset, 0);
			addArrowSegments((arrowy as Mesh).vertices[4], (arrowy as Mesh).vertices[6], maty, 0, offset, 0);
			addArrowSegments((arrowy as Mesh).vertices[5], (arrowy as Mesh).vertices[11], maty, 0, offset, 0);
			addArrowSegments((arrowy as Mesh).vertices[6], (arrowy as Mesh).vertices[11], maty, 0, offset, 0);
			addArrowSegments((arrowy as Mesh).vertices[5], (arrowy as Mesh).vertices[19], maty, 0, offset, 0);
			addArrowSegments((arrowy as Mesh).vertices[19], (arrowy as Mesh).vertices[11], maty, 0, offset, 0);
			addArrowSegments((arrowy as Mesh).vertices[19], (arrowy as Mesh).vertices[4], maty, 0, offset, 0);
			
			var arrowz:Lathe = new Lathe([new Number3D(0,0,0), new Number3D(-scaleW,0,0), new Number3D(0,scaleH,0)], {recenter:true, subdivision:4, material:null});
			arrowz.rotationX = 90;
			(arrowz as Mesh).applyRotations();
			addArrowSegments((arrowz as Mesh).vertices[5], (arrowz as Mesh).vertices[3], matz, 0, 0, offset);
			addArrowSegments((arrowz as Mesh).vertices[5], (arrowz as Mesh).vertices[4], matz, 0, 0, offset);
			addArrowSegments((arrowz as Mesh).vertices[4], (arrowz as Mesh).vertices[6], matz, 0, 0, offset);
			addArrowSegments((arrowz as Mesh).vertices[5], (arrowz as Mesh).vertices[11], matz, 0, 0, offset);
			addArrowSegments((arrowz as Mesh).vertices[6], (arrowz as Mesh).vertices[11], matz, 0, 0, offset);
			addArrowSegments((arrowz as Mesh).vertices[5], (arrowz as Mesh).vertices[19], matz, 0, 0, offset);
			addArrowSegments((arrowz as Mesh).vertices[19], (arrowz as Mesh).vertices[11], matz, 0, 0, offset);
			addArrowSegments((arrowz as Mesh).vertices[19], (arrowz as Mesh).vertices[4], matz, 0, 0, offset);
			
			arrowx = arrowy = arrowz = null;
			//x
			lineX.start = new Vertex(0,0,0);
			lineX.end = new Vertex(len,0,0);
			addChild(lineX);
			//y
			lineY.start = new Vertex(0,0,0);
			lineY.end = new Vertex(0,len,0);
			addChild(lineY);
			//z
			lineZ.start = new Vertex(0,0,0);
			lineZ.end = new Vertex(0,0,len);
			addChild(lineZ);
			
			if(showLetters){
				//x
				var scl15:Number = scaleW*1.5;
				var sclh3:Number = scaleH*3;
				var sclh2:Number = scaleH*2;
				var sclh34:Number = scaleH*3.4;
				var x1:LineSegment = new LineSegment({material:matx});
				x1.start = new Vertex(len+sclh3, scl15 , 0);
				x1.end = new Vertex(len+sclh2, -scl15 , 0);
				var x2:LineSegment = new LineSegment({material:matx});
				x2.start = new Vertex(len+sclh2, scl15 , 0);
				x2.end = new Vertex(len+sclh3, -scl15 , 0);
				
				addChild(x1);
				addChild(x2);
				//y
				var y1:LineSegment = new LineSegment({material:maty});
				var y2:LineSegment = new LineSegment({material:maty});
				var y3:LineSegment = new LineSegment({material:maty});
				var cross:Number = len+(sclh2) + (  ((len+sclh34) - (len+sclh2)) /3  * 2);
				y1.start = new Vertex(-scaleW*1.2, len+sclh34,0);
				y1.end = new Vertex( 0, cross, 0);
				y2.start = new Vertex(scaleW*1.2, len+sclh34,0);
				y2.end = new Vertex( 0, cross, 0);
				y3.start = new Vertex( 0, cross, 0);
				y3.end = new Vertex( 0, len+sclh2, 0);
				
				addChild(y1);
				addChild(y2);
				addChild(y3);
				//z
				var z1:LineSegment = new LineSegment({material:matz});
				var z2:LineSegment = new LineSegment({material:matz});
				var z3:LineSegment = new LineSegment({material:matz});
				
				z1.start = new Vertex(0, scl15, len+sclh3);
				z2.end = new Vertex(0, -scl15, len+sclh2);
							
				z1.end = new Vertex(0, scl15, len+sclh2);
				z2.start = new Vertex(0, -scl15, len+sclh3);
	
				z3.start = z2.end;
				z3.end = z1.start;
				
				addChild(z1);
				addChild(z2);
				addChild(z3);
			}
		}
		
	}
}
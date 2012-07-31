﻿package away3d.extrusions
{
   	import flash.display.BitmapData;
	import away3d.core.base.*;
	
	/**
	* Class ElevationModifier updates the vertexes of a flat Mesh such as a Plane, RegularPolygon with a bimap information<ElevationModifier></code>
	* 
	*/
	public class ElevationModifier {
		
		private var _mesh:Mesh;
		private var _channel:String;
		private var _elevate:Number;
		private var _sourceBmd:BitmapData;
		private var _axis:String;
			
		public function ElevationModifier()
        {
		}
		
		/**
		* Updates the vertexes of a Mesh on the z axis according to color information stored into a BitmapData
		*
		* @param	sourceBmd				Bitmapdata. The bitmapData to read from.
		* @param	mesh						Object3D. The mesh Object3D to be updated.
		* @param	channel					[optional] String. The channel information to read. supported "a", alpha, "r", red, "g", green, "b", blue and "av" (averages and luminance). Default is red channel "r".
		* @param	elevate					[optional] Number. The scale multiplier along the z axis. Default is .5.
		* @param	axis						[optional] String. The axis to influence. Default is "z".

		*/
		public function update(sourceBmd:BitmapData, mesh:Object3D, channel:String = "r", elevate:Number = .5, axis:String = "z"):void
		{
			if((mesh as Mesh).geometry.faces != null){
				
				var i:int = 0;
				_channel = channel.toLowerCase();
				_elevate = elevate;
				_sourceBmd = sourceBmd;
				_mesh = (mesh as Mesh);
				_axis = axis;
				
				var flist:Array = _mesh.geometry.faces;
				var face:Face;
				var vr0:Vertex;
				var vr1:Vertex;
				var vr2:Vertex;
				var u0:Number;
				var u1:Number;
				var u2:Number;
				var v0:Number;
				var v1:Number;
				var v2:Number;
				
				var w:Number = sourceBmd.width;
				var h:Number = sourceBmd.height;
				
				for(i = 0;i<flist.length;++i)
				{
					face = flist[i];
					vr0 = face.v0;
					vr1 = face.v1;
					vr2 = face.v2;
					u0 = w * face.uv0.u,
					u1 = w * face.uv1.u,
					u2 = w * face.uv2.u,
					v0 = h * (1 - face.uv0.v),
					v1 = h * (1 - face.uv1.v),
					v2 = h * (1 - face.uv2.v);
					
					updateVertex(vr0, u0, v0);
					updateVertex(vr1, u1, v1);
					updateVertex(vr2, u2, v2);
				}
				
			} else{
				
				throw new Error("ElevationModifier error: unvalid mesh");
			}
			
		}
		
		private function updateVertex(vertex:Vertex, x:Number, y:Number):void
		{
				var color:uint = (_channel == "a")? _sourceBmd.getPixel32(x, y) : _sourceBmd.getPixel(x, y);
				var cha:Number;
				switch(_channel){
					case "a":
						cha = color >> 24 & 0xFF;
						break;
					case "r":
						cha = color >> 16 & 0xFF;
						break;
					case "g":
						cha = color >> 8 & 0xFF;
						break;
					case "b":
						cha = color & 0xFF;
						break;
					case "av":
						cha = ((color >> 16 & 0xFF)*0.212671) + ((color >> 8 & 0xFF)*0.715160) + ((color >> 8 & 0xFF)*0.072169);
				}
				
				switch(_axis){
					case "x":
						_mesh.updateVertex(vertex,  cha*_elevate, vertex.y, vertex.z , false);
						break;
					case "y":
						_mesh.updateVertex(vertex, vertex.x, cha*_elevate, vertex.z , false);
						break;
					case "z":
						_mesh.updateVertex(vertex, vertex.x, vertex.y ,cha*_elevate,  false);
						break;
				}
			
			}
				
	}
}
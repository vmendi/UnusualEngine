﻿/*
 * Copyright 2007 (c) Gabriel Putnam
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

package away3d.primitives
{
	import away3d.arcane;
    import away3d.core.base.*;
    
	use namespace arcane;
	
    /**
    * Creates a 3d geodesic sphere primitive.
    */ 
	public class GeodesicSphere extends AbstractPrimitive
	{
		private var _radius:Number;
		private var _fractures:Number;
		
		/**
		 * @inheritDoc
		 */
    	protected override function buildPrimitive():void
    	{
    		super.buildPrimitive();
    		
			// Set up variables for keeping track of the vertices, faces, and texture coords.
			var aVertice:Array = []; 
            var aUV:Array  = []; 
			
			// Set up variables for keeping track of the number of iterations and the angles
			var iVerts:uint = _fractures + 1, jVerts:uint;
			var j:uint, Theta:Number=0, Phi:Number=0, ThetaDel:Number, PhiDel:Number;
			var cosTheta:Number, sinTheta:Number, rcosPhi:Number, rsinPhi:Number;
			// Set up variables for figuring out the texture coordinates using a diamond ~equal area map projection
			// This is done so that there is the minimal amount of distortion of textures around poles.
			// Visually, this map projection looks like this.
			/*	Phi   /\0,0
				|    /  \
				\/  /    \
				   /      \
				  /        \
				 / 1,0      \0,1
				 \ Theta->  /
				  \        /
				   \      /
				    \    /
					 \  /
					  \/1,1
			*/
			var Pd4:Number = Math.PI / 4, cosPd4:Number = Math.cos(Pd4), sinPd4:Number = Math.sin(Pd4), PIInv:Number = 1/Math.PI;
			var R_00:Number = cosPd4, R_01:Number = -sinPd4, R_10:Number = sinPd4, R_11:Number = cosPd4;
			var Scale:Number = Math.SQRT2, uOff:Number = 0.5, vOff:Number = 0.5;
			var UU:Number, VV:Number, u:Number, v:Number;
			PhiDel = Math.PI / ( 2 * iVerts);
			// Build the top vertex
			aVertice.push( createVertex( 0, 0, _radius ) );
			aUV.push( createUV( 0, 0 ) );
			//++i;
			Phi += PhiDel;
			// Build the tops worth of vertices for the sphere progressing in rings around the sphere
			var i:int;
			
			for( i = 1 ; i <= iVerts; ++i){
				j = 0;
				jVerts = i*4;
				Theta = 0;
				ThetaDel = 2* Math.PI / jVerts;
				rcosPhi = Math.cos( Phi ) * _radius;
				rsinPhi = Math.sin( Phi ) * _radius;
				for( j; j < jVerts; ++j ){
					
					UU = Theta * PIInv/2 - 0.5;
					VV = ( Phi * PIInv - 1 ) * ( 0.5 - Math.abs( UU ) );
					
					u = ( UU * R_00 + VV * R_01 ) * Scale + uOff;
					v = ( UU * R_10 + VV * R_11 ) * Scale + vOff;
					
					cosTheta = Math.cos( Theta );
					sinTheta = Math.sin( Theta );
					 
					aVertice.push( createVertex( cosTheta * rsinPhi, sinTheta * rsinPhi, rcosPhi ) );
					aUV.push(createUV( u, v ) );
					Theta += ThetaDel;
				}
				Phi += PhiDel;
			}
			// Build the bottom worth of vertices for the sphere.
			for( i = iVerts-1; i >0; i-- ){
				j = 0;
				jVerts = i*4;
				Theta = 0;
				ThetaDel = 2* Math.PI / jVerts;
				rcosPhi = Math.cos( Phi ) * _radius;
				rsinPhi = Math.sin( Phi ) * _radius;
				for( j; j < jVerts; ++j ){
					
					UU = Theta * PIInv/2 - 0.5;
					VV = ( Phi * PIInv - 1 ) * ( 0.5 + Math.abs( UU ) );
					
					u = ( UU * R_00 + VV * R_01 ) * Scale + uOff;
					v = ( UU * R_10 + VV * R_11 ) * Scale + vOff;
					
					cosTheta = Math.cos( Theta );
					sinTheta = Math.sin( Theta );
					aVertice.push( createVertex( cosTheta * rsinPhi, sinTheta * rsinPhi, rcosPhi ) );
					aUV.push(createUV( u, v ) );
					Theta += ThetaDel;
				}
				Phi += PhiDel;
			}
			
			// Build the last vertice
			aVertice.push( createVertex( 0, 0, -_radius ) );
			aUV.push( createUV( 1, 1 ) );
			// Build the faces for the sphere
			// Build the upper four sections
			var k:uint, L_Ind_s:uint, U_Ind_s:uint, U_Ind_e:uint, L_Ind_e:uint, L_Ind:uint, U_Ind:uint;
			var isUpTri:Boolean, Pt0:uint, Pt1:uint, Pt2:uint, triInd:uint, tris:uint;
			tris = 1;
			
			L_Ind_s = 0; L_Ind_e = 0;
			for( i = 0; i < iVerts; ++i ){
				U_Ind_s = L_Ind_s;
				U_Ind_e = L_Ind_e;
				if( i == 0 ) L_Ind_s++;
				L_Ind_s += 4*i;
				L_Ind_e += 4*(i+1);
				U_Ind = U_Ind_s;
				L_Ind = L_Ind_s;
				for( k = 0; k < 4; ++k ){
					isUpTri = true;
					for( triInd = 0; triInd < tris; triInd++ ){
						if( isUpTri ){
							Pt0 = U_Ind;
							Pt1 = L_Ind;
							L_Ind++;
							if( L_Ind > L_Ind_e ) L_Ind = L_Ind_s;
							Pt2 = L_Ind;
							isUpTri = false;
						} else {
							Pt0 = L_Ind;
							Pt2 = U_Ind;
							U_Ind++;
							if( U_Ind > U_Ind_e ) U_Ind = U_Ind_s;
							Pt1 = U_Ind;
							isUpTri = true;
						}
						addFace( createFace( aVertice[Pt1],aVertice[Pt0], aVertice[Pt2] , null,  aUV[Pt1],aUV[Pt0],aUV[Pt2] ) );
											}
				}
				tris += 2;
			}
			U_Ind_s = L_Ind_s; U_Ind_e = L_Ind_e;
			// Build the lower four sections
			 
			for( i = iVerts-1; i >= 0; i-- ){
				L_Ind_s = U_Ind_s; L_Ind_e = U_Ind_e; U_Ind_s = L_Ind_s + 4*(i+1); U_Ind_e = L_Ind_e + 4*i;
				if( i == 0 ) U_Ind_e++;
				tris -= 2;
				U_Ind = U_Ind_s;
				L_Ind = L_Ind_s;
				for( k = 0; k < 4; ++k ){
					isUpTri = true;
					for( triInd = 0; triInd < tris; triInd++ ){
						if( isUpTri ){
							Pt0 = U_Ind;
							Pt1 = L_Ind;
							L_Ind++;
							if( L_Ind > L_Ind_e ) L_Ind = L_Ind_s;
							Pt2 = L_Ind;
							isUpTri = false;
						} else {
							Pt0 = L_Ind;
							Pt2 = U_Ind;
							U_Ind++;
							if( U_Ind > U_Ind_e ) U_Ind = U_Ind_s;
							Pt1 = U_Ind;
							isUpTri = true;
						}
						addFace( createFace( aVertice[Pt2],aVertice[Pt0],aVertice[Pt1] , null, aUV[Pt2],aUV[Pt0],aUV[Pt1] ) );
					}
				}
			}
    	}
    	
    	/**
    	 * Defines the radius of the sphere. Defaults to 100.
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
    	 * Defines the fractures of the sphere. Defaults to 2.
    	 */
    	public function get fractures():Number
    	{
    		return _fractures;
    	}
    	
    	public function set fractures(val:Number):void
    	{
    		if (_fractures == val)
    			return;
    		
    		_fractures = val;
    		_primitiveDirty = true;
    	}
		
		/**
		 * Creates a new <code>GeodesicSphere</code> object.
		 *
		 * @param	init			[optional]	An initialisation object for specifying default instance properties.
		 */
		public function GeodesicSphere( init:Object = null)
        {
            super(init);
            
			_radius = ini.getNumber("radius", 100, {min:100});
            _fractures = ini.getInt("fractures", 2, {min:2});
			
			type = "GeoSphere";
        	url = "primitive"; 
		}
	}
}
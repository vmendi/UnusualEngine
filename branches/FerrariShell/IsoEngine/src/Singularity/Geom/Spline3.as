//
// Spline3.as - Generate natural cubic spline, given a set of knots.  
//
// Reference:  http://www.algorithmist.net/spline.html
//
// copyright (c) 2005-2007, Jim Armstrong.  All Rights Reserved.
//
// This software program is supplied 'as is' without any warranty, express, implied, 
// or otherwise, including without limitation all warranties of merchantability or fitness
// for a particular purpose.  Jim Armstrong shall not be liable for any special
// incidental, or consequential damages, including, without limitation, lost
// revenues, lost profits, or loss of prospective economic advantage, resulting
// from the use or misuse of this software program.
//
//
// Note:  Although some attempt has been made to optimize operation count and complexity, this code
//        is written more for clarity than Actionscript performance.
//
// Programmed by Jim Armstrong, Singularity (www.algorithmist.net)
//
//
// Important notes:  1) Intervals must be non-overlapping.  Insertion preserves this constraint.
//
//                   2) Knot insertion/deletion causes a complete regeneration of coefficients.
//                      A future (faster) version will do this adaptively.
//

package Singularity.Geom
{
  import Singularity.Numeric.Consts;
  import Singularity.Geom.Composite;
  
  public class Spline3 extends Composite
  {
    // read associated white paper for details on these variables
    private var __t:Array;
    private var __y:Array;
    private var __u:Array;
    private var __v:Array;
    private var __h:Array;
    private var __b:Array;
    private var __z:Array;

    private var __hInv:Array;             // precomputed h^-1 values
    private var __delta:Number;           // current x-t(i)
    private var __knots:Number;           // current knot count

/**
* @description 	Method: Spline3() - Construct a new Spline3 instance
*
* @return Nothing
*
* @since 1.0
*
*/
    public function Spline3()
    {
      super();
      
      __error.classname = "Spline3";

      __t    = new Array();
      __y    = new Array();
      __u    = new Array();
      __v    = new Array();
      __h    = new Array();
      __b    = new Array();
      __z    = new Array();
      __hInv = new Array();

      __invalidate = true;
      __delta      = 0.0;
      __knots      = 0;
    }

    // return knot count
    public function get knotCount():Number { return __knots; }

    // return array of Objects with X and Y properties containing knot coordinates
    public function get knots():Array
    {
      var knotArr:Array = new Array();
      for( var i:uint=0; i<__knots; ++i )
        knotArr.push({X:__t[i], Y:__y[i]});

      return knotArr;
    }

/**
* @description 	Method: addControlPoint( _xKnot:Number, _yKnot:Number ) - Add/Insert a knot in a manner that maintains
* non-overlapping intervals.  This method rearranges knot order, if necessary, to maintain non-overlapping intervals.
*
* @param _t:Number - x-coordinate of knot to add
* @param _y:Number - y-coordinate of knot to add
*
* @return Nothing
*
* @since 1.0
*
*/
    public override function addControlPoint(_xKnot:Number, _yKnot:Number):void
    {
      __error.methodname = "addControlPoint()";

      if( isNaN(_xKnot) )
      {
        __error.message = "invalid x-coordinate at knot: " + __t.length;
        dispatchEvent(__error);
        return;
      }
      if( isNaN(_yKnot) )
      {
        __error.message = "invalid y-coordinate at knot: " + __t.length;
        dispatchEvent(__error);
        return;
      }

      __invalidate = true;

      if( __t.length == 0 )
      {
        __t.push(_xKnot);
        __y.push(_yKnot);
        __knots++;
      }
      else
      {
        if ( _xKnot > __t[__knots-1] )
        {
          __t.push(_xKnot);
          __y.push(_yKnot);
          __knots++;
        }
        else if( _xKnot < __t[0] )
          __insert(_xKnot, _yKnot, 0);
        else
        {
          if( __knots > 1 )
          {
            for( var i:uint=0; i<__knots-1; ++i )
            {
              if( _xKnot > __t[i] && _xKnot < __t[i+1] )
                __insert(_xKnot, _yKnot, i+1 );
            }
          }
        }
      }
    }

    // insert knot at index
    private function __insert(_xKnot:Number, _yKnot:Number, _indx:Number):void
    {
      for( var i:uint=__knots-1; i>=_indx; i-- )
      { 
        __t[i+1] = __t[i];
        __y[i+1] = __y[i];
      }
      __t[_indx] = _xKnot;
      __y[_indx] = _yKnot;
      __knots++;
    }

    // remove knot at index
    private function __remove(_indx:Number):void
    {
      for( var i:uint=_indx; i<__knots; ++i)
      { 
        __t[i] = __t[i+1];
        __y[i] = __y[i+1];
      }
      __t.pop();
      __y.pop();
      __knots--;
    }

/**
* @description 	Method: removePointAt( _indx:uint ) - Delete knot at the specified index
*
* @param _indx:uint - index of knot to delete
*
* @return Nothing
*
* @since 1.0
*
*/
    public function removePointAt(_indx:uint):void
    {
      __error.methodname = "removePointAt()";

      if( _indx < 0 || _indx >= __knots )
      {
        __error.message = "Index: " + _indx.toString() + " is out of range.";
        dispatchEvent(__error);
        return;
      };

      __remove(_indx);
      __invalidate   = true;
    }

/**
* @description 	Method: moveControlPoint( _indx:uint, _xKnot:Number, _yKnot:Number ) - Move knot at the specified index within its interval
*
* @param _indx:uint    - index of knot to replace
* @param _xKnot:Number - new x-coordinate
* @param _yKnot:Number - new y-coordinate
*
* @return Nothing - There is no testing to see if the move causes any intervals to overlap
*
* @since 1.0
*
*/
    public override function moveControlPoint(_indx:uint, _xKnot:Number, _yKnot:Number):void
    {
      __error.methodname = "moveControlPoint()";

      if( _indx < 0 || _indx >= __knots )
      {
        __error.message = "Index: " + _indx.toString() + " is out of range.";
        dispatchEvent(__error);
        return;
      }

      if( isNaN(_xKnot) )
      {
        __error.message = "Invalid x-coordinate";
        dispatchEvent(__error);
        return;
      }
 
      if( isNaN(_yKnot) )
      {
        __error.message = "Invalid y-coordinate";
        dispatchEvent(__error);
        return;
      }

      __t[_indx]   = _xKnot;
      __y[_indx]   = _yKnot;
      __invalidate = true;
    }
/**
* @description 	Method: deleteAllKnots() - Delete all knots
*
* @return Nothing
*
* @since 1.0
*
*/
    public function deleteAllKnots():void
    {
      __t.splice(0);
      __y.splice(0);

      __knots      = 0;
      __invalidate = true;
    }

/**
* @description 	Method: removeKnotAtX( _xKnot:Number ) - Delete knot at a given x-coordinate
*
* @param _xKnot:Number - x-coordinate of knot to delete
*
* @return Nothing
*
* @since 1.0
*
*/
    public function removeKnotAtX(_xKnot:Number):void
    {
      __error.methodname = "removeKnotAtX()";

      if( isNaN(_xKnot) )
      {
        __error.message = "Invalid x-coordinate:";
  
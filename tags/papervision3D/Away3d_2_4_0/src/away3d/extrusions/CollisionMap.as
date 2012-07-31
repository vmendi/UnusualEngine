﻿package away3d.extrusions
{
   	import flash.display.BitmapData;
	import flash.events.*;

	public class CollisionMap extends EventDispatcher{
		
		private var _detectBmd:BitmapData;
		private var _oDetect:Object = {};
		private var _factorX:Number;
		private var _factorY:Number;
		private var _offsetX:Number;
		private var _offsetY:Number;
		
		private function fireColorEvent(eventID:String):void
        {
			dispatchEvent(new Event(eventID));
        }
		
		/**
		 * Creates a new <CollisionMap>CollisionMap</code>
		 * 
		 * @param	 	sourcebmd		The bitmapdata with color regions to act as trigger.
		 * @param 	factorX			[optional]	A factor scale along the X axis
		 * @param 	factorY			[optional]	A factor scale along the Y axis
		 * 
		 * note that an offset equal to halfwidth/halfheight of the source is set per default. Because most terrains are placed centered at 0,0,0 
		 */
		public function CollisionMap(sourcebmd:BitmapData, factorX:Number = 0 , factorY:Number = 0)
        {
			this._detectBmd = sourcebmd;
			this._factorX = factorX;
			this._factorY = factorY;
			this._offsetX = sourcebmd.rect.width*.5;
			this._offsetY = sourcebmd.rect.height*.5; 
		}
		
		/**
		 * If at the given coordinates a color is found that matches a defined color event, the color event will be triggered.
		 * 
		 * @param 	x			X coordinate on the source bmd
		 * @param 	y			Y coordinate on the source bmd
		 *
		 * note that offsetX, offsetY, factorX, factorY are applied in this handler
		 */
		public function read(x:Number, y:Number):void
        {
			var col:Number = x/_factorX;
			var row:Number = y/_factorY; 
			col += _offsetX;
			row += _offsetY;
			var color:Number = _detectBmd.getPixel(col, row);
			
			if(_oDetect["_"+color] != null){
				fireColorEvent(_oDetect["_"+color].eventID);
			}
			 
		}
		
		/**
		 * If at the given coordinates a color is found that matches a defined color event, the color event will be triggered.
		 * 
		 * @param 	x			X coordinate on the source bmd
		 * @param 	y			Y coordinate on the source bmd
		 *
		 * @return		A Number, the color value at coordinates x, y
		 *
		 * note that offsetX, offsetY, factorX, factorY are applied in this handler
		 */
		public function getColorAt(x:Number, y:Number):Number
        {
			var col:Number = x/_factorX;
			var row:Number = y/_factorY; 
			col += _offsetX;
			row += _offsetY;
			
			return _detectBmd.getPixel(col, row);
		}
		
		/**
		 * Defines a color event for this class
		 * 
		 * @param 	color			A color Number
		 * @param 	eventid		A string to identify that event
		 * @param 	listener		The function  that must be triggered
		 *
		 * note that offsetX, offsetY, factorX, factorY are applied in this handler
		 */
		public function setColorEvent(color:Number, eventid:String, listener:Function):void
        {
			_oDetect["_"+color] = {color:color, eventID:eventid, min:color, max:color};
			addEventListener(eventid, listener, false, 0, false);
        }
		
		/**
		 * getter/setter for the offsetX, offsetY
		 */
		public function set offsetX(val:Number):void
        {
			_offsetX = val;
        }
		
		public function set offsetY(val:Number):void
        {
			_offsetY = val;
        }
		
		public function get offsetX():Number
        {
			return _offsetX;
        }
		
		public function get offsetY():Number
        {
			return _offsetY;
        }
		
		/**
		 * getter/setter for the factorX, factorY
		 */
		public function set factorX(val:Number):void
        {
			_factorX = val;
        }
		
		public function set factorY(val:Number):void
        {
			_factorY = val;
        }
		
		public function get factorX():Number
        {
			return _factorX;
        }
		
		public function get factorY():Number
        {
			return _factorY;
        }
		
		/**
		 * getter/setter for source bitmapdata
		 */
		public function set source(bmd:BitmapData):void
        {
			this._detectBmd = bmd;
        }
		public function get source():BitmapData
        {
			return this._detectBmd;
        }
		 
	}
}
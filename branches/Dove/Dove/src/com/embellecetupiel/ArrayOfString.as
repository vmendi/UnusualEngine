/**
 * ArrayOfString.as
 * This file was auto-generated from WSDL by the Apache Axis2 generator modified by Adobe
 * Any change made to this file will be overwritten when the code is re-generated.
 */
package com.embellecetupiel
{
	import mx.utils.ObjectProxy;
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.collections.ICollectionView;
	import mx.rpc.soap.types.*;
	/**
	 * Typed array collection
	 */

	public class ArrayOfString extends ArrayCollection
	{
		/**
		 * Constructor - initializes the array collection based on a source array
		 */
        
		public function ArrayOfString(source:Array = null)
		{
			super(source);
		}
        
        
		public function addStringAt(item:String,index:int):void 
		{
			addItemAt(item,index);
		}

		public function addString(item:String):void 
		{
			addItem(item);
		} 

		public function getStringAt(index:int):String 
		{
			return getItemAt(index) as String;
		}

		public function getStringIndex(item:String):int 
		{
			return getItemIndex(item);
		}

		public function setStringAt(item:String,index:int):void 
		{
			setItemAt(item,index);
		}

		public function asIList():IList 
		{
			return this as IList;
		}
        
		public function asICollectionView():ICollectionView 
		{
			return this as ICollectionView;
		}
	}
}

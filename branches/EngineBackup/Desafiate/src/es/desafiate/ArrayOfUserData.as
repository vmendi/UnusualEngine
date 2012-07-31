/**
 * ArrayOfUserData.as
 * This file was auto-generated from WSDL by the Apache Axis2 generator modified by Adobe
 * Any change made to this file will be overwritten when the code is re-generated.
 */
package es.desafiate
{
	import mx.utils.ObjectProxy;
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.collections.ICollectionView;
	import mx.rpc.soap.types.*;
	/**
	 * Typed array collection
	 */

	public class ArrayOfUserData extends ArrayCollection
	{
		/**
		 * Constructor - initializes the array collection based on a source array
		 */
        
		public function ArrayOfUserData(source:Array = null)
		{
			super(source);
		}
        
        
		public function addUserDataAt(item:UserData,index:int):void 
		{
			addItemAt(item,index);
		}

		public function addUserData(item:UserData):void 
		{
			addItem(item);
		} 

		public function getUserDataAt(index:int):UserData 
		{
			return getItemAt(index) as UserData;
		}

		public function getUserDataIndex(item:UserData):int 
		{
			return getItemIndex(item);
		}

		public function setUserDataAt(item:UserData,index:int):void 
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

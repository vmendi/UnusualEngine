/**
 * SavePuntuacion_request.as
 * This file was auto-generated from WSDL by the Apache Axis2 generator modified by Adobe
 * Any change made to this file will be overwritten when the code is re-generated.
 */

package es.desafiate
{
	import mx.utils.ObjectProxy;
	import flash.utils.ByteArray;
	import mx.rpc.soap.types.*;
	/**
	 * Wrapper class for a operation required type
	 */
    
	public class SavePuntuacion_request
	{
		/**
		 * Constructor, initializes the type class
		 */
		public function SavePuntuacion_request() {}
            
		public var cFacebookString:String;
		public var nIdSesion:String;
		public var cEvento:String;
		public var nPuntuacion:Number;
		public var cUserCheck:String;
	}
}
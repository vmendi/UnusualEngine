
/**
 * Service.as
 * This file was auto-generated from WSDL by the Apache Axis2 generator modified by Adobe
 * Any change made to this file will be overwritten when the code is re-generated.
 */
package com.embellecetupiel{
	import mx.rpc.AsyncToken;
	import flash.utils.ByteArray;
	import mx.rpc.soap.types.*;
               
    public interface IDoveWebService
    {
    	//Stub functions for the SaveTestResult operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param answers
    	 * @return An AsyncToken
    	 */
    	function saveTestResult(answers:ArrayOfString):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function saveTestResult_send():AsyncToken;
        
        /**
         * The saveTestResult operation lastResult property
         */
        function get saveTestResult_lastResult():Number;
		/**
		 * @private
		 */
        function set saveTestResult_lastResult(lastResult:Number):void;
       /**
        * Add a listener for the saveTestResult operation successful result event
        * @param The listener function
        */
       function addsaveTestResultEventListener(listener:Function):void;
       
       
        /**
         * The saveTestResult operation request wrapper
         */
        function get saveTestResult_request_var():SaveTestResult_request;
        
        /**
         * @private
         */
        function set saveTestResult_request_var(request:SaveTestResult_request):void;
                   
    	//Stub functions for the SaveRegister operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param registerFields
    	 * @return An AsyncToken
    	 */
    	function saveRegister(registerFields:RegisterFields):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function saveRegister_send():AsyncToken;
        
        /**
         * The saveRegister operation lastResult property
         */
        function get saveRegister_lastResult():String;
		/**
		 * @private
		 */
        function set saveRegister_lastResult(lastResult:String):void;
       /**
        * Add a listener for the saveRegister operation successful result event
        * @param The listener function
        */
       function addsaveRegisterEventListener(listener:Function):void;
       
       
        /**
         * The saveRegister operation request wrapper
         */
        function get saveRegister_request_var():SaveRegister_request;
        
        /**
         * @private
         */
        function set saveRegister_request_var(request:SaveRegister_request):void;
                   
        /**
         * Get access to the underlying web service that the stub uses to communicate with the server
         * @return The base service that the facade implements
         */
        function getWebService():BaseDoveWebService;
	}
}
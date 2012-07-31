/**
 * DoveWebServiceService.as
 * This file was auto-generated from WSDL by the Apache Axis2 generator modified by Adobe
 * Any change made to this file will be overwritten when the code is re-generated.
 */
 /**
  * Usage example: to use this service from within your Flex application you have two choices:
  * Use it via Actionscript only
  * Use it via MXML tags
  * Actionscript sample code:
  * Step 1: create an instance of the service; pass it the LCDS destination string if any
  * var myService:DoveWebService= new DoveWebService();
  * Step 2: for the desired operation add a result handler (a function that you have already defined previously)  
  * myService.addSaveTestResultEventListener(myResultHandlingFunction);
  * Step 3: Call the operation as a method on the service. Pass the right values as arguments:
  * myService.SaveTestResult(myanswers);
  *
  * MXML sample code:
  * First you need to map the package where the files were generated to a namespace, usually on the <mx:Application> tag, 
  * like this: xmlns:srv="com.embellecetupiel.*"
  * Define the service and within its tags set the request wrapper for the desired operation
  * <srv:DoveWebService id="myService">
  *   <srv:SaveTestResult_request_var>
  *		<srv:SaveTestResult_request answers=myValue/>
  *   </srv:SaveTestResult_request_var>
  * </srv:DoveWebService>
  * Then call the operation for which you have set the request wrapper value above, like this:
  * <mx:Button id="myButton" label="Call operation" click="myService.SaveTestResult_send()" />
  */
package com.embellecetupiel
{
	import mx.rpc.AsyncToken;
	import flash.events.EventDispatcher;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.events.FaultEvent;
	import flash.utils.ByteArray;
	import mx.rpc.soap.types.*;

    /**
     * Dispatches when a call to the operation SaveTestResult completes with success
     * and returns some data
     * @eventType SaveTestResultResultEvent
     */
    [Event(name="SaveTestResult_result", type="com.embellecetupiel.SaveTestResultResultEvent")]
    
    /**
     * Dispatches when a call to the operation SaveRegister completes with success
     * and returns some data
     * @eventType SaveRegisterResultEvent
     */
    [Event(name="SaveRegister_result", type="com.embellecetupiel.SaveRegisterResultEvent")]
    
	/**
	 * Dispatches when the operation that has been called fails. The fault event is common for all operations
	 * of the WSDL
	 * @eventType mx.rpc.events.FaultEvent
	 */
    [Event(name="fault", type="mx.rpc.events.FaultEvent")]

	public class DoveWebService extends EventDispatcher implements IDoveWebService
	{
    	private var _baseService:BaseDoveWebService;
        
        /**
         * Constructor for the facade; sets the destination and create a baseService instance
         * @param The LCDS destination (if any) associated with the imported WSDL
         */  
        public function DoveWebService(destination:String=null,rootURL:String=null)
        {
        	_baseService = new BaseDoveWebService(destination,rootURL);
        }
        
		//stub functions for the SaveTestResult operation
          

        /**
         * @see IDoveWebService#SaveTestResult()
         */
        public function saveTestResult(answers:ArrayOfString):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.saveTestResult(answers);
            _internal_token.addEventListener("result",_SaveTestResult_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IDoveWebService#SaveTestResult_send()
		 */    
        public function saveTestResult_send():AsyncToken
        {
        	return saveTestResult(_SaveTestResult_request.answers);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _SaveTestResult_request:SaveTestResult_request;
		/**
		 * @see IDoveWebService#SaveTestResult_request_var
		 */
		[Bindable]
		public function get saveTestResult_request_var():SaveTestResult_request
		{
			return _SaveTestResult_request;
		}
		
		/**
		 * @private
		 */
		public function set saveTestResult_request_var(request:SaveTestResult_request):void
		{
			_SaveTestResult_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _saveTestResult_lastResult:Number;
		[Bindable]
		/**
		 * @see IDoveWebService#SaveTestResult_lastResult
		 */	  
		public function get saveTestResult_lastResult():Number
		{
			return _saveTestResult_lastResult;
		}
		/**
		 * @private
		 */
		public function set saveTestResult_lastResult(lastResult:Number):void
		{
			_saveTestResult_lastResult = lastResult;
		}
		
		/**
		 * @see IDoveWebService#addSaveTestResult()
		 */
		public function addsaveTestResultEventListener(listener:Function):void
		{
			addEventListener(SaveTestResultResultEvent.SaveTestResult_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _SaveTestResult_populate_results(event:ResultEvent):void
		{
			var e:SaveTestResultResultEvent = new SaveTestResultResultEvent();
		            e.result = event.result as Number;
		                       e.headers = event.headers;
		             saveTestResult_lastResult = e.result;
		             dispatchEvent(e);
	        		}
		
		//stub functions for the SaveRegister operation
          

        /**
         * @see IDoveWebService#SaveRegister()
         */
        public function saveRegister(registerFields:RegisterFields):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.saveRegister(registerFields);
            _internal_token.addEventListener("result",_SaveRegister_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IDoveWebService#SaveRegister_send()
		 */    
        public function saveRegister_send():AsyncToken
        {
        	return saveRegister(_SaveRegister_request.registerFields);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _SaveRegister_request:SaveRegister_request;
		/**
		 * @see IDoveWebService#SaveRegister_request_var
		 */
		[Bindable]
		public function get saveRegister_request_var():SaveRegister_request
		{
			return _SaveRegister_request;
		}
		
		/**
		 * @private
		 */
		public function set saveRegister_request_var(request:SaveRegister_request):void
		{
			_SaveRegister_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _saveRegister_lastResult:String;
		[Bindable]
		/**
		 * @see IDoveWebService#SaveRegister_lastResult
		 */	  
		public function get saveRegister_lastResult():String
		{
			return _saveRegister_lastResult;
		}
		/**
		 * @private
		 */
		public function set saveRegister_lastResult(lastResult:String):void
		{
			_saveRegister_lastResult = lastResult;
		}
		
		/**
		 * @see IDoveWebService#addSaveRegister()
		 */
		public function addsaveRegisterEventListener(listener:Function):void
		{
			addEventListener(SaveRegisterResultEvent.SaveRegister_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _SaveRegister_populate_results(event:ResultEvent):void
		{
			var e:SaveRegisterResultEvent = new SaveRegisterResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             saveRegister_lastResult = e.result;
		             dispatchEvent(e);
	        		}
		
		//service-wide functions
		/**
		 * @see IDoveWebService#getWebService()
		 */
		public function getWebService():BaseDoveWebService
		{
			return _baseService;
		}
		
		/**
		 * Set the event listener for the fault event which can be triggered by each of the operations defined by the facade
		 */
		public function addDoveWebServiceFaultEventListener(listener:Function):void
		{
			addEventListener("fault",listener);
		}
		
		/**
		 * Internal function to re-dispatch the fault event passed on by the base service implementation
		 * @private
		 */
		 
		 private function throwFault(event:FaultEvent):void
		 {
		 	dispatchEvent(event);
		 }
    }
}


/**
 * Service.as
 * This file was auto-generated from WSDL by the Apache Axis2 generator modified by Adobe
 * Any change made to this file will be overwritten when the code is re-generated.
 */
package es.desafiate{
	import mx.rpc.AsyncToken;
	import flash.utils.ByteArray;
	import mx.rpc.soap.types.*;
               
    public interface IMainService
    {
    	//Stub functions for the sessionStart operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param cFacebookString
    	 * @return An AsyncToken
    	 */
    	function sessionStart(cFacebookString:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function sessionStart_send():AsyncToken;
        
        /**
         * The sessionStart operation lastResult property
         */
        function get sessionStart_lastResult():String;
		/**
		 * @private
		 */
        function set sessionStart_lastResult(lastResult:String):void;
       /**
        * Add a listener for the sessionStart operation successful result event
        * @param The listener function
        */
       function addsessionStartEventListener(listener:Function):void;
       
       
        /**
         * The sessionStart operation request wrapper
         */
        function get sessionStart_request_var():SessionStart_request;
        
        /**
         * @private
         */
        function set sessionStart_request_var(request:SessionStart_request):void;
                   
    	//Stub functions for the sessionStartNew operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param cFacebookString
    	 * @param cSessionID
    	 * @return An AsyncToken
    	 */
    	function sessionStartNew(cFacebookString:String,cSessionID:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function sessionStartNew_send():AsyncToken;
        
        /**
         * The sessionStartNew operation lastResult property
         */
        function get sessionStartNew_lastResult():String;
		/**
		 * @private
		 */
        function set sessionStartNew_lastResult(lastResult:String):void;
       /**
        * Add a listener for the sessionStartNew operation successful result event
        * @param The listener function
        */
       function addsessionStartNewEventListener(listener:Function):void;
       
       
        /**
         * The sessionStartNew operation request wrapper
         */
        function get sessionStartNew_request_var():SessionStartNew_request;
        
        /**
         * @private
         */
        function set sessionStartNew_request_var(request:SessionStartNew_request):void;
                   
    	//Stub functions for the keepAlive operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param cFacebookString
    	 * @param nIdSesion
    	 * @return An AsyncToken
    	 */
    	function keepAlive(cFacebookString:String,nIdSesion:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function keepAlive_send():AsyncToken;
        
        /**
         * The keepAlive operation lastResult property
         */
        function get keepAlive_lastResult():String;
		/**
		 * @private
		 */
        function set keepAlive_lastResult(lastResult:String):void;
       /**
        * Add a listener for the keepAlive operation successful result event
        * @param The listener function
        */
       function addkeepAliveEventListener(listener:Function):void;
       
       
        /**
         * The keepAlive operation request wrapper
         */
        function get keepAlive_request_var():KeepAlive_request;
        
        /**
         * @private
         */
        function set keepAlive_request_var(request:KeepAlive_request):void;
                   
    	//Stub functions for the getChecker operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @return An AsyncToken
    	 */
    	function getChecker():AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function getChecker_send():AsyncToken;
        
        /**
         * The getChecker operation lastResult property
         */
        function get getChecker_lastResult():String;
		/**
		 * @private
		 */
        function set getChecker_lastResult(lastResult:String):void;
       /**
        * Add a listener for the getChecker operation successful result event
        * @param The listener function
        */
       function addgetCheckerEventListener(listener:Function):void;
       
       
    	//Stub functions for the getHOF operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @return An AsyncToken
    	 */
    	function getHOF():AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function getHOF_send():AsyncToken;
        
        /**
         * The getHOF operation lastResult property
         */
        function get getHOF_lastResult():ArrayOfUserData;
		/**
		 * @private
		 */
        function set getHOF_lastResult(lastResult:ArrayOfUserData):void;
       /**
        * Add a listener for the getHOF operation successful result event
        * @param The listener function
        */
       function addgetHOFEventListener(listener:Function):void;
       
       
    	//Stub functions for the getUsuario operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param cFacebookString
    	 * @param nIdSesion
    	 * @param cUserCheck
    	 * @return An AsyncToken
    	 */
    	function getUsuario(cFacebookString:String,nIdSesion:String,cUserCheck:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function getUsuario_send():AsyncToken;
        
        /**
         * The getUsuario operation lastResult property
         */
        function get getUsuario_lastResult():String;
		/**
		 * @private
		 */
        function set getUsuario_lastResult(lastResult:String):void;
       /**
        * Add a listener for the getUsuario operation successful result event
        * @param The listener function
        */
       function addgetUsuarioEventListener(listener:Function):void;
       
       
        /**
         * The getUsuario operation request wrapper
         */
        function get getUsuario_request_var():GetUsuario_request;
        
        /**
         * @private
         */
        function set getUsuario_request_var(request:GetUsuario_request):void;
                   
    	//Stub functions for the saveUsuario operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param cFacebookString
    	 * @param nIdSesion
    	 * @param cxmlProperties
    	 * @param cUserCheck
    	 * @return An AsyncToken
    	 */
    	function saveUsuario(cFacebookString:String,nIdSesion:String,cxmlProperties:String,cUserCheck:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function saveUsuario_send():AsyncToken;
        
        /**
         * The saveUsuario operation lastResult property
         */
        function get saveUsuario_lastResult():String;
		/**
		 * @private
		 */
        function set saveUsuario_lastResult(lastResult:String):void;
       /**
        * Add a listener for the saveUsuario operation successful result event
        * @param The listener function
        */
       function addsaveUsuarioEventListener(listener:Function):void;
       
       
        /**
         * The saveUsuario operation request wrapper
         */
        function get saveUsuario_request_var():SaveUsuario_request;
        
        /**
         * @private
         */
        function set saveUsuario_request_var(request:SaveUsuario_request):void;
                   
    	//Stub functions for the savePuntuacion operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param cFacebookString
    	 * @param nIdSesion
    	 * @param cEvento
    	 * @param nPuntuacion
    	 * @param cUserCheck
    	 * @return An AsyncToken
    	 */
    	function savePuntuacion(cFacebookString:String,nIdSesion:String,cEvento:String,nPuntuacion:Number,cUserCheck:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function savePuntuacion_send():AsyncToken;
        
        /**
         * The savePuntuacion operation lastResult property
         */
        function get savePuntuacion_lastResult():String;
		/**
		 * @private
		 */
        function set savePuntuacion_lastResult(lastResult:String):void;
       /**
        * Add a listener for the savePuntuacion operation successful result event
        * @param The listener function
        */
       function addsavePuntuacionEventListener(listener:Function):void;
       
       
        /**
         * The savePuntuacion operation request wrapper
         */
        function get savePuntuacion_request_var():SavePuntuacion_request;
        
        /**
         * @private
         */
        function set savePuntuacion_request_var(request:SavePuntuacion_request):void;
                   
    	//Stub functions for the addLogro operation
    	/**
    	 * Call the operation on the server passing in the arguments defined in the WSDL file
    	 * @param cFacebookString
    	 * @param nIdSesion
    	 * @param cEvento
    	 * @param cLogro
    	 * @param cUserCheck
    	 * @return An AsyncToken
    	 */
    	function addLogro(cFacebookString:String,nIdSesion:String,cEvento:String,cLogro:String,cUserCheck:String):AsyncToken;
        /**
         * Method to call the operation on the server without passing the arguments inline.
         * You must however set the _request property for the operation before calling this method
         * Should use it in MXML context mostly
         * @return An AsyncToken
         */
        function addLogro_send():AsyncToken;
        
        /**
         * The addLogro operation lastResult property
         */
        function get addLogro_lastResult():String;
		/**
		 * @private
		 */
        function set addLogro_lastResult(lastResult:String):void;
       /**
        * Add a listener for the addLogro operation successful result event
        * @param The listener function
        */
       function addaddLogroEventListener(listener:Function):void;
       
       
        /**
         * The addLogro operation request wrapper
         */
        function get addLogro_request_var():AddLogro_request;
        
        /**
         * @private
         */
        function set addLogro_request_var(request:AddLogro_request):void;
                   
        /**
         * Get access to the underlying web service that the stub uses to communicate with the server
         * @return The base service that the facade implements
         */
        function getWebService():BaseMainService;
	}
}
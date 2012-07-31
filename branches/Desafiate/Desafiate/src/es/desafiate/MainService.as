/**
 * MainServiceService.as
 * This file was auto-generated from WSDL by the Apache Axis2 generator modified by Adobe
 * Any change made to this file will be overwritten when the code is re-generated.
 */
 /**
  * Usage example: to use this service from within your Flex application you have two choices:
  * Use it via Actionscript only
  * Use it via MXML tags
  * Actionscript sample code:
  * Step 1: create an instance of the service; pass it the LCDS destination string if any
  * var myService:MainService= new MainService();
  * Step 2: for the desired operation add a result handler (a function that you have already defined previously)  
  * myService.addsessionStartEventListener(myResultHandlingFunction);
  * Step 3: Call the operation as a method on the service. Pass the right values as arguments:
  * myService.sessionStart(mycFacebookString);
  *
  * MXML sample code:
  * First you need to map the package where the files were generated to a namespace, usually on the <mx:Application> tag, 
  * like this: xmlns:srv="es.desafiate.*"
  * Define the service and within its tags set the request wrapper for the desired operation
  * <srv:MainService id="myService">
  *   <srv:sessionStart_request_var>
  *		<srv:SessionStart_request cFacebookString=myValue/>
  *   </srv:sessionStart_request_var>
  * </srv:MainService>
  * Then call the operation for which you have set the request wrapper value above, like this:
  * <mx:Button id="myButton" label="Call operation" click="myService.sessionStart_send()" />
  */
package es.desafiate
{
	import mx.rpc.AsyncToken;
	import flash.events.EventDispatcher;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.events.FaultEvent;
	import flash.utils.ByteArray;
	import mx.rpc.soap.types.*;

    /**
     * Dispatches when a call to the operation sessionStart completes with success
     * and returns some data
     * @eventType SessionStartResultEvent
     */
    [Event(name="SessionStart_result", type="es.desafiate.SessionStartResultEvent")]
    
    /**
     * Dispatches when a call to the operation sessionStartNew completes with success
     * and returns some data
     * @eventType SessionStartNewResultEvent
     */
    [Event(name="SessionStartNew_result", type="es.desafiate.SessionStartNewResultEvent")]
    
    /**
     * Dispatches when a call to the operation keepAlive completes with success
     * and returns some data
     * @eventType KeepAliveResultEvent
     */
    [Event(name="KeepAlive_result", type="es.desafiate.KeepAliveResultEvent")]
    
    /**
     * Dispatches when a call to the operation getChecker completes with success
     * and returns some data
     * @eventType GetCheckerResultEvent
     */
    [Event(name="GetChecker_result", type="es.desafiate.GetCheckerResultEvent")]
    
    /**
     * Dispatches when a call to the operation getHOF completes with success
     * and returns some data
     * @eventType GetHOFResultEvent
     */
    [Event(name="GetHOF_result", type="es.desafiate.GetHOFResultEvent")]
    
    /**
     * Dispatches when a call to the operation getUsuario completes with success
     * and returns some data
     * @eventType GetUsuarioResultEvent
     */
    [Event(name="GetUsuario_result", type="es.desafiate.GetUsuarioResultEvent")]
    
    /**
     * Dispatches when a call to the operation saveUsuario completes with success
     * and returns some data
     * @eventType SaveUsuarioResultEvent
     */
    [Event(name="SaveUsuario_result", type="es.desafiate.SaveUsuarioResultEvent")]
    
    /**
     * Dispatches when a call to the operation savePuntuacion completes with success
     * and returns some data
     * @eventType SavePuntuacionResultEvent
     */
    [Event(name="SavePuntuacion_result", type="es.desafiate.SavePuntuacionResultEvent")]
    
    /**
     * Dispatches when a call to the operation addLogro completes with success
     * and returns some data
     * @eventType AddLogroResultEvent
     */
    [Event(name="AddLogro_result", type="es.desafiate.AddLogroResultEvent")]
    
	/**
	 * Dispatches when the operation that has been called fails. The fault event is common for all operations
	 * of the WSDL
	 * @eventType mx.rpc.events.FaultEvent
	 */
    [Event(name="fault", type="mx.rpc.events.FaultEvent")]

	public class MainService extends EventDispatcher implements IMainService
	{
    	private var _baseService:BaseMainService;
        
        /**
         * Constructor for the facade; sets the destination and create a baseService instance
         * @param The LCDS destination (if any) associated with the imported WSDL
         */  
        public function MainService(destination:String=null,rootURL:String=null)
        {
        	_baseService = new BaseMainService(destination,rootURL);
        }
        
		//stub functions for the sessionStart operation
          

        /**
         * @see IMainService#sessionStart()
         */
        public function sessionStart(cFacebookString:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.sessionStart(cFacebookString);
            _internal_token.addEventListener("result",_sessionStart_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IMainService#sessionStart_send()
		 */    
        public function sessionStart_send():AsyncToken
        {
        	return sessionStart(_sessionStart_request.cFacebookString);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _sessionStart_request:SessionStart_request;
		/**
		 * @see IMainService#sessionStart_request_var
		 */
		[Bindable]
		public function get sessionStart_request_var():SessionStart_request
		{
			return _sessionStart_request;
		}
		
		/**
		 * @private
		 */
		public function set sessionStart_request_var(request:SessionStart_request):void
		{
			_sessionStart_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _sessionStart_lastResult:String;
		[Bindable]
		/**
		 * @see IMainService#sessionStart_lastResult
		 */	  
		public function get sessionStart_lastResult():String
		{
			return _sessionStart_lastResult;
		}
		/**
		 * @private
		 */
		public function set sessionStart_lastResult(lastResult:String):void
		{
			_sessionStart_lastResult = lastResult;
		}
		
		/**
		 * @see IMainService#addsessionStart()
		 */
		public function addsessionStartEventListener(listener:Function):void
		{
			addEventListener(SessionStartResultEvent.SessionStart_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _sessionStart_populate_results(event:ResultEvent):void
		{
			var e:SessionStartResultEvent = new SessionStartResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             sessionStart_lastResult = e.result;
		             dispatchEvent(e);
	        		}
		
		//stub functions for the sessionStartNew operation
          

        /**
         * @see IMainService#sessionStartNew()
         */
        public function sessionStartNew(cFacebookString:String,cSessionID:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.sessionStartNew(cFacebookString,cSessionID);
            _internal_token.addEventListener("result",_sessionStartNew_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IMainService#sessionStartNew_send()
		 */    
        public function sessionStartNew_send():AsyncToken
        {
        	return sessionStartNew(_sessionStartNew_request.cFacebookString,_sessionStartNew_request.cSessionID);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _sessionStartNew_request:SessionStartNew_request;
		/**
		 * @see IMainService#sessionStartNew_request_var
		 */
		[Bindable]
		public function get sessionStartNew_request_var():SessionStartNew_request
		{
			return _sessionStartNew_request;
		}
		
		/**
		 * @private
		 */
		public function set sessionStartNew_request_var(request:SessionStartNew_request):void
		{
			_sessionStartNew_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _sessionStartNew_lastResult:String;
		[Bindable]
		/**
		 * @see IMainService#sessionStartNew_lastResult
		 */	  
		public function get sessionStartNew_lastResult():String
		{
			return _sessionStartNew_lastResult;
		}
		/**
		 * @private
		 */
		public function set sessionStartNew_lastResult(lastResult:String):void
		{
			_sessionStartNew_lastResult = lastResult;
		}
		
		/**
		 * @see IMainService#addsessionStartNew()
		 */
		public function addsessionStartNewEventListener(listener:Function):void
		{
			addEventListener(SessionStartNewResultEvent.SessionStartNew_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _sessionStartNew_populate_results(event:ResultEvent):void
		{
			var e:SessionStartNewResultEvent = new SessionStartNewResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             sessionStartNew_lastResult = e.result;
		             dispatchEvent(e);
	        		}
		
		//stub functions for the keepAlive operation
          

        /**
         * @see IMainService#keepAlive()
         */
        public function keepAlive(cFacebookString:String,nIdSesion:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.keepAlive(cFacebookString,nIdSesion);
            _internal_token.addEventListener("result",_keepAlive_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IMainService#keepAlive_send()
		 */    
        public function keepAlive_send():AsyncToken
        {
        	return keepAlive(_keepAlive_request.cFacebookString,_keepAlive_request.nIdSesion);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _keepAlive_request:KeepAlive_request;
		/**
		 * @see IMainService#keepAlive_request_var
		 */
		[Bindable]
		public function get keepAlive_request_var():KeepAlive_request
		{
			return _keepAlive_request;
		}
		
		/**
		 * @private
		 */
		public function set keepAlive_request_var(request:KeepAlive_request):void
		{
			_keepAlive_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _keepAlive_lastResult:String;
		[Bindable]
		/**
		 * @see IMainService#keepAlive_lastResult
		 */	  
		public function get keepAlive_lastResult():String
		{
			return _keepAlive_lastResult;
		}
		/**
		 * @private
		 */
		public function set keepAlive_lastResult(lastResult:String):void
		{
			_keepAlive_lastResult = lastResult;
		}
		
		/**
		 * @see IMainService#addkeepAlive()
		 */
		public function addkeepAliveEventListener(listener:Function):void
		{
			addEventListener(KeepAliveResultEvent.KeepAlive_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _keepAlive_populate_results(event:ResultEvent):void
		{
			var e:KeepAliveResultEvent = new KeepAliveResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             keepAlive_lastResult = e.result;
		             dispatchEvent(e);
	        		}
		
		//stub functions for the getChecker operation
          

        /**
         * @see IMainService#getChecker()
         */
        public function getChecker():AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.getChecker();
            _internal_token.addEventListener("result",_getChecker_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IMainService#getChecker_send()
		 */    
        public function getChecker_send():AsyncToken
        {
        	return getChecker();
        }
              
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _getChecker_lastResult:String;
		[Bindable]
		/**
		 * @see IMainService#getChecker_lastResult
		 */	  
		public function get getChecker_lastResult():String
		{
			return _getChecker_lastResult;
		}
		/**
		 * @private
		 */
		public function set getChecker_lastResult(lastResult:String):void
		{
			_getChecker_lastResult = lastResult;
		}
		
		/**
		 * @see IMainService#addgetChecker()
		 */
		public function addgetCheckerEventListener(listener:Function):void
		{
			addEventListener(GetCheckerResultEvent.GetChecker_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _getChecker_populate_results(event:ResultEvent):void
		{
			var e:GetCheckerResultEvent = new GetCheckerResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             getChecker_lastResult = e.result;
		             dispatchEvent(e);
	        		}
		
		//stub functions for the getHOF operation
          

        /**
         * @see IMainService#getHOF()
         */
        public function getHOF():AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.getHOF();
            _internal_token.addEventListener("result",_getHOF_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IMainService#getHOF_send()
		 */    
        public function getHOF_send():AsyncToken
        {
        	return getHOF();
        }
              
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _getHOF_lastResult:ArrayOfUserData;
		[Bindable]
		/**
		 * @see IMainService#getHOF_lastResult
		 */	  
		public function get getHOF_lastResult():ArrayOfUserData
		{
			return _getHOF_lastResult;
		}
		/**
		 * @private
		 */
		public function set getHOF_lastResult(lastResult:ArrayOfUserData):void
		{
			_getHOF_lastResult = lastResult;
		}
		
		/**
		 * @see IMainService#addgetHOF()
		 */
		public function addgetHOFEventListener(listener:Function):void
		{
			addEventListener(GetHOFResultEvent.GetHOF_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _getHOF_populate_results(event:ResultEvent):void
		{
			var e:GetHOFResultEvent = new GetHOFResultEvent();
		            e.result = event.result as ArrayOfUserData;
		                       e.headers = event.headers;
		             getHOF_lastResult = e.result;
		             dispatchEvent(e);
	        		}
		
		//stub functions for the getUsuario operation
          

        /**
         * @see IMainService#getUsuario()
         */
        public function getUsuario(cFacebookString:String,nIdSesion:String,cUserCheck:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.getUsuario(cFacebookString,nIdSesion,cUserCheck);
            _internal_token.addEventListener("result",_getUsuario_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IMainService#getUsuario_send()
		 */    
        public function getUsuario_send():AsyncToken
        {
        	return getUsuario(_getUsuario_request.cFacebookString,_getUsuario_request.nIdSesion,_getUsuario_request.cUserCheck);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _getUsuario_request:GetUsuario_request;
		/**
		 * @see IMainService#getUsuario_request_var
		 */
		[Bindable]
		public function get getUsuario_request_var():GetUsuario_request
		{
			return _getUsuario_request;
		}
		
		/**
		 * @private
		 */
		public function set getUsuario_request_var(request:GetUsuario_request):void
		{
			_getUsuario_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _getUsuario_lastResult:String;
		[Bindable]
		/**
		 * @see IMainService#getUsuario_lastResult
		 */	  
		public function get getUsuario_lastResult():String
		{
			return _getUsuario_lastResult;
		}
		/**
		 * @private
		 */
		public function set getUsuario_lastResult(lastResult:String):void
		{
			_getUsuario_lastResult = lastResult;
		}
		
		/**
		 * @see IMainService#addgetUsuario()
		 */
		public function addgetUsuarioEventListener(listener:Function):void
		{
			addEventListener(GetUsuarioResultEvent.GetUsuario_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _getUsuario_populate_results(event:ResultEvent):void
		{
			var e:GetUsuarioResultEvent = new GetUsuarioResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             getUsuario_lastResult = e.result;
		             dispatchEvent(e);
	        		}
		
		//stub functions for the saveUsuario operation
          

        /**
         * @see IMainService#saveUsuario()
         */
        public function saveUsuario(cFacebookString:String,nIdSesion:String,cxmlProperties:String,cUserCheck:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.saveUsuario(cFacebookString,nIdSesion,cxmlProperties,cUserCheck);
            _internal_token.addEventListener("result",_saveUsuario_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IMainService#saveUsuario_send()
		 */    
        public function saveUsuario_send():AsyncToken
        {
        	return saveUsuario(_saveUsuario_request.cFacebookString,_saveUsuario_request.nIdSesion,_saveUsuario_request.cxmlProperties,_saveUsuario_request.cUserCheck);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _saveUsuario_request:SaveUsuario_request;
		/**
		 * @see IMainService#saveUsuario_request_var
		 */
		[Bindable]
		public function get saveUsuario_request_var():SaveUsuario_request
		{
			return _saveUsuario_request;
		}
		
		/**
		 * @private
		 */
		public function set saveUsuario_request_var(request:SaveUsuario_request):void
		{
			_saveUsuario_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _saveUsuario_lastResult:String;
		[Bindable]
		/**
		 * @see IMainService#saveUsuario_lastResult
		 */	  
		public function get saveUsuario_lastResult():String
		{
			return _saveUsuario_lastResult;
		}
		/**
		 * @private
		 */
		public function set saveUsuario_lastResult(lastResult:String):void
		{
			_saveUsuario_lastResult = lastResult;
		}
		
		/**
		 * @see IMainService#addsaveUsuario()
		 */
		public function addsaveUsuarioEventListener(listener:Function):void
		{
			addEventListener(SaveUsuarioResultEvent.SaveUsuario_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _saveUsuario_populate_results(event:ResultEvent):void
		{
			var e:SaveUsuarioResultEvent = new SaveUsuarioResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             saveUsuario_lastResult = e.result;
		             dispatchEvent(e);
	        		}
		
		//stub functions for the savePuntuacion operation
          

        /**
         * @see IMainService#savePuntuacion()
         */
        public function savePuntuacion(cFacebookString:String,nIdSesion:String,cEvento:String,nPuntuacion:Number,cUserCheck:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.savePuntuacion(cFacebookString,nIdSesion,cEvento,nPuntuacion,cUserCheck);
            _internal_token.addEventListener("result",_savePuntuacion_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IMainService#savePuntuacion_send()
		 */    
        public function savePuntuacion_send():AsyncToken
        {
        	return savePuntuacion(_savePuntuacion_request.cFacebookString,_savePuntuacion_request.nIdSesion,_savePuntuacion_request.cEvento,_savePuntuacion_request.nPuntuacion,_savePuntuacion_request.cUserCheck);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _savePuntuacion_request:SavePuntuacion_request;
		/**
		 * @see IMainService#savePuntuacion_request_var
		 */
		[Bindable]
		public function get savePuntuacion_request_var():SavePuntuacion_request
		{
			return _savePuntuacion_request;
		}
		
		/**
		 * @private
		 */
		public function set savePuntuacion_request_var(request:SavePuntuacion_request):void
		{
			_savePuntuacion_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _savePuntuacion_lastResult:String;
		[Bindable]
		/**
		 * @see IMainService#savePuntuacion_lastResult
		 */	  
		public function get savePuntuacion_lastResult():String
		{
			return _savePuntuacion_lastResult;
		}
		/**
		 * @private
		 */
		public function set savePuntuacion_lastResult(lastResult:String):void
		{
			_savePuntuacion_lastResult = lastResult;
		}
		
		/**
		 * @see IMainService#addsavePuntuacion()
		 */
		public function addsavePuntuacionEventListener(listener:Function):void
		{
			addEventListener(SavePuntuacionResultEvent.SavePuntuacion_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _savePuntuacion_populate_results(event:ResultEvent):void
		{
			var e:SavePuntuacionResultEvent = new SavePuntuacionResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             savePuntuacion_lastResult = e.result;
		             dispatchEvent(e);
	        		}
		
		//stub functions for the addLogro operation
          

        /**
         * @see IMainService#addLogro()
         */
        public function addLogro(cFacebookString:String,nIdSesion:String,cEvento:String,cLogro:String,cUserCheck:String):AsyncToken
        {
         	var _internal_token:AsyncToken = _baseService.addLogro(cFacebookString,nIdSesion,cEvento,cLogro,cUserCheck);
            _internal_token.addEventListener("result",_addLogro_populate_results);
            _internal_token.addEventListener("fault",throwFault); 
            return _internal_token;
		}
        /**
		 * @see IMainService#addLogro_send()
		 */    
        public function addLogro_send():AsyncToken
        {
        	return addLogro(_addLogro_request.cFacebookString,_addLogro_request.nIdSesion,_addLogro_request.cEvento,_addLogro_request.cLogro,_addLogro_request.cUserCheck);
        }
              
		/**
		 * Internal representation of the request wrapper for the operation
		 * @private
		 */
		private var _addLogro_request:AddLogro_request;
		/**
		 * @see IMainService#addLogro_request_var
		 */
		[Bindable]
		public function get addLogro_request_var():AddLogro_request
		{
			return _addLogro_request;
		}
		
		/**
		 * @private
		 */
		public function set addLogro_request_var(request:AddLogro_request):void
		{
			_addLogro_request = request;
		}
		
	  		/**
		 * Internal variable to store the operation's lastResult
		 * @private
		 */
        private var _addLogro_lastResult:String;
		[Bindable]
		/**
		 * @see IMainService#addLogro_lastResult
		 */	  
		public function get addLogro_lastResult():String
		{
			return _addLogro_lastResult;
		}
		/**
		 * @private
		 */
		public function set addLogro_lastResult(lastResult:String):void
		{
			_addLogro_lastResult = lastResult;
		}
		
		/**
		 * @see IMainService#addaddLogro()
		 */
		public function addaddLogroEventListener(listener:Function):void
		{
			addEventListener(AddLogroResultEvent.AddLogro_RESULT,listener);
		}
			
		/**
		 * @private
		 */
        private function _addLogro_populate_results(event:ResultEvent):void
		{
			var e:AddLogroResultEvent = new AddLogroResultEvent();
		            e.result = event.result as String;
		                       e.headers = event.headers;
		             addLogro_lastResult = e.result;
		             dispatchEvent(e);
	        		}
		
		//service-wide functions
		/**
		 * @see IMainService#getWebService()
		 */
		public function getWebService():BaseMainService
		{
			return _baseService;
		}
		
		/**
		 * Set the event listener for the fault event which can be triggered by each of the operations defined by the facade
		 */
		public function addMainServiceFaultEventListener(listener:Function):void
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

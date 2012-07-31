/**
 * BaseMainServiceService.as
 * This file was auto-generated from WSDL by the Apache Axis2 generator modified by Adobe
 * Any change made to this file will be overwritten when the code is re-generated.
 */
package es.desafiate
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import mx.controls.treeClasses.DefaultDataDescriptor;
	import mx.utils.ObjectUtil;
	import mx.utils.ObjectProxy;
	import mx.messaging.events.MessageFaultEvent;
	import mx.messaging.MessageResponder;
	import mx.messaging.messages.SOAPMessage;
	import mx.messaging.messages.ErrorMessage;
   	import mx.messaging.ChannelSet;
	import mx.messaging.channels.DirectHTTPChannel;
	import mx.rpc.*;
	import mx.rpc.events.*;
	import mx.rpc.soap.*;
	import mx.rpc.wsdl.*;
	import mx.rpc.xml.*;
	import mx.rpc.soap.types.*;
	import mx.collections.ArrayCollection;
	
	/**
	 * Base service implementation, extends the AbstractWebService and adds specific functionality for the selected WSDL
	 * It defines the options and properties for each of the WSDL's operations
	 */ 
	public class BaseMainService extends AbstractWebService
    {
		private var results:Object;
		private var schemaMgr:SchemaManager;
		private var BaseMainServiceService:WSDLService;
		private var BaseMainServicePortType:WSDLPortType;
		private var BaseMainServiceBinding:WSDLBinding;
		private var BaseMainServicePort:WSDLPort;
		private var currentOperation:WSDLOperation;
		private var internal_schema:BaseMainServiceSchema;
	
		/**
		 * Constructor for the base service, initializes all of the WSDL's properties
		 * @param [Optional] The LCDS destination (if available) to use to contact the server
		 * @param [Optional] The URL to the WSDL end-point
		 */
		public function BaseMainService(destination:String=null, rootURL:String=null)
		{
			super(destination, rootURL);
			if(destination == null)
			{
				//no destination available; must set it to go directly to the target
				this.useProxy = false;
			}
			else
			{
				//specific destination requested; must set proxying to true
				this.useProxy = true;
			}
			
			if(rootURL != null)
			{
				this.endpointURI = rootURL;
			} 
			else 
			{
				this.endpointURI = null;
			}
			internal_schema = new BaseMainServiceSchema();
			schemaMgr = new SchemaManager();
			for(var i:int;i<internal_schema.schemas.length;i++)
			{
				internal_schema.schemas[i].targetNamespace=internal_schema.targetNamespaces[i];
				schemaMgr.addSchema(internal_schema.schemas[i]);
			}
BaseMainServiceService = new WSDLService("BaseMainServiceService");
			BaseMainServicePort = new WSDLPort("BaseMainServicePort",BaseMainServiceService);
        	BaseMainServiceBinding = new WSDLBinding("BaseMainServiceBinding");
	        BaseMainServicePortType = new WSDLPortType("BaseMainServicePortType");
       		BaseMainServiceBinding.portType = BaseMainServicePortType;
       		BaseMainServicePort.binding = BaseMainServiceBinding;
       		BaseMainServiceService.addPort(BaseMainServicePort);
       		BaseMainServicePort.endpointURI = "http://www.desafiate.es/services/MainService.asmx";
       		if(this.endpointURI == null)
       		{
       			this.endpointURI = BaseMainServicePort.endpointURI; 
       		} 
       		
			var requestMessage:WSDLMessage;
			var responseMessage:WSDLMessage;
			//define the WSDLOperation: new WSDLOperation(methodName)
            var sessionStart:WSDLOperation = new WSDLOperation("sessionStart");
				//input message for the operation
    	        requestMessage = new WSDLMessage("sessionStart");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","cFacebookString"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://tempuri.org/";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://tempuri.org/","sessionStart");
                
                responseMessage = new WSDLMessage("sessionStartResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","sessionStartResult"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://tempuri.org/";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://tempuri.org/","sessionStartResponse");
			sessionStart.inputMessage = requestMessage;
	        sessionStart.outputMessage = responseMessage;
            sessionStart.schemaManager = this.schemaMgr;
            sessionStart.soapAction = "http://tempuri.org/sessionStart";
            sessionStart.style = "document";
            BaseMainServiceService.getPort("BaseMainServicePort").binding.portType.addOperation(sessionStart);
			//define the WSDLOperation: new WSDLOperation(methodName)
            var sessionStartNew:WSDLOperation = new WSDLOperation("sessionStartNew");
				//input message for the operation
    	        requestMessage = new WSDLMessage("sessionStartNew");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","cFacebookString"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","cSessionID"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://tempuri.org/";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://tempuri.org/","sessionStartNew");
                
                responseMessage = new WSDLMessage("sessionStartNewResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","sessionStartNewResult"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://tempuri.org/";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://tempuri.org/","sessionStartNewResponse");
			sessionStartNew.inputMessage = requestMessage;
	        sessionStartNew.outputMessage = responseMessage;
            sessionStartNew.schemaManager = this.schemaMgr;
            sessionStartNew.soapAction = "http://tempuri.org/sessionStartNew";
            sessionStartNew.style = "document";
            BaseMainServiceService.getPort("BaseMainServicePort").binding.portType.addOperation(sessionStartNew);
			//define the WSDLOperation: new WSDLOperation(methodName)
            var keepAlive:WSDLOperation = new WSDLOperation("keepAlive");
				//input message for the operation
    	        requestMessage = new WSDLMessage("keepAlive");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","cFacebookString"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","nIdSesion"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://tempuri.org/";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://tempuri.org/","keepAlive");
                
                responseMessage = new WSDLMessage("keepAliveResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","keepAliveResult"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://tempuri.org/";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://tempuri.org/","keepAliveResponse");
			keepAlive.inputMessage = requestMessage;
	        keepAlive.outputMessage = responseMessage;
            keepAlive.schemaManager = this.schemaMgr;
            keepAlive.soapAction = "http://tempuri.org/keepAlive";
            keepAlive.style = "document";
            BaseMainServiceService.getPort("BaseMainServicePort").binding.portType.addOperation(keepAlive);
			//define the WSDLOperation: new WSDLOperation(methodName)
            var getChecker:WSDLOperation = new WSDLOperation("getChecker");
				//input message for the operation
    	        requestMessage = new WSDLMessage("getChecker");
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://tempuri.org/";
			requestMessage.encoding.useStyle="literal";
                
                responseMessage = new WSDLMessage("getCheckerResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","getCheckerResult"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://tempuri.org/";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://tempuri.org/","getCheckerResponse");
			getChecker.inputMessage = requestMessage;
	        getChecker.outputMessage = responseMessage;
            getChecker.schemaManager = this.schemaMgr;
            getChecker.soapAction = "http://tempuri.org/getChecker";
            getChecker.style = "document";
            BaseMainServiceService.getPort("BaseMainServicePort").binding.portType.addOperation(getChecker);
			//define the WSDLOperation: new WSDLOperation(methodName)
            var getHOF:WSDLOperation = new WSDLOperation("getHOF");
				//input message for the operation
    	        requestMessage = new WSDLMessage("getHOF");
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://tempuri.org/";
			requestMessage.encoding.useStyle="literal";
                
                responseMessage = new WSDLMessage("getHOFResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","getHOFResult"),null,new QName("http://tempuri.org/","ArrayOfUserData")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://tempuri.org/";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://tempuri.org/","getHOFResponse");
			getHOF.inputMessage = requestMessage;
	        getHOF.outputMessage = responseMessage;
            getHOF.schemaManager = this.schemaMgr;
            getHOF.soapAction = "http://tempuri.org/getHOF";
            getHOF.style = "document";
            BaseMainServiceService.getPort("BaseMainServicePort").binding.portType.addOperation(getHOF);
			//define the WSDLOperation: new WSDLOperation(methodName)
            var getUsuario:WSDLOperation = new WSDLOperation("getUsuario");
				//input message for the operation
    	        requestMessage = new WSDLMessage("getUsuario");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","cFacebookString"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","nIdSesion"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","cUserCheck"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://tempuri.org/";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://tempuri.org/","getUsuario");
                
                responseMessage = new WSDLMessage("getUsuarioResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","getUsuarioResult"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://tempuri.org/";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://tempuri.org/","getUsuarioResponse");
			getUsuario.inputMessage = requestMessage;
	        getUsuario.outputMessage = responseMessage;
            getUsuario.schemaManager = this.schemaMgr;
            getUsuario.soapAction = "http://tempuri.org/getUsuario";
            getUsuario.style = "document";
            BaseMainServiceService.getPort("BaseMainServicePort").binding.portType.addOperation(getUsuario);
			//define the WSDLOperation: new WSDLOperation(methodName)
            var saveUsuario:WSDLOperation = new WSDLOperation("saveUsuario");
				//input message for the operation
    	        requestMessage = new WSDLMessage("saveUsuario");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","cFacebookString"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","nIdSesion"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","cxmlProperties"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","cUserCheck"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://tempuri.org/";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://tempuri.org/","saveUsuario");
                
                responseMessage = new WSDLMessage("saveUsuarioResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","saveUsuarioResult"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://tempuri.org/";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://tempuri.org/","saveUsuarioResponse");
			saveUsuario.inputMessage = requestMessage;
	        saveUsuario.outputMessage = responseMessage;
            saveUsuario.schemaManager = this.schemaMgr;
            saveUsuario.soapAction = "http://tempuri.org/saveUsuario";
            saveUsuario.style = "document";
            BaseMainServiceService.getPort("BaseMainServicePort").binding.portType.addOperation(saveUsuario);
			//define the WSDLOperation: new WSDLOperation(methodName)
            var savePuntuacion:WSDLOperation = new WSDLOperation("savePuntuacion");
				//input message for the operation
    	        requestMessage = new WSDLMessage("savePuntuacion");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","cFacebookString"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","nIdSesion"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","cEvento"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","nPuntuacion"),null,new QName("http://www.w3.org/2001/XMLSchema","int")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","cUserCheck"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://tempuri.org/";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://tempuri.org/","savePuntuacion");
                
                responseMessage = new WSDLMessage("savePuntuacionResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","savePuntuacionResult"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://tempuri.org/";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://tempuri.org/","savePuntuacionResponse");
			savePuntuacion.inputMessage = requestMessage;
	        savePuntuacion.outputMessage = responseMessage;
            savePuntuacion.schemaManager = this.schemaMgr;
            savePuntuacion.soapAction = "http://tempuri.org/savePuntuacion";
            savePuntuacion.style = "document";
            BaseMainServiceService.getPort("BaseMainServicePort").binding.portType.addOperation(savePuntuacion);
			//define the WSDLOperation: new WSDLOperation(methodName)
            var addLogro:WSDLOperation = new WSDLOperation("addLogro");
				//input message for the operation
    	        requestMessage = new WSDLMessage("addLogro");
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","cFacebookString"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","nIdSesion"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","cEvento"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","cLogro"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
            				requestMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","cUserCheck"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                requestMessage.encoding = new WSDLEncoding();
                requestMessage.encoding.namespaceURI="http://tempuri.org/";
			requestMessage.encoding.useStyle="literal";
	            requestMessage.isWrapped = true;
	            requestMessage.wrappedQName = new QName("http://tempuri.org/","addLogro");
                
                responseMessage = new WSDLMessage("addLogroResponse");
            				responseMessage.addPart(new WSDLMessagePart(new QName("http://tempuri.org/","addLogroResult"),null,new QName("http://www.w3.org/2001/XMLSchema","string")));
                responseMessage.encoding = new WSDLEncoding();
                responseMessage.encoding.namespaceURI="http://tempuri.org/";
                responseMessage.encoding.useStyle="literal";				
				
	            responseMessage.isWrapped = true;
	            responseMessage.wrappedQName = new QName("http://tempuri.org/","addLogroResponse");
			addLogro.inputMessage = requestMessage;
	        addLogro.outputMessage = responseMessage;
            addLogro.schemaManager = this.schemaMgr;
            addLogro.soapAction = "http://tempuri.org/addLogro";
            addLogro.style = "document";
            BaseMainServiceService.getPort("BaseMainServicePort").binding.portType.addOperation(addLogro);
							SchemaTypeRegistry.getInstance().registerCollectionClass(new QName("http://tempuri.org/","ArrayOfUserData"),es.desafiate.ArrayOfUserData);
							SchemaTypeRegistry.getInstance().registerClass(new QName("http://tempuri.org/","UserData"),es.desafiate.UserData);
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param cFacebookString
		 * @return Asynchronous token
		 */
		public function sessionStart(cFacebookString:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["cFacebookString"] = cFacebookString;
	            currentOperation = BaseMainServiceService.getPort("BaseMainServicePort").binding.portType.getOperation("sessionStart");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param cFacebookString* @param cSessionID
		 * @return Asynchronous token
		 */
		public function sessionStartNew(cFacebookString:String,cSessionID:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["cFacebookString"] = cFacebookString;
	            out["cSessionID"] = cSessionID;
	            currentOperation = BaseMainServiceService.getPort("BaseMainServicePort").binding.portType.getOperation("sessionStartNew");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param cFacebookString* @param nIdSesion
		 * @return Asynchronous token
		 */
		public function keepAlive(cFacebookString:String,nIdSesion:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["cFacebookString"] = cFacebookString;
	            out["nIdSesion"] = nIdSesion;
	            currentOperation = BaseMainServiceService.getPort("BaseMainServicePort").binding.portType.getOperation("keepAlive");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 
		 * @return Asynchronous token
		 */
		public function getChecker():AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            currentOperation = BaseMainServiceService.getPort("BaseMainServicePort").binding.portType.getOperation("getChecker");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 
		 * @return Asynchronous token
		 */
		public function getHOF():AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            currentOperation = BaseMainServiceService.getPort("BaseMainServicePort").binding.portType.getOperation("getHOF");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param cFacebookString* @param nIdSesion* @param cUserCheck
		 * @return Asynchronous token
		 */
		public function getUsuario(cFacebookString:String,nIdSesion:String,cUserCheck:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["cFacebookString"] = cFacebookString;
	            out["nIdSesion"] = nIdSesion;
	            out["cUserCheck"] = cUserCheck;
	            currentOperation = BaseMainServiceService.getPort("BaseMainServicePort").binding.portType.getOperation("getUsuario");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param cFacebookString* @param nIdSesion* @param cxmlProperties* @param cUserCheck
		 * @return Asynchronous token
		 */
		public function saveUsuario(cFacebookString:String,nIdSesion:String,cxmlProperties:String,cUserCheck:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["cFacebookString"] = cFacebookString;
	            out["nIdSesion"] = nIdSesion;
	            out["cxmlProperties"] = cxmlProperties;
	            out["cUserCheck"] = cUserCheck;
	            currentOperation = BaseMainServiceService.getPort("BaseMainServicePort").binding.portType.getOperation("saveUsuario");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param cFacebookString* @param nIdSesion* @param cEvento* @param nPuntuacion* @param cUserCheck
		 * @return Asynchronous token
		 */
		public function savePuntuacion(cFacebookString:String,nIdSesion:String,cEvento:String,nPuntuacion:Number,cUserCheck:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["cFacebookString"] = cFacebookString;
	            out["nIdSesion"] = nIdSesion;
	            out["cEvento"] = cEvento;
	            out["nPuntuacion"] = nPuntuacion;
	            out["cUserCheck"] = cUserCheck;
	            currentOperation = BaseMainServiceService.getPort("BaseMainServicePort").binding.portType.getOperation("savePuntuacion");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
		/**
		 * Performs the low level call to the server for the operation
		 * It passes along the headers and the operation arguments
		 * @param cFacebookString* @param nIdSesion* @param cEvento* @param cLogro* @param cUserCheck
		 * @return Asynchronous token
		 */
		public function addLogro(cFacebookString:String,nIdSesion:String,cEvento:String,cLogro:String,cUserCheck:String):AsyncToken
		{
			var headerArray:Array = new Array();
            var out:Object = new Object();
            out["cFacebookString"] = cFacebookString;
	            out["nIdSesion"] = nIdSesion;
	            out["cEvento"] = cEvento;
	            out["cLogro"] = cLogro;
	            out["cUserCheck"] = cUserCheck;
	            currentOperation = BaseMainServiceService.getPort("BaseMainServicePort").binding.portType.getOperation("addLogro");
            var pc:PendingCall = new PendingCall(out,headerArray);
            call(currentOperation,out,pc.token,pc.headers);
            return pc.token;
		}
        /**
         * Performs the actual call to the remove server
         * It SOAP-encodes the message using the schema and WSDL operation options set above and then calls the server using 
         * an async invoker
         * It also registers internal event handlers for the result / fault cases
         * @private
         */
        private function call(operation:WSDLOperation,args:Object,token:AsyncToken,headers:Array=null):void
        {
	    	var enc:SOAPEncoder = new SOAPEncoder();
	        var soap:Object = new Object;
	        var message:SOAPMessage = new SOAPMessage();
	        enc.wsdlOperation = operation;
	        soap = enc.encodeRequest(args,headers);
	        message.setSOAPAction(operation.soapAction);
	        message.body = soap.toString();
	        message.url=endpointURI;
            var inv:AsyncRequest = new AsyncRequest();
            inv.destination = super.destination;
            //we need this to handle multiple asynchronous calls 
            var wrappedData:Object = new Object();
            wrappedData.operation = currentOperation;
            wrappedData.returnToken = token;
            if(!this.useProxy)
            {
            	var dcs:ChannelSet = new ChannelSet();	
	        	dcs.addChannel(new DirectHTTPChannel("direct_http_channel"));
            	inv.channelSet = dcs;
            }                
            var processRes:AsyncResponder = new AsyncResponder(processResult,faultResult,wrappedData);
            inv.invoke(message,processRes);
		}
        
        /**
         * Internal event handler to process a successful operation call from the server
         * The result is decoded using the schema and operation settings and then the events get passed on to the actual facade that the user employs in the application 
         * @private
         */
		private function processResult(result:Object,wrappedData:Object):void
           {
           		var headers:Object;
           		var token:AsyncToken = wrappedData.returnToken;
                var currentOperation:WSDLOperation = wrappedData.operation;
                var decoder:SOAPDecoder = new SOAPDecoder();
                decoder.resultFormat = "object";
                decoder.headerFormat = "object";
                decoder.multiplePartsFormat = "object";
                decoder.ignoreWhitespace = true;
                decoder.makeObjectsBindable=false;
                decoder.wsdlOperation = currentOperation;
                decoder.schemaManager = currentOperation.schemaManager;
                var body:Object = result.message.body;
                var stringResult:String = String(body);
                if(stringResult == null  || stringResult == "")
                	return;
                var soapResult:SOAPResult = decoder.decodeResponse(result.message.body);
                if(soapResult.isFault)
                {
	                var faults:Array = soapResult.result as Array;
	                for each (var soapFault:Fault in faults)
	                {
		                var soapFaultEvent:FaultEvent = FaultEvent.createEvent(soapFault,token,null);
		                token.dispatchEvent(soapFaultEvent);
	                }
                } else {
	                result = soapResult.result;
	                headers = soapResult.headers;
	                var event:ResultEvent = ResultEvent.createEvent(result,token,null);
	                event.headers = headers;
	                token.dispatchEvent(event);
                }
           }
           	/**
           	 * Handles the cases when there are errors calling the operation on the server
           	 * This is not the case for SOAP faults, which is handled by the SOAP decoder in the result handler
           	 * but more critical errors, like network outage or the impossibility to connect to the server
           	 * The fault is dispatched upwards to the facade so that the user can do something meaningful 
           	 * @private
           	 */
			private function faultResult(error:MessageFaultEvent,token:Object):void
			{
				//when there is a network error the token is actually the wrappedData object from above	
				if(!(token is AsyncToken))
					token = token.returnToken;
				token.dispatchEvent(new FaultEvent(FaultEvent.FAULT,true,true,new Fault(error.faultCode,error.faultString,error.faultDetail)));
			}
		}
	}

	import mx.rpc.AsyncToken;
	import mx.rpc.AsyncResponder;
	import mx.rpc.wsdl.WSDLBinding;
                
    /**
     * Internal class to handle multiple operation call scheduling
     * It allows us to pass data about the operation being encoded / decoded to and from the SOAP encoder / decoder units. 
     * @private
     */
    class PendingCall
    {
		public var args:*;
		public var headers:Array;
		public var token:AsyncToken;
		
		public function PendingCall(args:Object, headers:Array=null)
		{
			this.args = args;
			this.headers = headers;
			this.token = new AsyncToken(null);
		}
	}
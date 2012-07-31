<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="codegen.xslt"/>
  <xsl:import href="codegen.invoke.xslt"/>

  <xsl:template name="comment.service">
    /***********************************************************************
    The generated code provides a simple mechanism for invoking methods
    on the <xsl:value-of select="@fullname" /> class using WebORB. 
    You can add the code to your Flex Builder project and use the 
    class as shown below:

           import <xsl:value-of select="@fullname" />;
           import <xsl:value-of select="@fullname" />Model;

           [Bindable]
           var model:<xsl:value-of select="@name" />Model = new <xsl:value-of select="@name" />Model();
           var serviceProxy:<xsl:value-of select="@name" /> = new <xsl:value-of select="@name" />( model );
           // make sure to substitute foo() with a method from the class
           serviceProxy.foo();
           
    Notice the model variable is shown in the example above as Bindable. 
    You can bind your UI components to the fields in the model object.
    ************************************************************************/
  </xsl:template>
  <!-- xsl:template name="codegen.info">
<b>What has just happened?</b> You selected a class deployed in WebORB and the console produced a corresponding client-side code to invoke methods on the selected class.<br /><br />
<b>What can the generated code do?</b> The generated code accomplishes several goals:<ul>
<li>Generates ActionScript v3 value object classes for all complex types used in the remote .NET class.</li><li>Generates RemoteObject declaration and handler functions for each corresponding remote method</li><li>Generates a utility wrapper class making it easier to perform remoting calls</li>
</ul><br /><b>What can I do with this code?</b> You can download the code, add it to your Flex Builder (or Flex SDK) project and start invoking your .NET methods. The code is the basic minimum one would need to perform a remote invocation. It includes all the stubs for each remote method. Make sure to add your application logic to the handler functions.<br /><br />
<b>How can I download the code?</b> There is a 'Download Code' button in the bottom right corner. The button fetches a zip file with all the generated source code<br />    
  </xsl:template -->
  
   
  <xsl:template name="codegen.service">
    <xsl:if test="count(//datatype) != 0">
        <file name="{@name}.as">
        <xsl:call-template name="codegen.code" />
      </file>

        <file name="{@name}Model.as">
        <xsl:call-template name="codegen.model" />
      </file>

        <file name="DataTypeInitializer.as">
          <xsl:call-template name="codegen.datatypelist">
            <xsl:with-param name="namespaceName" select="@namespace" />
          </xsl:call-template>  
        </file>

        <file name="LockMode.as">
package NHibernate
{	
	[RemoteClass(alias="NHibernate.LockMode")]
	public class LockMode
	{		
		public var level:int;
		public var name:String;
		public var hashcode:int;

	    public function LockMode(level:int, name:String)
		{
			this.level = level;
			this.name = name;
			hashcode = (level * 37) ^ (name != null ? name.length : 0);
		}
		
		/// 
		/// No lock required. 
		/// 
		/// 
		/// If an object is requested with this lock mode, a Read lock
		/// might be obtained if necessary.
		/// 
		public static var None:LockMode = new LockMode(0, "None");

		/// 
		/// A shared lock. 
		/// 
		/// 
		/// Objects are loaded in Read mode by default
		/// 
		public static var Read:LockMode = new LockMode(5, "Read");

		/// 
		/// An upgrade lock. 
		/// 
		/// 
		/// Objects loaded in this lock mode are materialized using an
		/// SQL SELECT ... FOR UPDATE
		/// 
		public static var Upgrade:LockMode = new LockMode(10, "Upgrade");

		/// 
		/// Attempt to obtain an upgrade lock, using an Oracle-style
		/// SELECT ... FOR UPGRADE NOWAIT. 
		/// 
		/// 
		/// The semantics of this lock mode, once obtained, are the same as Upgrade
		/// 
		public static var UpgradeNoWait:LockMode = new LockMode(10, "UpgradeNoWait");

		/// 
		/// A Write lock is obtained when an object is updated or inserted.
		/// 
		/// 
		/// This is not a valid mode for Load() or Lock().
		/// 
		public static var Write:LockMode = new LockMode(10, "Write");

		///  
		/// Similar to  except that, for versioned entities,
		/// it results in a forced version increment.
		/// 
		public static var Force:LockMode = new LockMode(15, "Force");		
	}
}        
        </file>

        <file name="FlushMode.as">
package NHibernate
{
	public class FlushMode
	{
			/// 
			/// Special value for unspecified flush mode (like  in Java).
			/// 
			public static var Unspecified:int = -1;
	
			/// 
			/// The ISession is never flushed unless Flush() is explicitly
			/// called by the application. This mode is very efficient for read only
			/// transactions
			/// 
			public static var Never:int = 0;
			/// 
			/// The ISession is flushed when Transaction.Commit() is called
			/// 
			public static var Commit:int = 5;
			/// 
			/// The ISession is sometimes flushed before query execution in order to
			/// ensure that queries never return stale state. This is the default flush mode.
			/// 
			public static var Auto:int = 10;
			///  
			/// The  is flushed before every query. This is
			/// almost always unnecessary and inefficient.
			/// 
			public static var Always:int = 20;
		}
	}
               
        </file>

        <file name="CacheMode.as">
package NHibernate
{
	public class CacheMode
	{
			///  
		/// The session will never interact with the cache, except to invalidate
		/// cache items when updates occur
		/// 
		public static var Ignore:int = 0;

		///  
		/// The session will never read items from the cache, but will add items
		/// to the cache as it reads them from the database.
		/// 
		public static var Put:int = 1;

		///  
		/// The session may read items from the cache, but will not add items, 
		/// except to invalidate items when updates occur
		/// 
		public static var Get:int = 2;

		///  The session may read items from the cache, and add items to the cache
		public static var Normal:int = Put | Get;

		///  
		/// The session will never read items from the cache, but will add items
		/// to the cache as it reads them from the database. In this mode, the
		/// effect of hibernate.cache.use_minimal_puts is bypassed, in
		/// order to force a cache refresh
		/// 
		public static var Refresh:int = Put | 4; // NH: include Put but have a different value
	}
}
        
        </file>

        <file name="MultiQueryDescriptor.as">
package NHibernate
{
	import flash.utils.ByteArray;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	
	public class MultiQueryDescriptor
	{		 
	  protected var session:NHibernateSession;
	  public var parameters:Array;	
		
	  public function MultiQueryDescriptor( session:NHibernateSession )
	  {
	  	this.session = session;
	  	parameters = new Array();
	  	
	  	parameters["methodName"] = "CreateMultiQuery";	  	
	  }
	  
      public function List( responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = session.remoteObject.MultiList(parameters);
        
        if( responder != null )
            asyncToken.addResponder( responder );
      }
      
 	  public function Add( query:Object ):MultiQueryDescriptor
      {              	    
        parameters.push(["Add", query]);        
        return this;
      } 
            
 	  public function AddHQL( query:String ):MultiQueryDescriptor
      {              	    
        parameters.push(["AddHQL", query]);        
        return this;
      } 
      
 	  public function AddNamedQuery( query:String ):MultiQueryDescriptor
      {              	    
        parameters.push(["AddNamedQuery", query]);        
        return this;
      }	  	       
             
	  public function SetForceCacheRefresh( cacheRegion:Boolean ):MultiQueryDescriptor
	  {
	  	parameters.push(["SetForceCacheRefresh", cacheRegion]);
	  	return this;
	  }		 

	  public function SetCacheable( cacheable:Boolean ):MultiQueryDescriptor
	  {
	  	parameters.push(["SetCacheable", cacheable]);
	  	return this;
	  }	 
	  
	  public function SetCacheRegion( cacheRegion:String ):MultiQueryDescriptor
	  {
	  	parameters.push(["SetCacheRegion", cacheRegion]);
	  	return this;
	  }	 		
	  public function SetTimeout( timeout:int ):MultiQueryDescriptor
	  {
	  	parameters.push(["SetTimeout", timeout]);
	  	return this;
	  }	     
	  
	  public function SetParameter( pos:int, val:Object ):MultiQueryDescriptor
	  {
	  	parameters.push(["SetParameter", pos, val ]);
	  	return this;
	  }	  	  	    	 
	  
	  public function SetParameterList( pos:int, val:Array ):MultiQueryDescriptor
	  {
	  	parameters.push(["SetParameterList", pos, val ]);
	  	return this;
	  }	  	   
	  
	  public function SetAnsiString( pos:int, val:String ):MultiQueryDescriptor
	  {
	  	parameters.push(["SetAnsiString", pos, val ]);
	  	return this;
	  }

	  public function SetBinary( pos:int, val:ByteArray ):MultiQueryDescriptor
	  {
	  	parameters.push(["SetBinary", pos, val ]);
	  	return this;
	  }

	  public function SetBoolean( pos:int, val:Boolean ):MultiQueryDescriptor
	  {
	  	parameters.push(["SetBoolean", pos, val ]);
	  	return this;
	  }

	  public function SetDateTime( pos:int, val:Date ):MultiQueryDescriptor
	  {
	  	parameters.push(["SetDateTime", pos, val ]);
	  	return this;
	  }

	  public function SetNumber( pos:int, val:Number ):MultiQueryDescriptor
	  {
	  	parameters.push(["SetNumber", pos, val]);
	  	return this;
	  }

	  public function SetString( pos:int, val:String ):MultiQueryDescriptor
	  {
	  	parameters.push(["SetString", pos, val ]);
	  	return this;
	  }
	  
	  public function SetInt32( pos:int, val:int ):MultiQueryDescriptor
	  {
	  	parameters.push(["SetInt32", pos, val ]);
	  	return this;
	  }
  
	  public function SetResultTransformer( transformer:Object ):MultiQueryDescriptor
	  {
	  	parameters.push(["SetResultTransformer", transformer]);
	  	return this;
	  }	 
	   	     
	}
}        
        </file>

        <file name="QueryDescriptor.as">
package NHibernate
{
	import flash.utils.ByteArray;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	 
	[RemoteClass(alias="Weborb.Handler.NHibernateUtils.QueryDescriptor")] 
	public class QueryDescriptor
	{
	  protected var session:NHibernateSession;
	  public var parameters:Array;	
		
	  public function QueryDescriptor( session:NHibernateSession, methodName:String, query:String )
	  {
	  	this.session = session;
	  	parameters = new Array();	  	
	  	parameters.push( [ methodName, query ] );
	  }
	  	  
	  public function UniqueResult( responder:IResponder = null ):void
      {            
        var asynchToken:AsyncToken = session.remoteObject.UniqueResult(parameters);
        
        if ( responder!=null )
        	asynchToken.addResponder(responder); 
      } 
	 
	  public function ExecuteUpdate( responder:IResponder = null ):void
      {          
      	var asynchToken:AsyncToken = session.remoteObject.ExecuteUpdate(parameters);
        
        if ( responder!=null )
        	asynchToken.addResponder(responder);   
      }   
	  	  
      public function List( responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = session.remoteObject.List(parameters);
        
        if( responder != null )
            asyncToken.addResponder( responder );
      }	 
	  	  
	  public function SetMaxResults( maxResult:int ):QueryDescriptor
	  {
	  	parameters.push(["SetMaxResults",maxResult]);
	  	return this;
	  }	 
	  
	  public function SetFirstResult( firstResult:int ):QueryDescriptor
	  {
	  	parameters.push(["SetFirstResult", firstResult]);
	  	return this;
	  }	 
	  
	  public function SetReadOnly( readonly:Boolean ):QueryDescriptor
	  {
	  	parameters.push(["SetReadOnly", readonly]);
	  	return this;
	  }	 
	  
	  public function SetFetchSize( fetchSize:int ):QueryDescriptor
	  {
	  	parameters.push(["SetFetchSize",fetchSize]);
	  	return this;
	  }
	  

	  public function SetLockMode( alias:String, lock:LockMode ):QueryDescriptor
	  {
	  	parameters.push(["SetLockMode", alias,lock ]);
	  	return this;
	  }
	  
	  public function SetComment( comment:String ):QueryDescriptor
	  {
	  	parameters.push(["SetComment", comment]);
	  	return this;
	  }


	  public function SetFlushMode( flush:int ):QueryDescriptor
	  {
	  	parameters.push(["SetFlushMode", flush]);
	  	return this;
	  }
	  
	  public function SetCacheMode( cache:int ):QueryDescriptor
	  {
	  	parameters.push(["SetCacheMode", cache]);
	  	return this;
	  }  
	  
	  public function SetNamedParameter( name:String, val:Object ):QueryDescriptor
	  {
	  	parameters.push(["SetNamedParameter", name, val ]);
	  	return this;
	  }	  	  
	  
	  public function SetNamedParameterList( name:String, val:Array ):QueryDescriptor
	  {
	  	parameters.push(["SetNamedParameterList", name, val ]);
	  	return this;
	  }	  	 
	  
	  public function SetProperties( prop:Object ):QueryDescriptor
	  {
	  	parameters.push(["SetProperties", prop]);
	  	return this;
	  }

	  public function SetNamedAnsiString( name:String, val:String ):QueryDescriptor
	  {
	  	parameters.push(["SetNamedAnsiString", name, val ]);
	  	return this;
	  }

	  public function SetNamedString( name:String, val:String ):QueryDescriptor
	  {
	  	parameters.push(["SetNamedString", name, val ]);
	  	return this;
	  }	  

	  public function SetNamedBinary( name:String, val:ByteArray ):QueryDescriptor
	  {
	  	parameters.push(["SetNamedBinary", name, val ]);
	  	return this;
	  }

	  public function SetNamedBoolean( name:String, val:Boolean ):QueryDescriptor
	  {
	  	parameters.push(["SetNamedBoolean", name, val ]);
	  	return this;
	  }

	  public function SetNamedDateTime( name:String, val:Date ):QueryDescriptor
	  {
	  	parameters.push(["SetNamedDateTime", name, val]);
	  	return this;
	  }

	  public function SetNamedNumber( name:String, val:Number ):QueryDescriptor
	  {
	  	parameters.push(["SetNamedNumber", name, val]);
	  	return this;
	  }

	  public function SetNamedEntity( name:String, val:Object ):QueryDescriptor
	  {
	  	parameters.push(["SetNamedEntity", name, val]);
	  	return this;
	  }		
	  
	  public function SetNamedInt32( name:String, val:int ):QueryDescriptor
	  {
	  	parameters.push(["SetNamedInt32", name, val]);
	  	return this;
	  }		

	  public function SetCacheable( cacheable:Boolean ):QueryDescriptor
	  {
	  	parameters.push(["SetCacheable", cacheable]);
	  	return this;
	  }	 
	  
	  public function SetCacheRegion( cacheRegion:String ):QueryDescriptor
	  {
	  	parameters.push(["SetCacheRegion", cacheRegion]);
	  	return this;
	  }	 		
	  public function SetTimeout( timeout:int ):QueryDescriptor
	  {
	  	parameters.push(["SetTimeout", timeout]);
	  	return this;
	  }	     
	  
	  public function SetParameter( pos:int, val:Object ):QueryDescriptor
	  {
	  	parameters.push(["SetParameter", pos, val ]);
	  	return this;
	  }	  	  	    	 
	  
	  public function SetParameterList( pos:int, val:Array ):QueryDescriptor
	  {
	  	parameters.push(["SetParameterList", pos, val ]);
	  	return this;
	  }	  	   
	  
	  public function SetAnsiString( pos:int, val:String ):QueryDescriptor
	  {
	  	parameters.push(["SetAnsiString", pos, val ]);
	  	return this;
	  }

	  public function SetBinary( pos:int, val:ByteArray ):QueryDescriptor
	  {
	  	parameters.push(["SetBinary", pos, val ]);
	  	return this;
	  }

	  public function SetBoolean( pos:int, val:Boolean ):QueryDescriptor
	  {
	  	parameters.push(["SetBoolean", pos, val ]);
	  	return this;
	  }

	  public function SetDateTime( pos:int, val:Date ):QueryDescriptor
	  {
	  	parameters.push(["SetDateTime", pos, val ]);
	  	return this;
	  }

	  public function SetNumber( pos:int, val:Number ):QueryDescriptor
	  {
	  	parameters.push(["SetNumber", pos, val]);
	  	return this;
	  }

	  public function SetString( pos:int, val:String ):QueryDescriptor
	  {
	  	parameters.push(["SetString", pos, val ]);
	  	return this;
	  }
	  
	  public function SetInt32( pos:int, val:int ):QueryDescriptor
	  {
	  	parameters.push(["SetInt32", pos, val ]);
	  	return this;
	  }
 
	  public function SetResultTransformer( transformer:Object ):QueryDescriptor
	  {
	  	parameters.push(["SetResultTransformer", transformer]);
	  	return this;
	  }	 	  
	    	  	  	   
	}
}                    
        </file>

        <file name="SQLQueryDescriptor.as">
package NHibernate
{
	public class SQLQueryDescriptor extends QueryDescriptor
	{
		public function SQLQueryDescriptor(session:NHibernateSession, methodName:String, query:String)
		{
			super(session, methodName, query);
		}
	
		public function AddEntity(entityName:String):SQLQueryDescriptor
		{
			parameters.push(["AddEntity",entityName]);
	  		return this;
		}
	
		public function AddJoin(alias:String, path:String):SQLQueryDescriptor
		{
			parameters.push(["AddJoin",alias, path]);
	  		return this;
		}		

		public function SetResultSetMapping(name:String):SQLQueryDescriptor
		{
			parameters.push(["SetResultSetMapping",name]);
	  		return this;
		}						
	}
}        
        </file>
      </xsl:if>  
      
    <xsl:if test="method[@containsvalues=1]">

    <folder name="testdrive">
      <xsl:for-each select="method[@containsvalues=1]">
        <file name="{@name}Invoke.as">
          <xsl:call-template name="codegen.description">
            <xsl:with-param name="file-name" select="concat(@name,'Invoke.as')" />
          </xsl:call-template>

      package <xsl:value-of select="../@namespace" />.testdrive
      {
      <xsl:if test="//datatype">
        import <xsl:value-of select="../@namespace" />.vo.*;
      </xsl:if>
        import <xsl:value-of select="../@namespace" />.*;
        
        public class <xsl:value-of select="@name" />Invoke
        {
          var m_service:<xsl:value-of select="../@name"/> = new <xsl:value-of select="../@name"/>();
        
          public function Execute():void
          {
            <xsl:call-template name="codegen.invoke.method" />
          }
        }
      }
        </file>   
      </xsl:for-each>
    </folder>

    </xsl:if>

     
  </xsl:template>


  <xsl:template name="codegen.invoke.method.name">
    m_service.<xsl:value-of select="@name"/>
  </xsl:template>
  
  <xsl:template name="codegen.code">   
    /*******************************************************************
    * GlobalSession.as
    * Copyright (C) 2006-2010 Midnight Coders, Inc.
    *
    * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
    * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
    * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    ********************************************************************/
    
    /***********************************************************************
    The generated code provides a simple mechanism for invoking methods
    on the NHibernate.GlobalSession class using WebORB. 
    You can add the code to your Flex Builder project and use the 
    class as shown below:

           import NHibernate.GlobalSession;
           import NHibernate.GlobalSessionModel;

           [Bindable]
           var model:GlobalSessionModel = new GlobalSessionModel();
           var serviceProxy:GlobalSession = new GlobalSession( model );
           // make sure to substitute foo() with a method from the class
           serviceProxy.foo();
           
    Notice the model variable is shown in the example above as Bindable. 
    You can bind your UI components to the fields in the model object.
    ************************************************************************/
  
    package NHibernate
    {
    import Weborb.Examples.PizzaService.vo.*;
    import Weborb.Examples.vo.*;
    
    import mx.controls.Alert;
    import mx.rpc.AsyncToken;
    import mx.rpc.IResponder;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.ResultEvent;
    import mx.rpc.remoting.RemoteObject;
        
    public class NHibernateSession
    {
      public var remoteObject:RemoteObject;
      private var model:GlobalSessionModel; 

      public function NHibernateSession( model:GlobalSessionModel = null )
      {
        remoteObject  = new RemoteObject("GenericDestination");
        remoteObject.source = "NHibernate.GlobalSession";          
                
        remoteObject.DeleteByQuery.addEventListener("result",DeleteByQueryHandler);
        
        remoteObject.Delete.addEventListener("result",DeleteHandler);
        
        remoteObject.Find.addEventListener("result",FindHandler);
        
        remoteObject.Get.addEventListener("result",GetHandler);
        
        remoteObject.Load.addEventListener("result",LoadHandler);
        
        remoteObject.Save.addEventListener("result",SaveHandler);
        
        remoteObject.SaveOrUpdate.addEventListener("result",SaveOrUpdateHandler);
        
        remoteObject.Update.addEventListener("result",UpdateHandler);
        
        remoteObject.addEventListener("fault", onFault);
        
        if( model == null )
            model = new GlobalSessionModel();
    
        this.model = model;

      }
      
      public function setCredentials( userid:String, password:String ):void
      {
        remoteObject.setCredentials( userid, password );
      }

      public function GetModel():GlobalSessionModel
      {
        return this.model;
      }        
    
      public function CreateQuery(queryString:String):QueryDescriptor
      {
		    return new QueryDescriptor(this, "CreateQuery", queryString);
      }
    
      public function CreateMultiQuery():MultiQueryDescriptor
      {
       return new MultiQueryDescriptor(this);
      }    
    
      public function CreateSQLQuery(queryString:String):SQLQueryDescriptor
      {
		    return new SQLQueryDescriptor(this, "CreateSQLQuery", queryString);
      }
    
      public function GetNamedQuery( name:String ):QueryDescriptor
      {
        return new QueryDescriptor(this, "GetNamedQuery", name);
      }    
    
      public function DeleteByQuery(query:String, responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.DeleteByQuery(query);
        
        if( responder != null )
            asyncToken.addResponder( responder );
      }
    
      public function Delete(obj:Object, responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.Delete(obj);
        
        if( responder != null )
            asyncToken.addResponder( responder );
      }
    
      public function Find(query:String, responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.Find(query);
        
        if( responder != null )
            asyncToken.addResponder( responder );
      }
    
      public function Get(entityName:String, id:Object, responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.Get(entityName,id);
        
        if( responder != null )
            asyncToken.addResponder( responder );
      }
    
      public function Load(entityName:String, id:Object, responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.Load(entityName,id);
        
        if( responder != null )
            asyncToken.addResponder( responder );
      }
    
      public function Save(obj:Object, responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.Save(obj);
        
        if( responder != null )
            asyncToken.addResponder( responder );
      }
    
      public function SaveOrUpdate(obj:Object, responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.SaveOrUpdate(obj);
        
        if( responder != null )
            asyncToken.addResponder( responder );
      }
    
      public function Update(obj:Object, responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.Update(obj);
        
        if( responder != null )
            asyncToken.addResponder( responder );
      }
         
      public virtual function CreateMultiQueryHandler(event:ResultEvent):void
      {        
          var returnValue:Object = event.result as Object;
          model.CreateMultiQueryResult = returnValue;     
      }
         
         
      public virtual function DeleteByQueryHandler(event:ResultEvent):void
      {
          var returnValue:int = event.result as int;
          model.DeleteByQueryResult = returnValue;       
      }
         
      public virtual function DeleteHandler(event:ResultEvent):void
      {
        
      }
         
      public virtual function FindHandler(event:ResultEvent):void
      {        
          var returnValue:Array = event.result as Array;
          model.FindResult = returnValue;        
      }
         
      public virtual function GetHandler(event:ResultEvent):void
      {        
          var returnValue:Object = event.result as Object;
          model.GetResult = returnValue;        
      }
         
      public virtual function LoadHandler(event:ResultEvent):void
      {       
          var returnValue:Object = event.result as Object;
          model.LoadResult = returnValue;        
      }
         
      public virtual function SaveHandler(event:ResultEvent):void
      {        
          var returnValue:Object = event.result as Object;
          model.SaveResult = returnValue;        
      }
         
      public virtual function SaveOrUpdateHandler(event:ResultEvent):void
      {
        
      }
         
      public virtual function UpdateHandler(event:ResultEvent):void
      {
        
      }
    
      public function onFault (event:FaultEvent):void
      {
        Alert.show(event.fault.faultString, "Error");
      }
    }
  }         
  </xsl:template>
  
  <xsl:template name="codegen.model">
    <xsl:call-template name="codegen.description">
      <xsl:with-param name="file-name" select="concat(@name,'Model.as')" />
    </xsl:call-template>
    
    package <xsl:value-of select="@namespace" />
    {    <xsl:for-each select="//namespace">    
    <xsl:if test="datatype">
      import <xsl:value-of select="@fullname" />.vo.*;</xsl:if>
    </xsl:for-each>
      [Bindable]
      public class <xsl:value-of select="@name"/>Model
      {<xsl:for-each select="method"><xsl:if test="@type != 'void'">     
        public var <xsl:value-of select="@name" />Result:<xsl:value-of select="@type" />;</xsl:if></xsl:for-each>
      }
    }
  </xsl:template>

</xsl:stylesheet>

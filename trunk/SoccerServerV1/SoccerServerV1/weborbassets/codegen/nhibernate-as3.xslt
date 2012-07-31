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
   <file name="DataTypeInitializer.as">
     <xsl:call-template name="codegen.datatypelist">
       <xsl:with-param name="namespaceName" select="@namespace" />
     </xsl:call-template>  
   </file>   
  </xsl:if>
</xsl:template>  

<xsl:template name="codegen.projectspecific">
<folder name="weborb">
<folder name="nhibernate">
  <xsl:if test="count(//datatype) != 0">
    <xsl:call-template name="codegen.code" />
     <file name="NHibernateModel.as">
  <xsl:call-template name="codegen.description">
   <xsl:with-param name="file-name">NHibernateModel.as</xsl:with-param>
  </xsl:call-template>
       
 package weborb.nhibernate
 {    
   /**
   * A bindable model class used by NHibernateSession to receive results of asynchronous method invocations.
   * NHibernateSession updates the model object with the return values of the remoting invocations.
   */ 
   [Bindable]
   public class NHibernateModel
   {
     /**
     * Contains return value of the most recent NHibernateSession.DeleteByQuery() invocation.
     */ 
   public var DeleteByQueryResult:int;
   
   /**
   * Contains return value of the most recent NHibernateSession.Find() invocation.
   */ 
   public var FindResult:Array;
   
   /**
   * Contains return value of the most recent NHibernateSession.Get() invocation.
   */ 
   public var GetResult:Object;
   
   /**
    * Contains return value of the most recent NHibernateSession.Load() invocation.
    */ 
   public var LoadResult:Object;
   
   /**
    * Contains return value of the most recent NHibernateSession.Save() invocation.
    */ 
   public var SaveResult:Object;
   }
  }
     </file>
    <file name="LockMode.as">
package weborb.nhibernate
{ 
  /**
  * Instances represent a lock mode for a row of a relational database table.
  */ 
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
    
    /**
    * No lock required. 
    * If an object is requested with this lock mode, a Read lock
    * might be obtained if necessary.
    */ 
    public static var None:LockMode = new LockMode(0, "None");

    /** 
    * A shared lock. 
    *  
    * Objects are loaded in Read mode by default
    */ 
    public static var Read:LockMode = new LockMode(5, "Read");

    /** 
    * An upgrade lock. 
    * 
    * Objects loaded in this lock mode are materialized using an
    * SQL SELECT ... FOR UPDATE
    */ 
    public static var Upgrade:LockMode = new LockMode(10, "Upgrade");

    /** 
    * Attempt to obtain an upgrade lock, using an Oracle-style
    * SELECT ... FOR UPGRADE NOWAIT. 
    * 
    * The semantics of this lock mode, once obtained, are the same as Upgrade
    */ 
    public static var UpgradeNoWait:LockMode = new LockMode(10, "UpgradeNoWait");

    /**
    * A Write lock is obtained when an object is updated or inserted.
    * This is not a valid mode for Load() or Lock().
    */ 
    public static var Write:LockMode = new LockMode(10, "Write");

    /**  
    * Similar to  except that, for versioned entities,
    * it results in a forced version increment.
    */ 
    public static var Force:LockMode = new LockMode(15, "Force");   
  }
}  
    </file>

    <file name="FlushMode.as">
package weborb.nhibernate
{
  /**
  * Represents a flushing strategy. The flush process synchronizes database state with session
  * state by detecting state changes and executing SQL statements.
  */ 
  public class FlushMode
  {
      /** 
      * Special value for unspecified flush mode (like  in Java).
      */
      public static var Unspecified:int = -1;
  
      /** 
      * The ISession is never flushed unless Flush() is explicitly
      * called by the application. This mode is very efficient for read only
      * transactions
      */ 
      public static var Never:int = 0;
      
      /** 
      * The ISession is flushed when Transaction.Commit() is called
      */ 
      public static var Commit:int = 5;
      
      /** 
      * The ISession is sometimes flushed before query execution in order to
      * ensure that queries never return stale state. This is the default flush mode.
      */ 
      public static var Auto:int = 10;
      
      /**  
      * The  is flushed before every query. This is
      * almost always unnecessary and inefficient.
      */ 
      public static var Always:int = 20;
    }
  }   
    </file>

<file name="CacheMode.as">
package weborb.nhibernate
{
  /**
  * Controls how the session interacts with the second-level cache and query cache.
  */ 
  public class CacheMode
  {
    /**
    * The session will never interact with the cache, except to invalidate
    * cache items when updates occur
    */ 
    public static var Ignore:int = 0;

    /**  
    * The session will never read items from the cache, but will add items
    * to the cache as it reads them from the database.
    */ 
    public static var Put:int = 1;

    /**  
    * The session may read items from the cache, but will not add items, 
    * except to invalidate items when updates occur
    */ 
    public static var Get:int = 2;

    /**
    *  The session may read items from the cache, and add items to the cache
    */ 
    public static var Normal:int = Put | Get;

    /**  
    * The session will never read items from the cache, but will add items
    * to the cache as it reads them from the database. In this mode, the
    * effect of hibernate.cache.use_minimal_puts is bypassed, in
    * order to force a cache refresh
    */ 
    public static var Refresh:int = Put | 4; // NH: include Put but have a different value
  }
}
</file>
<file name="MultiQueryDescriptor.as">
package weborb.nhibernate
{
  import flash.utils.ByteArray;
  
  import mx.rpc.AsyncToken;
  import mx.rpc.IResponder;
  
  /**
  * The class enables functionality to execute several HQL queries in one round-trip against
  * the database server. A simple use case is executing a paged query while also getting the
  * total count of results, in a single round-trip. Instances of MultiQueryDescriptor can be
  * created using NHibernateSession.CreateMultiQuery().
  */ 
  public class MultiQueryDescriptor
  {    
    protected var session:NHibernateSession;
    public var parameters:Array;  
    
    public function MultiQueryDescriptor( session:NHibernateSession )
    {
      this.session = session;
      parameters = new Array();
      
      parameters.push( [ "CreateMultiQuery" ] );
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
package weborb.nhibernate
{
  import flash.utils.ByteArray;
  
  import mx.rpc.AsyncToken;
  import mx.rpc.IResponder;
   
  /**
  * Enables functionality to run advanced HQL queries. 
  */ 
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
package weborb.nhibernate
{
  /**
  * The class enables functionality to execute SQL queries against the database server. 
  * Instances of SQLQueryDescriptor can be created using NHibernateSession.CreateSQLQuery().
  */ 
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

</folder>
</folder>
</xsl:template>
  



  <xsl:template name="codegen.invoke.method.name">
    m_service.<xsl:value-of select="@name"/>
  </xsl:template>
  
  <xsl:template name="codegen.code">   
  <file name="NHibernateSession.as">
    <xsl:call-template name="codegen.description">
     <xsl:with-param name="file-name">NHibernateSession.as</xsl:with-param>
  </xsl:call-template>
/***********************************************************************
 The generated code provides a simple mechanism for invoking methods
 on the weborb.nhibernate.NHibernateSession class using WebORB. 
 You can add the code to your Flex Builder project and use the 
 class as shown below:

       import weborb.nhibernate.NHibernateSession;
       import weborb.nhibernate.NHibernateModel;

       [Bindable]
       var model:NHibernateModel = new NHibernateModel();
       var serviceProxy:NHibernateSession = new NHibernateSession( model );
       // make sure to substitute foo() with a method from the class
       serviceProxy.foo();

  Notice the model variable is shown in the example above as Bindable. 
  You can bind your UI components to the fields in the model object.
************************************************************************/
  
    package weborb.nhibernate
    {
    import mx.controls.Alert;
    import mx.rpc.AsyncToken;
    import mx.rpc.IResponder;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.ResultEvent;
    import mx.rpc.remoting.RemoteObject;
    
    /**
    * Main class providing access to the remote persistent NHibernate entities. The
    * class enables remote data retrieval, entity creation, deletion and modification. Instances of
    * NHibernateSession can be constructed either with a model object which will be automatically 
    * updated when return values of the remote invocations become available. Alternatively,
    * all functions which result in remote method invocations accept mx.rpc.Responder object
    * which will be used for success/fault callbacks.
    */   
    public class NHibernateSession
    {
      /**
      * RemoteObject instance responsible for proxying client invocations to the server. The instance is 
      * initialized to use <code>GenericDestination</code> and targets the <code>NHibernate.NHibernateSession</code> virtual 
      * remoting service.
      */ 
      public var remoteObject:RemoteObject;
      private var model:NHibernateModel; 
      
      /**
      * Creates an instance of the class, sets up listeners for the remote invocations. If the model argument
      * is not specified, the constructor creates the default model object which can be obtained using the GetModel() 
      * function.
      */
      public function NHibernateSession( model:NHibernateModel = null )
      {
        remoteObject  = new RemoteObject("GenericDestination");
        remoteObject.source = "NHibernate.NHibernateSession";          
                
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
            model = new NHibernateModel();
    
        this.model = model;

      }
      
      /**
      * Associates user credentials (userid and password) with RemoteObject used internally by 
      * this instance.
      */ 
      public function setCredentials( userid:String, password:String ):void
      {
        remoteObject.setCredentials( userid, password );
      }

      /**
      * Returns the model object associated with this instance of NHibernateSession
      */ 
      public function GetModel():NHibernateModel
      {
        return this.model;
      }        
    
      /**
      * Constructs a QueryDescriptor object with the specified HQL query. The
      * QueryDescriptor is a client-side analogy to the <a href="http://nhforge.org/doc/nh/en/index.html#manipulatingdata-queryinterface">NHibernate.IQuery</a> interface.
      * The function serves as a factory method for the QueryDescriptor object and does not issue any remoting invocations.
      * @param queryString HQL statement to be executed by the created QueryDescriptor.
      * @return QueryDescriptor instance containing the specified query.
      * @example The following code demonstrates the usage of the method:
      * <listing version="3.0">
      * var nhibernateSession:NHibernateSession = new NHibernateSession();
      * var hqlQuery = "from Customer c where c.Orders.size > 0";
      * var queryDescriptor:QueryDescriptor = nhibernateSession.CreateQuery( hqlQuery );
      * var responder:mx.rpc.Responder = new mx.rpc.Responder( gotResult, gotError );
      * queryDescriptor.List( responder );
      * 
      * public function gotResult( evt:ResultEvent ):void
      * {
      *   // result is an array of Customer objects
      *   var results:Array = evt.result as Array;
      * }
      * 
      * public function gotError( evt:FaultEvent ):void
      * {
      * }
      * </listing>
      * @see weborb.nhibernate.QueryDescriptor
      */ 
      public function CreateQuery(queryString:String):QueryDescriptor
      {
        return new QueryDescriptor(this, "CreateQuery", queryString);
      }
      
      /**
      * Constructs a MultiQueryDescriptor object. The
      * MultiQueryDescriptor is a client-side analogy to the <a href="http://nhforge.org/doc/nh/en/index.html#performance-multi-query">NHibernate.IMultiQuery</a> interface.
      * The function serves as a factory method for the MultiQueryDescriptor object and does not issue any remoting invocations.
      * @example The following code demonstrates the usage of the method:
      * <listing version="3.0">
      * var nhibernateSession:NHibernateSession = new NHibernateSession();
      * var multiQuery:MultiQueryDescriptor = nhibernateSession.CreateMultiQuery();
      * 
      * var query1 = "from Customer c where c.Orders.size > 0";
      * multiQuery.AddHQL( query1 );
      * 
      * var query2 = "from Product p where p.ID > 10";
      * multiQuery.AddHQL( query2 );
      * 
      * var responder:mx.rpc.Responder = new mx.rpc.Responder( gotResult, gotError );
      * multiQuery.List( responder );
      * 
      * public function gotResult( evt:ResultEvent ):void
      * {
      *   // result is an array of arrays
      *   var results:Array = evt.result as Array;
      *   var customers:Array = results[ 0 ] as Array;
      *   var products:Array = results[ 1 ] as Array;
      * }
      * 
      * public function gotError( evt:FaultEvent ):void
      * {
      * }
      * </listing>
      * @see weborb.nhibernate.MultiQueryDescriptor
      */ 
      public function CreateMultiQuery():MultiQueryDescriptor
      {
       return new MultiQueryDescriptor(this);
      }    
    
      /**
      * Create a new instance of SQLQueryDescriptor for the given SQL query string.
      * SQLQueryDescriptor is a client-side analogy to the <a href="http://nhforge.org/doc/nh/en/index.html#manipulatingdata-queryinterface">NHibernate.IQuery</a> interface.
      * The function serves as a factory method for the SQLQueryDescriptor object and does not issue any remoting invocations.
      * @example The following code demonstrates the usage of the method:
      * <listing version="3.0">
      * var nhibernateSession:NHibernateSession = new NHibernateSession();
      * var sqlQuery = "select * from Customer";
      * var sqlQueryDescriptor:SQLQueryDescriptor = nhibernateSession.CreateSQLQuery( sqlQuery );
      * 
      * var responder:mx.rpc.Responder = new mx.rpc.Responder( gotResult, gotError );
      * sqlQueryDescriptor.List( responder );
      * 
      * public function gotResult( evt:ResultEvent ):void
      * {
      *   // result is an array of Customer objects
      *   var results:Array = evt.result as Array;
      * }
      * 
      * public function gotError( evt:FaultEvent ):void
      * {
      * }
      * </listing>
      */ 
      public function CreateSQLQuery(queryString:String):SQLQueryDescriptor
      {
      return new SQLQueryDescriptor(this, "CreateSQLQuery", queryString);
      }
      
      /**
      * Obtains an instance of QueryDescriptor for a named query string defined in the mapping file.
      * Requests issued using the created QueryDescriptor will be executed with the query string from the mapping file.
    * @param name  The name of a query defined externally.
      */ 
      public function GetNamedQuery( name:String ):QueryDescriptor
      {
        return new QueryDescriptor(this, "GetNamedQuery", name);
      }    
      
      /**
      * Deletes all objects returned by the query.
      * 
      * @param query HQL query string
      * @param responder optional Responder object with references to the success/failure callback functions. 
      * The model object associated with NHibernateSession is updated regardless whether the responder object is present in the argument list or not.
      * 
      * @example The following code demonstrates the usage of the method:
      * <listing version="3.0">
      * var nhibernateSession:NHibernateSession = new NHibernateSession();
      * var hqlQuery = "from Customer c where c.Orders.size > 0";
      * var responder:mx.rpc.Responder = new mx.rpc.Responder( deleteSucceeded, deleteFailed );
      * nhibernateSession.DeleteByQuery( hqlQuery, responder );
      * 
      * public function deleteSucceeded( evt:ResultEvent ):void
      * {
      * }
      * 
      * public function deleteFailed( evt:FaultEvent ):void
      * {
      * }
      * </listing>
      */ 
      public function DeleteByQuery(query:String, responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.DeleteByQuery(query);
        
        if( responder != null )
            asyncToken.addResponder( responder );
      }
    
      /**
      * Deletes a persistent entity identified by an ActionScript object.
      * @param obj an instance of a value object generated by WebORB. The object
      * represents a persistent NHibernate entity.
      * @param responder optional Responder object with references to the success/failure callback functions. 
      * The model object associated with NHibernateSession is updated regardless whether the responder object is present in the argument list or not.
      * @example The following code demonstrates the usage of the method:
      * <listing version="3.0">
      * var nhibernateSession:NHibernateSession = new NHibernateSession();
      * var customer:Customer = new Customer();
      * customer.ID = 10;
      * var responder:mx.rpc.Responder = new mx.rpc.Responder( deleteSucceeded, deleteFailed );
      * nhibernateSession.Delete( customer, responder );
      * 
      * public function deleteSucceeded( evt:ResultEvent ):void
      * {
      * }
      * 
      * public function deleteFailed( evt:FaultEvent ):void
      * {
      * }
      * </listing>
      */ 
      public function Delete(obj:Object, responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.Delete(obj);
        
        if( responder != null )
            asyncToken.addResponder( responder );
      }
    
      /**
      * Executes a query expressed in HQL.
      * @param query hql query to execute
      * @param responder optional Responder object with references to the success/failure callback functions. 
      * The model object associated with NHibernateSession is updated regardless whether the responder object is present in the argument list or not.
      * @example The following code demonstrates the usage of the method:
      * <listing version="3.0">
      * var nhibernateSession:NHibernateSession = new NHibernateSession();
      * var hqlQuery:String = "from Customer c where c.Orders.size > 1"
      * var responder:mx.rpc.Responder = new mx.rpc.Responder( gotResult, gotFault );
      * nhibernateSession.Find( hqlQuery, responder );
      * 
      * public function gotResult( evt:ResultEvent ):void
      * {
      *   // evt.result is an array of Customer objects
      *   var customers:Array = evt.result as Array;
      * }
      * 
      * public function gotFault( evt:FaultEvent ):void
      * {
      * }
      * </listing>
      */ 
      public function Find(query:String, responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.Find(query);
        
        if( responder != null )
            asyncToken.addResponder( responder );
      }
      
      /**
     * Return the persistent instance of the given named entity with the given identifier,
     * or null if there is no such persistent instance. (If the instance, or a proxy for the
     * instance, is already associated with the session, return that instance or proxy.) 
       * @param entityName the entity name as specified in the mapping file
       * @param id the identifier of the entity
       * @param responder optional Responder object with references to the success/failure callback functions. 
       * The model object associated with NHibernateSession is updated regardless whether the responder object is present in the argument list or not.
       * @example The following code demonstrates the usage of the method:
       * <listing version="3.0">
       * var nhibernateSession:NHibernateSession = new NHibernateSession();
       * var responder:mx.rpc.Responder = new mx.rpc.Responder( gotResult, gotFault );
       * nhibernateSession.Get( "Order", 1, responder );
       * 
       * public function gotResult( evt:ResultEvent ):void
       * {
       *   // evt.result is an instance of the Order class
       *   var order:Order = evt.result as Order;
       * }
       * 
       * public function gotFault( evt:FaultEvent ):void
       * {
       * }
       * </listing>
       */     
      public function Get(entityName:String, id:Object, responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.Get(entityName,id);
        
        if( responder != null )
            asyncToken.addResponder( responder );
      }
      
      /**
       * Return the persistent instance of the given entity class with the given identifier,
       * obtaining the specified lock mode, assuming the instance exists. 
       * @param entityName the entity name as specified in the mapping file
       * @param id the identifier of the entity
       * @param responder optional Responder object with references to the success/failure callback functions. 
       * The model object associated with NHibernateSession is updated regardless whether the responder object is present in the argument list or not.
       * @example The following code demonstrates the usage of the method:
       * <listing version="3.0">
       * var nhibernateSession:NHibernateSession = new NHibernateSession();
       * var responder:mx.rpc.Responder = new mx.rpc.Responder( gotResult, gotFault );
       * nhibernateSession.Load( "Order", 1, responder );
       * 
       * public function gotResult( evt:ResultEvent ):void
       * {
       *   // evt.result is an instance of the Order class
       *   var order:Order = evt.result as Order;
       * }
       * 
       * public function gotFault( evt:FaultEvent ):void
       * {
       * }
       * </listing>
       */     
      public function Load(entityName:String, id:Object, responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.Load(entityName,id);
        
        if( responder != null )
            asyncToken.addResponder( responder );
      }
      
      
      /**
       * Persists the given entity identified , first assigning a generated identifier.
       * @param obj an instance of a value object generated by WebORB. The object
       * represents a persistent NHibernate entity.
       * @param responder optional Responder object with references to the success/failure callback functions. 
       * The model object associated with NHibernateSession is updated regardless whether the responder object is present in the argument list or not.
       * @example The following code demonstrates the usage of the method:
       * <listing version="3.0">
       * var nhibernateSession:NHibernateSession = new NHibernateSession();
       * var customer:Customer = new Customer();
       * customer.Name = "FooBar, Inc";
       * var responder:mx.rpc.Responder = new mx.rpc.Responder( objectSaved, gotError );
       * nhibernateSession.Save( customer, responder );
       * 
       * public function objectSaved( evt:ResultEvent ):void
       * {
       *   // result event contains the saved object:
       *   var customer:Customer = evt.result as Customer;
       * }
       * 
       * public function gotError( evt:FaultEvent ):void
       * {
       * }
       * </listing>
       */    
      public function Save(obj:Object, responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.Save(obj);
        
        if( responder != null )
            asyncToken.addResponder( responder );
      }
      
      /**
       * Executes either <code>Save()</code> or <code>Update()</code> for the given instance, depending upon the value
       * of its identifier property. By default the instance is always saved. This behaviour may be adjusted by specifying
     * an <code>unsaved-value</code> attribute of the identifier property mapping.
       * @param obj an instance of a value object generated by WebORB. The object
       * represents a persistent NHibernate entity.
       * @param responder optional Responder object with references to the success/failure callback functions. 
       * The model object associated with NHibernateSession is updated regardless whether the responder object is present in the argument list or not.
       */ 
      public function SaveOrUpdate(obj:Object, responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.SaveOrUpdate(obj);
        
        if( responder != null )
            asyncToken.addResponder( responder );
      }
      
      /**
       * Updates the given entity identified , first assigning a generated identifier.
       * @param obj an instance of a value object generated by WebORB. The object
       * represents a persistent NHibernate entity.
       * @param responder optional Responder object with references to the success/failure callback functions. 
       * The model object associated with NHibernateSession is updated regardless whether the responder object is present in the argument list or not.
       */ 
      public function Update(obj:Object, responder:IResponder = null ):void
      {
        var asyncToken:AsyncToken = remoteObject.Update(obj);
        
        if( responder != null )
            asyncToken.addResponder( responder );
      }
        
         
      /**
       * @private
       */    
      public virtual function DeleteByQueryHandler(event:ResultEvent):void
      {
          var returnValue:int = event.result as int;
          model.DeleteByQueryResult = returnValue;       
      }
      
      /**
       * @private
       */ 
      public virtual function DeleteHandler(event:ResultEvent):void
      {
        
      }
      
      /**
       * @private
       */ 
      public virtual function FindHandler(event:ResultEvent):void
      {        
          var returnValue:Array = event.result as Array;
          model.FindResult = returnValue;        
      }
      
      /**
       * @private
       */ 
      public virtual function GetHandler(event:ResultEvent):void
      {        
          var returnValue:Object = event.result as Object;
          model.GetResult = returnValue;        
      }
      
      /**
       * @private
       */ 
      public virtual function LoadHandler(event:ResultEvent):void
      {       
          var returnValue:Object = event.result as Object;
          model.LoadResult = returnValue;        
      }
      
      /**
       * @private
       */ 
      public virtual function SaveHandler(event:ResultEvent):void
      {        
          var returnValue:Object = event.result as Object;
          model.SaveResult = returnValue;        
      }
      
      /**
       * @private
       */ 
      public virtual function SaveOrUpdateHandler(event:ResultEvent):void
      {
        
      }
      
      /**
       * @private
       */ 
      public virtual function UpdateHandler(event:ResultEvent):void
      {
        
      }
    
      /**
       * @private
       */ 
      public function onFault (event:FaultEvent):void
      {
        Alert.show(event.fault.faultDetail, "Error");
      } 
    }
  } 
  </file>
  </xsl:template>
  </xsl:stylesheet>
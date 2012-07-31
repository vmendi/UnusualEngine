<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
    xmlns:codegen="urn:cogegen-xslt-lib:xslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:import href="codegen.xslt"/>
  <xsl:import href="codegen.invoke.xslt"/>


    <xsl:template name="codegen.appmain">
<file name="main.mxml" type="xml">
<mx:Application xmlns:mx="http://www.adobe.com/2006/mxml" layout="absolute" initialize="onLoad()">
  <mx:Script>
    &lt;![CDATA[
  <xsl:if test="count(//datatype) != 0">
  import <xsl:value-of select="//service/@namespace"/>.DataTypeInitializer;
  </xsl:if>
  public function onLoad():void
    {
    <xsl:if test="count(//datatype) != 0">
      new DataTypeInitializer();
    </xsl:if>
    }
    ]]&gt;
  </mx:Script>
</mx:Application>
    </file>
    </xsl:template>

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

  <xsl:template name="codegen.vo">
    <xsl:param name="version" select="3" />
      <file name="{@name}.as">
        <xsl:call-template name="codegen.description">
          <xsl:with-param name="file-name" select="concat(@name,'.as')" />
        </xsl:call-template>
        <xsl:if test="$version=3">
          package <xsl:value-of select="../@fullname" />.vo
          {
          import flash.utils.ByteArray;
          import mx.collections.ArrayCollection;

          [Bindable]
          [RemoteClass(alias="<xsl:value-of select='@fullname'/>")]
        </xsl:if>
        <xsl:if test="$version=3">  public</xsl:if> class <xsl:choose>
          <xsl:when test='$version=3'>
            <xsl:value-of select="@name"/>
            <xsl:if test="@parentName">
              extends <xsl:value-of select="@parentNamespace"/>.vo.<xsl:value-of select="@parentName"/>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="//service/@namespace"/>.vo.<xsl:value-of select="@name"/>
          </xsl:otherwise>
        </xsl:choose>
        {
        public function <xsl:value-of select="@name"/>(){}

        <xsl:variable name="primaryKey" select="codegen:GetPrimaryKey(concat(../@fullname,'.',@name))"/>
        <xsl:if test="$primaryKey != ''">
          public var PrimaryKeyFieldsSet:String = "<xsl:value-of select="$primaryKey"/>";
        </xsl:if>

        <xsl:for-each select="const">
          public static const <xsl:value-of select="@name"/>:<xsl:choose>
            <xsl:when test="@typeNamespace">
              <xsl:value-of select="@typeNamespace"/>.vo.<xsl:value-of select="@type"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@fulltype"/>
            </xsl:otherwise>
          </xsl:choose> = <xsl:if test="@type='String'">"</xsl:if><xsl:value-of select="@value"/><xsl:if test="@type='String'">"</xsl:if>;
        </xsl:for-each>

        <xsl:for-each select="field">
          <xsl:variable name="argument" select="concat(../../@fullname,'.',../@name,'#',@name)"/>
          <xsl:variable name="isForbidden" select="codegen:IsForbiddenProperty(concat(../../@fullname,'.',../@name,'#',@name))"/>                    
          <xsl:if test="not($isForbidden)">
            public var <xsl:value-of select="@name"/>:<xsl:choose>
              <xsl:when test="@typeNamespace">
                <xsl:value-of select="@typeNamespace"/>.vo.<xsl:value-of select="@type"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@fulltype"/>
              </xsl:otherwise>
            </xsl:choose>;
         </xsl:if>
        </xsl:for-each>
        }
        <xsl:if test="$version=3">
          }
        </xsl:if>
      </file>    
  </xsl:template>

  <xsl:template name="codegen.service">
    <file name="{@name}.as">
        <xsl:call-template name="codegen.code" />
      </file>

    <file name="{@name}Model.as">
        <xsl:call-template name="codegen.model" />
      </file>

    <xsl:if test="count(//datatype) != 0">
        <file name="DataTypeInitializer.as">
          <xsl:call-template name="codegen.datatypelist">
            <xsl:with-param name="namespaceName" select="@namespace" />
          </xsl:call-template>  
        </file>
        <file name="EntityQuery.as">
package <xsl:value-of select="@namespace" />
{
	import mx.rpc.IResponder;
	 
	public class EntityQuery
	{
	  private var methodName:String;
	  public static var conditions:Object;
	  private var arguments:Array;
	  private var service:Object;
		 
	  public function EntityQuery( service:Object, methodName:String,  ... arguments )
	  {
	  	this.methodName = methodName;
	  	this.service = service;
	  	this.arguments = arguments;
	  	conditions = new Object();
	  }
	  	  
	  public function Where( query:String ):EntityQuery
	  {
	  	conditions["where"] = query;
	  	return this;
	  }	 
	  
	  public function OrderBy( query:String ):EntityQuery
	  {
	  	conditions["orderby"] = query;
	  	return this;
	  }	 
	  
	  public function Skip( amount:int ):EntityQuery
	  {
	  	conditions["skip"] = amount;
	  	return this;
	  }	 
	  	 
	  public function Take( amount:int ):EntityQuery
	  {
	  	conditions["take"] = amount;
	  	return this;
	  }	  	  
	  
	  public function Select( responder:IResponder = null ):void
      {            
      	this.arguments.push( responder );
        service[methodName].apply(service, this.arguments);
      }      
	}
}
        </file>

        <file name="ChangeSetEntry.as">
package <xsl:value-of select="@namespace" />
{
  [Bindable]
  [RemoteClass(alias="System.Windows.Ria.ChangeSetEntry")]
  public class ChangeSetEntry
  {
    public function ChangeSetEntry(){}
	public var Id:int;
    public var OriginalEntity:Object;
    public var Entity:Object;
    public var Operation:int;
    public var EntityActions:Array;
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
    <xsl:call-template name="codegen.description">
      <xsl:with-param name="file-name" select="concat(@name,'.as')" />
    </xsl:call-template>
    <xsl:call-template name="comment.service" />
    package <xsl:value-of select="@namespace" />
    {
    import mx.rpc.remoting.RemoteObject;
    import mx.controls.Alert;
    import mx.rpc.events.ResultEvent;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.AsyncToken;
    import mx.rpc.IResponder;
    import mx.collections.ArrayCollection;
    import flash.utils.getQualifiedClassName;
    import mx.utils.ObjectUtil;
    import mx.messaging.Channel;
    import mx.messaging.ChannelSet;
    import mx.messaging.channels.AMFChannel;

    <xsl:for-each select="//namespace">    
    <xsl:if test="datatype">
    import <xsl:value-of select="@fullname" />.vo.*;</xsl:if>
    </xsl:for-each>
        
    public class <xsl:value-of select="@name"/>
    {
      private var remoteObject:RemoteObject;
      private var model:<xsl:value-of select="@name"/>Model; 
      <xsl:for-each select="//datatype">        
        <xsl:if test="codegen:GetPrimaryKey(@fullname) != ''">
          public var <xsl:value-of select="@name"/><xsl:if test="substring(@name,1,string-length(@name)-1)='s'">e</xsl:if>s:Array=new Array();
        </xsl:if>
      </xsl:for-each>

      private var changes:Array = new Array();

      public function <xsl:value-of select="@name"/>( model:<xsl:value-of select="@name"/>Model = null )
      {
        remoteObject  = new RemoteObject( "GenericDestination" );
        <xsl:variable name="serviceName" select="@fullname"/>        
        remoteObject.source = "<xsl:value-of select='substring($serviceName,21)'/>";
        <xsl:for-each select="method">
          <xsl:variable name="methodType" select="codegen:GetMethodType(concat(../@namespace,'.',../@name,'#',@name))"/>
          <xsl:if test="$methodType=1 or $methodType=5 or $methodType=7">
        remoteObject.<xsl:value-of select="@name" />.addEventListener("result",<xsl:value-of select="@name" />Handler);</xsl:if></xsl:for-each>
        remoteObject.addEventListener("fault", onFault);
        
        if( model == null )
            model = new <xsl:value-of select="@name"/>Model();
    
        this.model = model;
      }

  	 public function setChannelParameters() : void
     {	 
    	 var url:String = "weborb.aspx"; 	
    	 	
    	 // insert query conditions if they were specified
    	 if ( EntityQuery.conditions != null )
    	 	 {
    	 	 url = "weborb.aspx?";
    	 	 url += "where=" + escape(EntityQuery.conditions[ "where" ]) + "&amp;";
    	 	 url += "orderby=" + escape(EntityQuery.conditions[ "orderby" ]) + "&amp;";
    	 	 url += "skip=" + EntityQuery.conditions["skip"] + "&amp;";
    	 	 url += "take=" + EntityQuery.conditions["take"] + "&amp;";
    	 	 url = url.slice( 0, -1 );
    		 EntityQuery.conditions = null;	 	
    	 	 }
    	 	
  	 	  var channelSet:ChannelSet = new ChannelSet();
  	    var channel:Channel = new AMFChannel( null, url );            
  	    channelSet.addChannel( channel );      
  	    remoteObject.channelSet = channelSet;
     }    
      
      public function setCredentials( userid:String, password:String ):void
      {
       remoteObject.setCredentials( userid, password );
      }

      public function GetModel():<xsl:value-of select="@name"/>Model
        {
        return this.model;
        }

    <xsl:for-each select="method">
      <xsl:variable name="methodType" select="codegen:GetMethodType(concat(../@namespace,'.',../@name,'#',@name))"/>
        <xsl:if test="$methodType!=7">
      <!--<xsl:variable name="enums" select="//enum"/>-->
      public function <xsl:value-of select="@name"/>(<xsl:for-each select="arg"><xsl:value-of select="@name"/>:<xsl:choose>
 <xsl:when test="count(//enum[@fullname=current()/@nativetype])>0">String</xsl:when><xsl:otherwise><xsl:value-of select="@type" /></xsl:otherwise>
</xsl:choose><xsl:if test="position()!=last() or $methodType=1 or $methodType=5">,</xsl:if></xsl:for-each> <xsl:if test="$methodType=1 or $methodType=5">responder:IResponder = null</xsl:if> ):void
      {
       <xsl:if test="$methodType=1">
       setChannelParameters();
       </xsl:if>
       <xsl:if test="$methodType=1 or $methodType=5">
        var asyncToken:AsyncToken = remoteObject.<xsl:value-of select="@name"/>(<xsl:for-each select="arg">
          <xsl:if test="position() != 1">,</xsl:if>
          <xsl:value-of select="@name"/>
        </xsl:for-each>);
        if( responder != null )
          asyncToken.addResponder( responder );</xsl:if>
       <xsl:if test="$methodType=2 or $methodType=3 or $methodType=4 or $methodType=6">
        var change:ChangeSetEntry = new ChangeSetEntry();
		change.Id = changes.length;
       </xsl:if>
       <xsl:if test="$methodType=2">
        // insert method             
        change.Entity = <xsl:value-of select="arg/@name"/>;
        change.Operation = 2;        
       </xsl:if>
       <xsl:if test="$methodType=3">
        // update method
        var primaryKey:String = GetPrimaryKey(<xsl:value-of select="arg/@name"/>);
        change.Entity = <xsl:value-of select="arg/@name"/>;
        change.OriginalEntity = GetEntityArray(<xsl:value-of select="arg/@name"/>)[primaryKey];
        if (change.OriginalEntity == null)
        {
          throw new Error("There is no entity with such primary key " + primaryKey);
        }
        change.Operation = 3;
       </xsl:if>
       <xsl:if test="$methodType=4">
        // delete method
        change.Entity = <xsl:value-of select="arg/@name"/>;
        change.Operation = 4;
       </xsl:if>
       <xsl:if test="$methodType=6">
        // named update method
        var primaryKey:String = GetPrimaryKey(<xsl:value-of select="arg/@name"/>);
        change.Entity = <xsl:value-of select="arg/@name"/>;
        change.OriginalEntity = GetEntityArray(<xsl:value-of select="arg/@name"/>)[primaryKey];
        change.Operation = 3;
        var actions:Array = new Array();
        actions["<xsl:value-of select="@name"/>"] = new Array(<xsl:for-each select="arg">
          <xsl:if test="position() != 1">
            <xsl:if test="position() != 2">,</xsl:if>
            <xsl:value-of select="@name"/>
          </xsl:if>
        </xsl:for-each>);
        change.EntityActions = actions;        
      </xsl:if>
      <xsl:if test="$methodType=2 or $methodType=3 or $methodType=4 or $methodType=6">
        changes.push( change );
      </xsl:if>
        }
        </xsl:if>
    </xsl:for-each>

      // this method is called for submiting all local changes of model to server
      public function SubmitChanges( responder:IResponder = null ):void
        {
        var asyncToken:AsyncToken = remoteObject.SubmitChanges(changes);
        changes = [];
        if( responder != null )
          asyncToken.addResponder( responder );
        }

    <xsl:for-each select="method">
      <xsl:variable name="methodType" select="codegen:GetMethodType(concat(../@namespace,'.',../@name,'#',@name))"/>
      <xsl:if test="$methodType = 1">
      <xsl:variable name="enums" select="//enum"/>
      public function From<xsl:value-of select="@name"/>(<xsl:for-each select="arg">
        <xsl:value-of select="@name"/>:<xsl:choose>
          <xsl:when test="count($enums[@fullname=current()/@nativetype])>0">String,</xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@type" /> <xsl:if test="position!=last()">,</xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>):EntityQuery
        {
          return new EntityQuery( this, "<xsl:value-of select="@name"/>"<xsl:for-each select="arg">,<xsl:value-of select="@name"/></xsl:for-each> );
        }
      </xsl:if>
    </xsl:for-each>


    <xsl:for-each select="method">
      <xsl:variable name="methodType" select="codegen:GetMethodType(concat(../@namespace,'.',../@name,'#',@name))"/>
      <xsl:if test="$methodType=1 or $methodType=5 or $methodType=7">
        public virtual function <xsl:value-of select="@name" />Handler(event:ResultEvent):void
        {  <xsl:if test="@type != 'void'">
          var returnValue:<xsl:value-of select="@type" /> = event.result as <xsl:value-of select="@type" />;
          model.<xsl:value-of select="@name" />Result = returnValue;
        </xsl:if>

        <xsl:if test="$methodType=1">
          ProcessQueryResult(returnValue);
        </xsl:if>       
        <xsl:if test="$methodType=5">
          // this is invoke method handler
        </xsl:if>
        <xsl:if test="$methodType=7">
          // go through request entries and check the responce
          for each(var changeEntry:ChangeSetEntry in event.token.message.body[0])
          {
            if (changeEntry.Operation == 4)
            { 
	             if (isEntityDeleted(changeEntry, event.result as Array)) 
	             {                     
		          	RemoveFromModel(changeEntry.Entity);
	             }
	             else
	             {
	             	var key:String = GetPrimaryKey(changeEntry.Entity);             
	             	throw new Error("Entity wasn't deleted due to a conflict. Primary key is " + key);
	             }	 
            }
  	        if (changeEntry.Operation == 3)
  	        {          	
  	        	AddToModel(changeEntry.Entity);
  	        }
          }

          // go through responce to search for new entities
          for each(var resultEntry:Object in returnValue)
          {
	          if (resultEntry.Operation == "Insert" || resultEntry.Operation == "Update")
	          {          	
	          	AddToModel(resultEntry.Entity);
	          }   	          	      
          }   
        </xsl:if>
        }
      </xsl:if>
    </xsl:for-each>

    private function isEntityDeleted(request:ChangeSetEntry, results:Array):Boolean 
    {
    	for each(var result:Object in results)
    	{
    		if ( GetPrimaryKey(request.Entity) == GetPrimaryKey(result.Entity) &amp;&amp; result.IsDeleteConflict)
    		  return false; 
    	}
    	return true;
    }
      

    public function GetPrimaryKey(entity:Object):String
    {
      var primaryKey:String="";
      for each(var fieldName:String in entity.PrimaryKeyFieldsSet.split(","))
      {
        if (primaryKey.length == 0) primaryKey = String(entity[fieldName]);
          else primaryKey += "," + String(entity[fieldName]);
      }
      return primaryKey;
    }

    public virtual function ProcessQueryResult(result:Object):void
    {
      for each(var entity:Object in result.RootResults)
      {
        AddToModel(entity);
      }
      for each(var dependentEntity:Object in result.IncludedResults)
      {
        AddToModel(dependentEntity);
      }
    }

    public virtual function AddToModel(entity:Object):void
    {
      var primaryKey:String = GetPrimaryKey(entity);
      GetEntityArray(entity)[primaryKey] = ObjectUtil.copy(entity);
    }

    public virtual function RemoveFromModel(entity:Object):void
    {
      var primaryKey:String = GetPrimaryKey(entity);
      delete GetEntityArray(entity)[primaryKey];
    }

    public function GetEntityArray(entity:Object):Array
    {
      var name:String = flash.utils.getQualifiedClassName(entity).split("::")[1];
      if (name.charAt(name.length-1)=="s")name+="es"; else name += "s";
      return this[name];
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

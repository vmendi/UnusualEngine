<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
    xmlns:codegen="urn:cogegen-xslt-lib:xslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="codegen.xslt"/>
  
	<xsl:variable name="up" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
	<xsl:variable name="lo" select="'abcdefghijklmnopqrstuvwxyz'"/>

  <xsl:template name="codegen.appmain">
    <file name="main.mxml">
&lt;mx:Application xmlns:mx="http://www.adobe.com/2006/mxml" layout="absolute" initialize="onLoad()"
xmlns:business = "<xsl:value-of select="//service/@namespace"/>.business.*" xmlns:control="<xsl:value-of select="//service/@namespace"/>.control.*">
&lt;mx:Script>
  &lt;![CDATA[
  import <xsl:value-of select="//service/@namespace"/>.DataTypeInitializer;
  public function onLoad():void
  {
    new DataTypeInitializer();
  }
  ]]&gt;
  &lt;/mx:Script>

&lt;control:<xsl:value-of select="//service/@name"/>Controller />
&lt;business:<xsl:value-of select="//service/@name"/>Services id="services" />

&lt;/mx:Application>
    </file>
  </xsl:template>

  <xsl:template name="codegen.service">
    <xsl:call-template name="codegen.datatypeinitializer"/>
      <folder name="business">
         <file name="{@name}Delegate.as">
          <xsl:call-template name="codegen.description">
            <xsl:with-param name="file-name" select="concat(@name,'Delegate.as')" />
          </xsl:call-template>
          <xsl:call-template name="delegate" />
         </file>
    		 <file name="{@name}Services.mxml" type="xml">
          &lt;!--
    		  <xsl:call-template name="codegen.description">
            <xsl:with-param name="file-name" select="concat(@name,'Services.mxml')" />
          </xsl:call-template>
          -->
          <xsl:call-template name="services" />
        </file>
      </folder>
      <folder name="command">
        <xsl:for-each select='method'>
      		<xsl:variable name="firstLetter" select="substring(@name, 1,1)"/>
      		<xsl:variable name="className" select = "concat(translate($firstLetter, $lo, $up), substring(@name, 2, string-length(@name)-1))"/>			
          <file name="{$className}Command.as">
            <xsl:call-template name="codegen.description">
              <xsl:with-param name="file-name" select="concat($className,'Command.as')" />
            </xsl:call-template>
            <xsl:call-template name="command" />
          </file>
        </xsl:for-each>
      </folder>
    <folder name="model">
      <file name="{@name}ModelLocator.as">
        <xsl:call-template name="codegen.description">
          <xsl:with-param name="file-name" select="concat(@name,'ModelLocator.as')" />
        </xsl:call-template>
        <xsl:call-template name="modelLocator" />
      </file>     
    </folder>
	  <folder name="event">
        <xsl:for-each select='method'>
    		<xsl:variable name="firstLetter" select="substring(@name, 1,1)"/>
    		<xsl:variable name="className" select = "concat(translate($firstLetter, $lo, $up), substring(@name, 2, string-length(@name)-1))"/>	
          <file name="{$className}Event.as">
            <xsl:call-template name="codegen.description">
              <xsl:with-param name="file-name" select="concat($className,'Event.as')" />
            </xsl:call-template>
            <xsl:call-template name="event" />
          </file>
		  </xsl:for-each>
      </folder>
	  <folder name="control">
          <file name="{@name}Controller.as">
            <xsl:call-template name="codegen.description">
              <xsl:with-param name="file-name" select="concat(@name,'Controller.as')" />
            </xsl:call-template>
            <xsl:call-template name="controller" />
          </file>
      </folder>   
  </xsl:template> 
  
  <xsl:template name="services">

  <cairngorm:ServiceLocator xmlns:mx="http://www.adobe.com/2006/mxml"  xmlns:cairngorm="http://www.adobe.com/2006/cairngorm">

      <mx:RemoteObject id="{@name}" destination="GenericDestination" source="{@fullname}"
  							showBusyCursor="true">
      </mx:RemoteObject>

  </cairngorm:ServiceLocator>

</xsl:template>

  <xsl:template name="codegen.vo">
    <xsl:param name="version" select="3" />
    <file name="{@name}.as">
      <xsl:call-template name="codegen.description">
        <xsl:with-param name="file-name" select="concat(@name,'.as')" />
      </xsl:call-template>
      <xsl:if test="$version=3">
        package <xsl:value-of select="../@fullname" />.vo
        {
        import com.adobe.cairngorm.vo.IValueObject;
        import flash.utils.ByteArray;
        import mx.collections.ArrayCollection;
        <xsl:call-template name="codegen.import.fieldtypes"/>

        [Bindable]
        [RemoteClass(alias="<xsl:value-of select='@fullname'/>")]
      </xsl:if>
      <xsl:if test='$version=3'>  public</xsl:if> class <xsl:choose>
        <xsl:when test='$version=3'>
          <xsl:value-of select="@name"/>
          <xsl:choose>
            <xsl:when test="@parentName">
              extends <xsl:value-of select="@parentNamespace"/>.vo.<xsl:value-of select="@parentName"/>
            </xsl:when>
            <xsl:otherwise> implements IValueObject</xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="//service/@namespace"/>.vo.<xsl:value-of select="@name"/>
        </xsl:otherwise>
      </xsl:choose>
      {
      public function <xsl:value-of select="@name"/>(){}

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
        public var <xsl:value-of select="@name"/>:<xsl:choose>
          <xsl:when test="@typeNamespace">
            <xsl:value-of select="@typeNamespace"/>.vo.<xsl:value-of select="@type"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@fulltype"/>
          </xsl:otherwise>
        </xsl:choose>;
      </xsl:for-each>
      }
      <xsl:if test="$version=3">
        }
      </xsl:if>
    </file>
  </xsl:template>
  
  <xsl:template name="delegate">
    package <xsl:value-of select="@namespace" />.business
    {
    import mx.rpc.IResponder;
    import com.adobe.cairngorm.business.ServiceLocator;
    import mx.rpc.events.ResultEvent;
    import mx.rpc.AbstractOperation;
    <xsl:call-template name="codegen.import.alltypes"/>

		public class <xsl:value-of select="@name"/>Delegate
		{
			private var responder : IResponder;
			private var service : Object;

			public function <xsl:value-of select="@name"/>Delegate(responder : IResponder )
			{
				this.service = ServiceLocator.getInstance().getRemoteObject( "<xsl:value-of select='@name'/>" );
				this.responder = responder;
			}
        
        <xsl:for-each select='method'>
        public function <xsl:value-of select='@name' />(<xsl:for-each select="arg">
          <xsl:if test="position() != 1">, </xsl:if>
          <xsl:value-of select="@name"/>:<xsl:value-of select="@type" />
        </xsl:for-each>) : void
         {

			var call : Object = service.<xsl:value-of select="@name"/>(<xsl:for-each select="arg">
          <xsl:if test="position() != 1">,</xsl:if>
          <xsl:value-of select="@name"/>
        </xsl:for-each>);
        
			call.addResponder( responder );	
        }
        </xsl:for-each>
      }
    }    
  </xsl:template>
 
  <xsl:template name="command">

	package <xsl:value-of select="../@namespace" />.command
    {
    import mx.rpc.IResponder;
    import com.adobe.cairngorm.commands.ICommand;
    import com.adobe.cairngorm.control.CairngormEvent;
    import mx.rpc.events.ResultEvent;
    import mx.rpc.events.FaultEvent;
    import mx.controls.Alert;
    import <xsl:value-of select="../@namespace" />.business.*;
    import <xsl:value-of select="../@namespace" />.event.*;
    import <xsl:value-of select="../@namespace" />.model.*;
    <xsl:call-template name="codegen.import.alltypes"/>

		<xsl:variable name="firstLetter" select="substring(@name, 1,1)"/>
		<xsl:variable name="className" select = "concat(translate($firstLetter, $lo, $up), substring(@name, 2, string-length(@name)-1))"/>
		
		public class <xsl:value-of select="$className"/>Command implements ICommand, IResponder
		{
			public function <xsl:value-of select="$className"/>Command()
			{	 
			}

			public function execute ( event : CairngormEvent) : void
			{
				var delegate : <xsl:value-of select="../@name"/>Delegate = new <xsl:value-of select="../@name"/>Delegate ( this );
				delegate.<xsl:value-of select="@name"/>( <xsl:for-each select='arg'> <xsl:if test="position() != 1">, </xsl:if> <xsl:value-of select="$className"/>Event(event).<xsl:value-of select="@name" /> </xsl:for-each>);
			}
		
			public function result( event : Object ) : void
			{
			<xsl:if test="@type != 'void'">
				var returnValue:<xsl:value-of select="@type" /> = event.result as <xsl:value-of select="@type" />;
            <xsl:value-of select="../@name"/>ModelLocator.getInstance().<xsl:value-of select="$className"/>Result = returnValue;
      </xsl:if>    
			}
		
			public function fault( event : Object ) : void
			{
				var faultEvent : FaultEvent = FaultEvent( event );
				Alert.show( faultEvent.fault.faultString);
			}
		}
	}
  </xsl:template>

  <xsl:template name="controller">
	package <xsl:value-of select="@namespace" />.control
	{
		import com.adobe.cairngorm.control.FrontController;	
		import <xsl:value-of select="@namespace" />.business.*;
		import <xsl:value-of select="@namespace" />.event.*;
    import <xsl:value-of select="@namespace" />.command.*;
    <xsl:call-template name="codegen.import.alltypes"/>

		public class <xsl:value-of select="@name"/>Controller extends FrontController
		{
			public function <xsl:value-of select="@name"/>Controller()
			{
				initializeCommands();
			}		
		
			public function initializeCommands() : void
			{
				<xsl:for-each select='method'>
				<xsl:variable name="firstLetter" select="substring(@name, 1,1)"/>
				<xsl:variable name="className" select = "concat(translate($firstLetter, $lo, $up), substring(@name, 2, string-length(@name)-1))"/>
		
				addCommand( <xsl:value-of select="$className"/>Event.GET_MESSAGE_<xsl:value-of select="@name"/>, <xsl:value-of select="$className"/>Command );
				</xsl:for-each>
			}
		}
	}
   </xsl:template>

  <xsl:template name="modelLocator">
  package <xsl:value-of select="@namespace" />.model
  {
    import mx.collections.ArrayCollection;
    import com.adobe.cairngorm.model.IModelLocator;
    <xsl:call-template name="codegen.import.alltypes"/>

    [Bindable]
    public class <xsl:value-of select="@name"/>ModelLocator implements IModelLocator
    {
      static private var __instance:<xsl:value-of select="@name"/>ModelLocator=null;
    <xsl:for-each select='method[@type!="void"]'>
      <xsl:variable name="firstLetter" select="substring(@name, 1,1)"/>
      <xsl:variable name="methodName" select = "concat(translate($firstLetter, $lo, $up), substring(@name, 2, string-length(@name)-1))"/>
      public var <xsl:value-of select="$methodName"/>Result:<xsl:value-of select="@type"/>;
    </xsl:for-each>

      public static function getInstance():<xsl:value-of select="@name"/>ModelLocator
      {
        if(__instance == null)
        {
        __instance=new <xsl:value-of select="@name"/>ModelLocator();
        }
        return __instance;
      }
    }
  }
  </xsl:template>

  <xsl:template name="event">   
	package <xsl:value-of select="../@namespace" />.event
    {
    import flash.events.Event;
    import com.adobe.cairngorm.control.CairngormEvent;

    <xsl:call-template name="codegen.import.alltypes"/>
		
		<xsl:variable name="firstLetter" select="substring(@name, 1,1)"/>
		<xsl:variable name="className" select = "concat(translate($firstLetter, $lo, $up), substring(@name, 2, string-length(@name)-1))"/>

		public class <xsl:value-of select="$className"/>Event extends CairngormEvent
		{
			public static var GET_MESSAGE_<xsl:value-of select="@name"/>:String = "getMessage_<xsl:value-of select="@name"/>";

			public function <xsl:value-of select="$className"/>Event( type:String, <xsl:for-each select='arg'> <xsl:value-of select="@name" />:<xsl:value-of select="@type" />, </xsl:for-each> bubbles:Boolean=false, cancelable:Boolean=false)
			{
				super( type, bubbles, cancelable );
			<xsl:for-each select='arg'>
			_<xsl:value-of select="@name" /> = <xsl:value-of select="@name" />;
			</xsl:for-each>
			}
			<xsl:for-each select='arg'>
			private var	_<xsl:value-of select="@name" />:<xsl:value-of select="@type" />;
			</xsl:for-each>
			
			<xsl:for-each select='arg'>
			public function get <xsl:value-of select="@name" />():<xsl:value-of select="@type" />
			{
				return _<xsl:value-of select="@name" />;
			}
			</xsl:for-each>

			override public function clone() : Event
			{
				return new <xsl:value-of select="$className"/>Event(type, <xsl:for-each select='arg'> <xsl:value-of select="@name" />, </xsl:for-each> bubbles, cancelable);
			}	
		}
	}
  </xsl:template> 

</xsl:stylesheet>

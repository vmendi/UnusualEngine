<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
    xmlns:codegen="urn:cogegen-xslt-lib:xslt"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="codegen.xslt"/>
  <xsl:import href="codegen.invoke.xslt"/>

  <xsl:template name="codegen.process.fullproject">
    <xsl:for-each select="/namespaces">
      <xsl:call-template name="codegen.process.namespace" />
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="codegen.service">
      <file name="{@name}.as">
        <xsl:call-template name="codegen.description">
          <xsl:with-param name="file-name" select="concat(@name,'.as')" />
        </xsl:call-template>
        <xsl:call-template name="codegen.code" />
      </file>  
  </xsl:template>	  

<xsl:template name="codegen.code">
  
package <xsl:value-of select="@namespace" />
{
	import flash.net.NetConnection;
    import flash.net.Responder;
	import <xsl:value-of select="@namespace" />.vo.*;
  <xsl:call-template name="codegen.import.alltypes"/>
	
	
	public class <xsl:value-of select="@name" /> 
	{		
		// Constants:
		private const weborbUrl:String = "<xsl:value-of select='@url'/>";
		private const destination:String = "<xsl:value-of select="@fullname" />";

		// Private Properties:
		private var gateway:NetConnection;
	
		// Initialization:
		public function <xsl:value-of select="@name" /> () 
		{ 
			gateway = new NetConnection();
            gateway.connect(weborbUrl);
		} 
		
		// Public Methods:
		
		<xsl:for-each select="method">
      public function <xsl:value-of select="@name"/>(<xsl:for-each select="arg">
        <xsl:if test="position() != 1">,</xsl:if>
        <xsl:value-of select="@name"/>:<xsl:value-of select="@type" />
      </xsl:for-each>)
		{
			gateway.call(destination + ".<xsl:value-of select="@name"/>", new Responder(<xsl:value-of select="@name"/>Handler, OnErrorHandler) <xsl:for-each select="arg">, <xsl:value-of select="@name"/></xsl:for-each>);
		}
		  
		private function <xsl:value-of select="@name"/>Handler(result:Object):void
		{
            <xsl:if test="@type!='void'">
            var returnValue:<xsl:value-of select="@type"/>  = result as <xsl:value-of select="@type"/>;
            trace( "received result - " + returnValue );
        </xsl:if>
		}
		
		</xsl:for-each>
	    
		private function OnErrorHandler(error:Object):void
		{
			trace( error );
		}
	}
}
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
            import flash.utils.ByteArray;
            <xsl:call-template name="codegen.import.fieldtypes"/>

            [Bindable]
            [RemoteClass(alias="<xsl:value-of select='@fullname'/>")]
        </xsl:if>
        <xsl:if test='$version=3'>  public</xsl:if> class <xsl:choose>
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

        public <xsl:if test="not(@parentName)">virtual</xsl:if> <xsl:if test="@parentName">override</xsl:if> function toString():String
        {
        return <xsl:for-each select="field">this.<xsl:value-of select="@name"/><xsl:if test="position() != last()"> + ": " + 
        </xsl:if>
        </xsl:for-each>;
        }
        }
        <xsl:if test="$version=3">
            }
        </xsl:if>
    </file>
</xsl:template>

</xsl:stylesheet>

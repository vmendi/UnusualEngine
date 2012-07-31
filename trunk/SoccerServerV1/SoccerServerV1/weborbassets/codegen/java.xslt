<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:codegen="urn:cogegen-xslt-lib:xslt"
    xmlns:fn="http://www.w3.org/2005/xpath-functions">

  <xsl:import href="codegen.xslt"/>
  <xsl:import href="codegen.invoke.xslt"/>

  <xsl:template name="comment.service">
    /***********************************************************************
    The generated code provides a simple mechanism for invoking methods
    from the <xsl:value-of select="@fullname" /> class using WebORB for Java
    client API.
    The generated files can be added to library project. You can compile 
    the library and use it from other Java component projects.
    ************************************************************************/
  </xsl:template>

  <xsl:template name="codegen.process.fullproject">
    <xsl:param name="file-name" select="codegen:getServiceName()"/>
    <folder name="src">
      <xsl:for-each select="/namespaces">
        <xsl:call-template name="codegen.process.namespace" />
      </xsl:for-each>
    </folder>

    <xsl:call-template name="codegen.project.file" />
        
  </xsl:template>


  <xsl:template name="codegen.project.file">
    <file name=".classpath" type="xml">      
      <classpath>
        <classpathentry kind="src" path="src"/>
        <classpathentry kind="con" path="org.eclipse.jdt.launching.JRE_CONTAINER"/>
        <classpathentry kind="output" path="bin"/>
      </classpath>
    </file>
    <file name=".project" type="xml">      
      <projectDescription>
        <name>netInvocation</name>
        <comment></comment>
        <projects>
        </projects>
        <buildSpec>
          <buildCommand>
            <name>org.eclipse.jdt.core.javabuilder</name>
            <arguments>
            </arguments>
          </buildCommand>
        </buildSpec>
        <natures>
          <nature>org.eclipse.jdt.core.javanature</nature>
        </natures>
      </projectDescription>
    </file>
  </xsl:template>

  <xsl:template name="codegen.service">
      <file name="{@name}Service.java">
        <xsl:call-template name="codegen.code" />
      </file>
      <!-- <file name="{@name}Model.java">
        <xsl:call-template name="codegen.model" />
      </file> -->
  </xsl:template>

  <xsl:template name="codegen.vo.folder">
    <xsl:param name="version" select="3" />
    <xsl:if test="count(datatype) != 0">
      <xsl:for-each select="datatype">
        <xsl:call-template name="codegen.java.vo">
          <xsl:with-param name="version" select="$version" />
        </xsl:call-template>
      </xsl:for-each>
      <xsl:for-each select="enum">
        <xsl:call-template name="codegen.java.enum">
            <xsl:with-param name="version" select="$version" />
        </xsl:call-template>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template name="codegen.java.enum">
      <file name="{@name}.java">
          <xsl:call-template name="codegen.description">
              <xsl:with-param name="file-name" select="concat(@name,'.java')" />
          </xsl:call-template>
package <xsl:value-of select="@typeNamespace" />;

public enum <xsl:value-of select="@name"/> 
{
    <xsl:for-each select="field">
      <xsl:value-of select="@name"/><xsl:if test="position() != last()">,</xsl:if>
    </xsl:for-each>
}          
      </file>
  </xsl:template>

  <xsl:template name="codegen.java.vo">
    <file name="{@name}.java">
      <xsl:call-template name="codegen.description">
        <xsl:with-param name="file-name" select="concat(@name,'.java')" />
      </xsl:call-template>
package <xsl:value-of select="@typeNamespace" />;
       
import java.util.*;

public class <xsl:value-of select="@name"/> <xsl:if test="@parentName"> : <xsl:value-of select="@parentNamespace"/>.<xsl:value-of select="@parentName"/></xsl:if>
{
<xsl:for-each select="const">
  public const <xsl:value-of select="codegen:mapToJavaType(@nativetype)" /><xsl:text> </xsl:text><xsl:value-of select="@name"/> = <xsl:if test="@type='String'">"</xsl:if><xsl:value-of select="@value"/><xsl:if test="@type='String'">"</xsl:if>;
</xsl:for-each>
<xsl:for-each select="field">
  public <xsl:value-of select="codegen:mapToJavaType(@nativetype)" /><xsl:text> </xsl:text><xsl:value-of select="@name"/>;
</xsl:for-each>
}      
    </file>
  </xsl:template>  
  
  <xsl:template name="codegen.invoke.method.name">
    m_service.<xsl:value-of select="@name"/>
  </xsl:template>
  
  <xsl:template name="codegen.code">
    <xsl:call-template name="codegen.description">
      <xsl:with-param name="file-name" select="concat(concat(@name,'Service'),'.java')" />
    </xsl:call-template>
    <xsl:call-template name="comment.service" />
package <xsl:value-of select="@namespace" />;

import weborb.client.WeborbClient;
import weborb.client.IResponder;
import weborb.client.Fault;
import java.util.*;
<xsl:for-each select="//namespace/datatype">
import <xsl:value-of select="@fullname" />;
</xsl:for-each>



public class <xsl:value-of select="@name"/>Service
{
  private WeborbClient weborbClient;      
  <!-- 
  private <xsl:value-of select="@name"/>Model model;  

  public <xsl:value-of select="@name"/>Service() 
  {
    this( new <xsl:value-of select="@name"/>Model() );
  } 
  -->
  
  public <xsl:value-of select="@name"/>Service( <!--<xsl:value-of select="@name"/>Model model --> )
  {
    <!-- this.model = model; -->
    weborbClient = new WeborbClient("<xsl:value-of select="/namespaces/runtime/@weborbRootURL"/>/weborb.aspx", "GenericDestination");        
  }

  <!--public <xsl:value-of select="@name"/>Model GetModel()
  {
    return this.model;
  } -->
<xsl:for-each select="method">
  public void <xsl:value-of select="@name"/>( <xsl:for-each select="arg">
    <xsl:value-of select="codegen:mapToJavaType(@nativetype)" /><xsl:text> </xsl:text><xsl:value-of select="@name"/><xsl:if test="position() != last()">,</xsl:if><xsl:text> </xsl:text></xsl:for-each>) throws Exception
  {
    <xsl:value-of select="@name"/>( <xsl:for-each select="arg"><xsl:value-of select="@name"/>,<xsl:text> </xsl:text></xsl:for-each>null );
  }
  public void <xsl:value-of select="@name"/>( <xsl:for-each select="arg"><xsl:value-of select="codegen:mapToJavaType(@nativetype)" /><xsl:text> </xsl:text><xsl:value-of select="@name"/>,<xsl:text> </xsl:text></xsl:for-each> final IResponder responder ) throws Exception
  {
      Object[] arguments = new Object[]{<xsl:for-each select="arg"><xsl:if test="position() != 1">,</xsl:if><xsl:value-of select="@name"/></xsl:for-each>};
      weborbClient.invoke("<xsl:value-of select="parent::service/@fullname"/>", "<xsl:value-of select="@name"/>", arguments,
        new IResponder()
        {
          public void errorHandler(Fault fault) 
          {                            
            if (responder != null) 
              responder.errorHandler(fault);
          }

          public void responseHandler(Object res) 
          { 
            <xsl:if test="@type = 'void'">
              Object resAdapted = null;
            </xsl:if>
            
            <xsl:if test="@type != 'void'">
              <xsl:variable name="resultType" select="codegen:mapToJavaType(@nativetype)" />

              <xsl:if test="@type = 'Array' and not(starts-with($resultType,'HashMap'))">
                <xsl:variable name="elementType" select="substring($resultType, 1, string-length($resultType)-2)" />
             <xsl:value-of select="$elementType" />[] resAdapted = new <xsl:value-of select="$elementType" />[ ( (Object[])res ).length ];
             for ( int i = 0; i &lt; ( (Object[])res ).length; i++ )
               resAdapted[ i ] = (<xsl:value-of select="$elementType" />) ( (Object[])res )[ i ];
              </xsl:if>

              <xsl:if test="@type = 'Array' and starts-with($resultType,'HashMap')">
             HashMap resAdapted = (HashMap)( (Object[])res )[0];
              </xsl:if>

              <xsl:if test="@type != 'Array'">
              <xsl:value-of select="$resultType" /> resAdapted = (<xsl:value-of select="$resultType" />)( (Object[])res )[0];
              </xsl:if>

            </xsl:if>

            if (responder != null) 
              responder.responseHandler(resAdapted);   
          }
        });
  }
</xsl:for-each>        
}   
  </xsl:template>
  
  <!--
  <xsl:template name="codegen.model">
    <xsl:call-template name="codegen.description">
      <xsl:with-param name="file-name" select="concat(@name,'Model.java')" />
    </xsl:call-template>

package <xsl:value-of select="@namespace" />;

import java.util.*;

public class <xsl:value-of select="@name"/>Model
{<xsl:for-each select="method"><xsl:if test="@type != 'void'">     
  public <xsl:value-of select="codegen:mapToJavaType(@nativetype)" /><xsl:text> </xsl:text><xsl:value-of select="@name" />Result;</xsl:if></xsl:for-each>
}   
  </xsl:template> 
  -->
  
  <xsl:template name="codegen.instructions">
  <xsl:param name="file-name" select="codegen:getServiceName()"/>
    <file name="{$file-name}-instructions.txt" overwrite="false">
      The generated code enables remoting operations between a Java client and the 
      selected service (<xsl:value-of select="$file-name"/>).      

      Please don't forget to add the following dependencies into the java project:
      * commons-codec-1.3.jar
      * commons-httpclient-3.1.jar
      * commons-logging-1.1.jar
      * jdom-1.1.jar
      * weborb.jar
    </file>
  </xsl:template>  
</xsl:stylesheet>

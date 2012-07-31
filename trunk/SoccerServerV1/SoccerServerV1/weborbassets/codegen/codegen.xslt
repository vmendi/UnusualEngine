<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
xmlns:codegen="urn:cogegen-xslt-lib:xslt"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="codegen.project.eclipse.flex.xslt" />

<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />  

<xsl:template name="codegen.code" />  
<xsl:template name="codegen.info" />
<xsl:template name="codegen.instructions" />
<xsl:template name="codegen.file.comment" />
<xsl:template name="codegen.projectspecific" />

<xsl:template name="codegen.appmain">
<file name="main.mxml">
&lt;mx:Application xmlns:mx="http://www.adobe.com/2006/mxml" layout="absolute" initialize="onLoad()">
&lt;mx:Script>
&lt;![CDATA[
<xsl:if test="count(//datatype) != 0">
import <xsl:value-of select="//service/@namespace"/>.DataTypeInitializer;
</xsl:if>
public function onLoad():void
{
	<xsl:if test="count(//datatype) != 0">new DataTypeInitializer();</xsl:if>
}
]]&gt;
&lt;/mx:Script>
&lt;/mx:Application>
</file>
</xsl:template>

  <xsl:template match="/">
<folder name="weborb-codegen">
  <info>
	<xsl:call-template name="codegen.info" />
  </info>
  <xsl:call-template name="codegen.instructions" />

  <xsl:if test="not(codegen:getFullCode())">
	<xsl:call-template name="codegen.process.sourcesonly"/>
  </xsl:if>

  <xsl:if test="codegen:getFullCode()">
	  <xsl:call-template name="codegen.process.fullproject"/>
  </xsl:if>
</folder>
</xsl:template>

<xsl:template name="codegen.process.sourcesonly">
<xsl:call-template name="codegen.projectspecific" />
<xsl:for-each select="/namespaces">
  <xsl:call-template name="codegen.process.namespace" />
</xsl:for-each>
</xsl:template>


<xsl:template name="codegen.project.eclipse.flex.actionscript.properties.applications">
  <application path="main.mxml" />
</xsl:template>

<xsl:template name="codegen.project.eclipse.flex.actionscript.properties.mainApplicationPath">main.mxml</xsl:template>

<xsl:template name="codegen.project.eclipse.flex.name">
  <xsl:value-of select="//service/@name" />
</xsl:template>



  <xsl:template name="codegen.process.fullproject">
  <folder name="src">
    <xsl:call-template name="codegen.projectspecific" />
	  <xsl:for-each select="/namespaces">
		  <xsl:call-template name="codegen.process.namespace" />
	  </xsl:for-each>
	  <xsl:call-template name="codegen.appmain"/>
  </folder>

    <xsl:call-template name="codegen.project.eclipse.flex" />
    <xsl:call-template name="codegen.project.eclipse.flex.properties" />
    <xsl:call-template name="codegen.project.eclipse.flex.actionscript.properties" />
    <xsl:call-template name="codegen.project.eclipse.flex.htmltemplate" />

  </xsl:template>

<xsl:template name="codegen.process.namespace">
<xsl:for-each select="namespace">
  <folder name="{@name}">       
	<xsl:call-template name="codegen.process.namespace" />
	<xsl:for-each select="service">
	  <xsl:call-template name="codegen.service" />
	</xsl:for-each>
	<xsl:call-template name="codegen.vo.folder" />
  </folder>
</xsl:for-each>
</xsl:template>

<xsl:template name ="codegen.datatypeinitializer">
<xsl:if test="count(//datatype) != 0">
<file name="DataTypeInitializer.as">
<xsl:call-template name="codegen.datatypelist">
<xsl:with-param name="namespaceName" select="@namespace" />
</xsl:call-template>
</file>
</xsl:if>
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
	import mx.collections.ArrayCollection;
<xsl:call-template name="codegen.import.fieldtypes"/>        
	[Bindable]
	[RemoteClass(alias="<xsl:value-of select='@fullname'/>")]
</xsl:if>
<xsl:if test='$version=3'>	public</xsl:if> class <xsl:choose>
  <xsl:when test='$version=3'>
	<xsl:value-of select="@name"/> <xsl:if test="@parentName"> extends <xsl:value-of select="@parentNamespace"/>.vo.<xsl:value-of select="@parentName"/></xsl:if>
  </xsl:when>
  <xsl:otherwise>
	<xsl:value-of select="//service/@namespace"/>.vo.<xsl:value-of select="@name"/>
  </xsl:otherwise></xsl:choose>
	{
		public function <xsl:value-of select="@name"/>(){}
	<xsl:for-each select="const">
		public static const <xsl:value-of select="@name"/>:<xsl:choose><xsl:when test="@typeNamespace"><xsl:value-of select="@typeNamespace"/>.vo.<xsl:value-of select="@type"/></xsl:when><xsl:otherwise><xsl:value-of select="@fulltype"/></xsl:otherwise></xsl:choose> = <xsl:if test="@type='String'">"</xsl:if><xsl:value-of select="@value"/><xsl:if test="@type='String'">"</xsl:if>;</xsl:for-each>
	<xsl:for-each select="field">
		public var <xsl:value-of select="@name"/>:<xsl:choose><xsl:when test="@typeNamespace"><xsl:value-of select="@typeNamespace"/>.vo.<xsl:value-of select="@type"/></xsl:when><xsl:otherwise><xsl:value-of select="@fulltype"/></xsl:otherwise></xsl:choose>;</xsl:for-each>
	}<xsl:if test="$version=3">
}
</xsl:if>
</file>
</xsl:template>

<xsl:template name="codegen.enum">
<xsl:param name="version" select="3" />

<file name="{@name}.as">
<xsl:call-template name="codegen.description">
<xsl:with-param name="file-name" select="concat(@name,'.as')" />
</xsl:call-template>
<xsl:if test="$version=3">
package <xsl:value-of select="../@fullname" />.enum
{
</xsl:if>
<xsl:if test='$version=3'>  public</xsl:if> class <xsl:choose>
	  <xsl:when test='$version=3'>
		<xsl:value-of select="@name"/> <xsl:if test="@parentName"> extends <xsl:value-of select="@parentNamespace"/>.vo.<xsl:value-of select="@parentName"/></xsl:if>
	  </xsl:when>
	  <xsl:otherwise>
		<xsl:value-of select="//service/@namespace"/>.vo.<xsl:value-of select="@name"/>
	  </xsl:otherwise></xsl:choose>
	{
		public function <xsl:value-of select="@name"/>(){}
	<xsl:for-each select="field">
		public static var <xsl:value-of select="@name"/>:String="<xsl:value-of select="@name"/>";</xsl:for-each>
	}<xsl:if test="$version=3">
}
</xsl:if>
</file>
</xsl:template>  

<xsl:template name="codegen.vo.folder">
<xsl:param name="version" select="3" />

<xsl:if test="count(datatype) != 0">
  <folder name="vo">
	<xsl:for-each select="datatype">
	  <xsl:call-template name="codegen.vo">
		<xsl:with-param name="version" select="$version" />
	  </xsl:call-template>
	</xsl:for-each>
  </folder>
</xsl:if>
<xsl:if test="count(enum) != 0">
  <folder name="enum">
	<xsl:for-each select="enum">
	  <xsl:call-template name="codegen.enum">
		<xsl:with-param name="version" select="$version" />
	  </xsl:call-template>
	</xsl:for-each>        
  </folder>
</xsl:if>
</xsl:template>

<xsl:template name="codegen.service">
<xsl:call-template name="codegen.vo.folder" />

<file name="{concat(@name,'.as')}">
  <xsl:call-template name="codegen.description">
	<xsl:with-param name="file-name" select="concat(@name,'.as')" />
  </xsl:call-template>
  <xsl:call-template name="codegen.code" />         
</file>
</xsl:template>

<xsl:template name="codegen.datatypelist">
<xsl:param name="subnamespace" select="string('.vo.')" />
<xsl:param name="namespaceName" />/*****************************************************************
*
*  To force the compiler to include all the generated complex types
*  into the compiled application, add the following line of code 
*  into the main function of your Flex application:
*
*  new <xsl:value-of select="$namespaceName" />.DataTypeInitializer();
*
******************************************************************/

package <xsl:value-of select="$namespaceName" />
{<xsl:for-each select="//datatype">
	import <xsl:value-of select="../@fullname" /><xsl:value-of select="$subnamespace"/><xsl:value-of select="@name"/>;</xsl:for-each>
	
	public class DataTypeInitializer
	{
		public function DataTypeInitializer()
		{
		<xsl:for-each select="//datatype">	new <xsl:value-of select="../@fullname" /><xsl:value-of select="$subnamespace"/><xsl:value-of select="@name"/>();	
		</xsl:for-each>}
	}  
}  
</xsl:template>

<xsl:template name="codegen.import.alltypes">
<xsl:param name="excludeNamespace" select="''" />
<xsl:for-each select="//namespace/datatype[@typeNamespace!=$excludeNamespace]">
	import <xsl:value-of select="@typeNamespace" />.vo.<xsl:value-of select="@name"/>;</xsl:for-each>
<xsl:for-each select="//namespace/enum[@typeNamespace!=$excludeNamespace]">
	import <xsl:value-of select="@typeNamespace" />.enum.<xsl:value-of select="@name"/>;</xsl:for-each>    
</xsl:template>

<xsl:template name="codegen.import.fieldtypes">
<xsl:for-each select="field">
  <xsl:if test="@typeNamespace">import <xsl:value-of select="@typeNamespace" />.vo.<xsl:value-of select="@type"/>;</xsl:if>
</xsl:for-each>
</xsl:template>

<xsl:template name="codegen.description">
<xsl:param name="file-name" />/*******************************************************************
* <xsl:value-of select="$file-name" />
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
<xsl:call-template name="codegen.file.comment" />
</xsl:template>
</xsl:stylesheet> 

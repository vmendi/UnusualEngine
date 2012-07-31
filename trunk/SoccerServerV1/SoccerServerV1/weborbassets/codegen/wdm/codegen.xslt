<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" 
  xmlns:codegen="urn:cogegen-xslt-lib:xslt"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:import href="server/codegen.server.xslt"/>
  <xsl:import href="client/codegen.client.xslt"/>
  <xsl:import href="../codegen.project.eclipse.flex.xslt" />

  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
  
    <xsl:template match="/">
    <folder name="weborb-codegen">
      <folder name="server">
        <xsl:call-template name="codegen.server" />
      </folder>
      <folder name="client">
        <folder name="src">
          <xsl:call-template name="codegen.client" />
        </folder>
        <xsl:call-template name="codegen.project.eclipse.flex" />
        <xsl:call-template name="codegen.project.eclipse.flex.properties" />
        <xsl:call-template name="codegen.project.eclipse.flex.actionscript.properties" />
      </folder>
    </folder>
  </xsl:template>

  <xsl:template name="codegen.project.eclipse.flex.name">
    <xsl:value-of select="/xs:schema/xs:element/@name" />
  </xsl:template>

  <xsl:template name="codegen.project.eclipse.flex.actionscript.properties.mainApplicationPath">
    <xsl:choose>
      <xsl:when test="codegen:IsGenerateTestDrive()">testdrive.mxml</xsl:when>
      <xsl:when test="codegen:IsGenerateUnitTests()">UnitTests.mxml</xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="codegen.project.eclipse.flex.actionscript.properties.applications">
    <xsl:if test="codegen:IsGenerateUnitTests()">
      <application path="UnitTests.mxml" />
    </xsl:if>

    <xsl:if test="codegen:IsGenerateTestDrive()">
      <application path="testdrive.mxml" />
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
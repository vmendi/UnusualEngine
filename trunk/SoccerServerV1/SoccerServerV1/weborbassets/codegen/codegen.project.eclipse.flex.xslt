<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:codegen="urn:cogegen-xslt-lib:xslt"	 xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />

	<xsl:template name="codegen.project.eclipse.flex.actionscript.properties.applications" />
	<xsl:template name="codegen.project.eclipse.flex.actionscript.properties.mainApplicationPath" />
	<xsl:template name="codegen.project.eclipse.flex.name" />

	<xsl:template name="codegen.project.eclipse.flex">		
    <file name=".project" type="xml">
			<projectDescription>
				<name>
					<xsl:call-template name="codegen.project.eclipse.flex.name" />
				</name>
				<comment></comment>
				<projects>
				</projects>
				<buildSpec>
					<buildCommand>
						<name>com.adobe.flexbuilder.project.flexbuilder</name>
						<arguments>
						</arguments>
					</buildCommand>
				</buildSpec>
				<natures>
					<nature>com.adobe.flexbuilder.project.flexnature</nature>
					<nature>com.adobe.flexbuilder.project.actionscriptnature</nature>
				</natures>
				<linkedResources>
					<link>
						<name>bin-debug</name>
						<type>2</type>
						<location>
							<xsl:value-of select="//runtime/@path" />
							<xsl:call-template name="codegen.project.eclipse.flex.name" />
						</location>
					</link>
				</linkedResources>
			</projectDescription>
		</file>
	</xsl:template>

	<xsl:template name="codegen.project.eclipse.flex.properties">
		<file name=".flexProperties" type="xml">
			<flexProperties flexServerType="32" 
			   aspUseIIS="true" serverContextRoot="" serverRoot="{//runtime/@path}"    
			   serverRootURL="{//runtime/@weborbRootURL}" toolCompile="true" useServerFlexSDK="false" version="1">
			</flexProperties>
		</file>
	</xsl:template>

  <xsl:template name="codegen.project.eclipse.flex.htmltemplate">
    <folder name="html-template">
      <file name="index.template.html">
        <xsl:value-of select="codegen:getFile('weborbassets\codegen\html-template\index.template.html')"/>
      </file>
      <file name="playerProductInstall.swf">
        <xsl:value-of select="codegen:getFile('weborbassets\codegen\html-template\playerProductInstall.swf')"/>
      </file>
      <file name="AC_OETags.js">
        <xsl:value-of select="codegen:getFile('weborbassets\codegen\html-template\AC_OETags.js')"/>
      </file>
      <folder name="history">
        <file name="historyFrame.html">
          <xsl:value-of select="codegen:getFile('weborbassets\codegen\html-template\history\historyFrame.html')"/>
        </file>
        <file name="history.js">
          <xsl:value-of select="codegen:getFile('weborbassets\codegen\html-template\history\history.js')"/>
        </file>
        <file name="history.css">
          <xsl:value-of select="codegen:getFile('weborbassets\codegen\html-template\history\history.css')"/>
        </file>
      </folder>
    </folder>
  </xsl:template>
  
	<xsl:template name="codegen.project.eclipse.flex.actionscript.properties">
		<file name=".actionScriptProperties" type="xml">
			<actionScriptProperties version="3">
				<xsl:attribute name="mainApplicationPath"><xsl:call-template name="codegen.project.eclipse.flex.actionscript.properties.mainApplicationPath" /></xsl:attribute>

		<xsl:variable name="services_config">
			<xsl:choose>
				 <xsl:when test ="//runtime/@supportMessaging = 'true'">weborb-services-config.xml</xsl:when>				 
				 <xsl:otherwise>services-config.xml</xsl:otherwise>
			</xsl:choose>
	    </xsl:variable>			

		<xsl:variable name="service_folder">
			<xsl:choose>
				 <xsl:when test ="//runtime/@supportMessaging = 'true'"></xsl:when>				 
				 <xsl:otherwise>/<xsl:call-template name="codegen.project.eclipse.flex.name" /></xsl:otherwise>
			</xsl:choose>
	    </xsl:variable>	

		<xsl:variable name="htmlGenerate">
			<xsl:choose>
				 <xsl:when test ="//runtime/@supportMessaging = 'true'">false</xsl:when>				 
				 <xsl:otherwise>true</xsl:otherwise>
			</xsl:choose>
	    </xsl:variable>			

        <compiler	additionalCompilerArguments="-services &quot;{//runtime/@path}WEB-INF/flex/{$services_config}&quot; -locale en_US"
					copyDependentFiles="true" genableModuleDebug="false" generateAccessible="false" 
          htmlExpressInstall="true" htmlGenerate="{$htmlGenerate}"
					htmlHistoryManagement="false" htmlPlayerVersion="9.0.0"
					htmlPlayerVersionCheck="true"
					outputFolderPath="bin-debug"
					sourceFolderPath="src" strict="true" useApolloConfig="false"
					verifyDigests="true" warn="true">
					<xsl:attribute name="outputFolderLocation"><xsl:value-of select="//runtime/@path" /><xsl:call-template name="codegen.project.eclipse.flex.name" /></xsl:attribute>
					<!-- <xsl:attribute name="rootURL"><xsl:value-of select="//runtime/@weborbRootURL" /><xsl:value-of select="$service_folder" /></xsl:attribute>-->

					<compilerSourcePath />
					<libraryPath defaultLinkType="1">
						<libraryPathEntry kind="4" path="">
							<modifiedEntries>
								<libraryPathEntry kind="3" linkType="1"
									path="${PROJECT_FRAMEWORKS}/libs/framework.swc" sourcepath="${PROJECT_FRAMEWORKS}/source"
									useDefaultLinkType="true" />
							</modifiedEntries>
							<excludedEntries>
								<libraryPathEntry kind="3" linkType="1"
									path="${PROJECT_FRAMEWORKS}/libs/qtp.swc" useDefaultLinkType="false" />
								<libraryPathEntry kind="3" linkType="1"
									path="${PROJECT_FRAMEWORKS}/libs/automation.swc"
									useDefaultLinkType="false" />
								<libraryPathEntry kind="3" linkType="1"
									path="${PROJECT_FRAMEWORKS}/libs/automation_dmv.swc"
									useDefaultLinkType="false" />
								<libraryPathEntry kind="3" linkType="1"
									path="${PROJECT_FRAMEWORKS}/libs/automation_agent.swc"
									useDefaultLinkType="false" />
							</excludedEntries>
						</libraryPathEntry>
            
            <xsl:if test="//runtime/@supportMessaging = 'true'">
              <libraryPathEntry kind="3" linkType="1"
                path="{//runtime/@path}weborbassets/wdm/weborb.swc"
                useDefaultLinkType="false" />
            </xsl:if>
            
						<libraryPathEntry kind="4" path="" />
<!--
						<xsl:if test="//runtime/@codeFormatType = 8">
							<libraryPathEntry kind="1" linkType="1" path="libs" />
						</xsl:if>
						
						<xsl:if test="//runtime/@codeFormatType = 5">
							<libraryPathEntry kind="1" linkType="1" path="libs" />
							<libraryPathEntry kind="3" linkType="1"
								path="libs/Cairngorm.swc" useDefaultLinkType="false" />
						</xsl:if>

						<xsl:if test="//runtime/@codeFormatType = 3">
							<libraryPathEntry kind="1" linkType="1" path="libs" />
						</xsl:if>
						
						<xsl:if test="//runtime/@codeFormatType = 4">
							<libraryPathEntry kind="1" linkType="1" path="libs" />
						</xsl:if>
            -->

					</libraryPath>
					<sourceAttachmentPath>
						<sourceAttachmentPathEntry kind="3"
							linkType="1" path="${PROJECT_FRAMEWORKS}/libs/datavisualization.swc"
							sourcepath="${PROJECT_FRAMEWORKS}/source" useDefaultLinkType="false" />
						<sourceAttachmentPathEntry kind="3"
							linkType="1" path="${PROJECT_FRAMEWORKS}/libs/flex.swc"
							sourcepath="${PROJECT_FRAMEWORKS}/source" useDefaultLinkType="false" />
						<sourceAttachmentPathEntry kind="3"
							linkType="1" path="${PROJECT_FRAMEWORKS}/libs/framework.swc"
							sourcepath="${PROJECT_FRAMEWORKS}/source" useDefaultLinkType="true" />
					</sourceAttachmentPath>
				</compiler>
				<applications>
					<!-- application path="{//service/@name}.mxml" /-->
					<xsl:call-template name="codegen.project.eclipse.flex.actionscript.properties.applications" />
				</applications>
				<modules />
				<buildCSSFiles />
			</actionScriptProperties>
		</file>
	</xsl:template>
		
</xsl:stylesheet>

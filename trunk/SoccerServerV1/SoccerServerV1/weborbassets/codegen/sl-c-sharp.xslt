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
    from the <xsl:value-of select="@fullname" /> class using WebORB Silverlight. 
    client API.
    The generated files can be added to a Visual Studio 2008 Silverlight library 
    project. You can compile the library and use it from other Silverlight
    component projects.
    ************************************************************************/
  </xsl:template>
 
  <xsl:template name="codegen.process.fullproject">
    <xsl:param name="file-name" select="codegen:getServiceName()"/>

    <xsl:for-each select="/namespaces">
          <xsl:call-template name="codegen.process.namespace" />
    </xsl:for-each>

    <xsl:call-template name="codegen.project.file">
        <xsl:with-param name="projectVersion" select="2010"/>
    </xsl:call-template>

    <xsl:call-template name="codegen.project.file">
      <xsl:with-param name="projectVersion" select="2008"/>
    </xsl:call-template>

    <file name="App.xaml" type="xml">
      <Application xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
                   xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"             
                   x:Class="{$file-name}.App">
        &lt;Application.Resources>
        
        &lt;/Application.Resources>
      </Application>
    </file>

    <file name="App.xaml.cs">
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;

namespace <xsl:value-of select="$file-name"/>
{
    public partial class App: Application
    {
        public static string WeborbURL { get; set; }

        public App()
        {
            this.Startup += this.Application_Startup;
            this.Exit += this.Application_Exit;
            this.UnhandledException += this.Application_UnhandledException;

            InitializeComponent();
        }

        private void Application_Startup(object sender, StartupEventArgs e)
        {
            string urlValue = null;
            try
            {
                urlValue = e.InitParams["WebORBURL"];
            }
            catch { }

            if (string.IsNullOrEmpty(urlValue))
                urlValue = "weborb.aspx";

            WeborbURL = urlValue;

            this.RootVisual = new Page();
        }

        private void Application_Exit(object sender, EventArgs e)
        {

        }
        private void Application_UnhandledException(object sender, ApplicationUnhandledExceptionEventArgs e)
        {
            // If the app is running outside of the debugger then report the exception using
            // the browser's exception mechanism. On IE this will display it a yellow alert
            // icon in the status bar and Firefox will display a script error.
            if (!System.Diagnostics.Debugger.IsAttached)
            {

                // NOTE: This will allow the application to continue running after an exception has been thrown
                // but not handled.
                // For production applications this error handling should be replaced with something that will
                // report the error to the website and stop the application.
                e.Handled = true;

                try 
                {
                    string errorMsg = e.ExceptionObject.Message + e.ExceptionObject.StackTrace;
                    errorMsg = errorMsg.Replace('"', '\'').Replace("\r\n", @"\n");

                    System.Windows.Browser.HtmlPage.Window.Eval("throw new Error(\"Unhandled Error in Silverlight 2 Application " + errorMsg + "\");");
                }
                catch (Exception) 
                {
                }
            }
        }
    }
}
    </file>

    <file name="Page.xaml" type="xml">
      <UserControl x:Class="{$file-name}.Page"
          xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
          xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
          Width="400" Height="300">
        &lt;Grid x:Name="LayoutRoot" Background="White">
        
        &lt;/Grid>
      </UserControl>
    </file>


<file name="Page.xaml.cs">
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;
using Weborb.Client;

namespace <xsl:value-of select="$file-name"/>
{
    public partial class Page : UserControl
    {
        private WeborbClient weborbClient;
        
        public Page()
        {
            InitializeComponent();
            weborbClient = new WeborbClient( App.WeborbURL, this);
            // a simple invocation would look like this:
            //IService proxy = weborbClient.Bind&lt;IService>();
            //AsyncToken&lt;string> res = proxy.GetData("2");
            //res.ResultListener += GetDataResultHandler;
        }

        // simple responder
        //public void GetDataResultHandler(string result)
        //{
        // ...
        //}
    }
}
</file>
 


      <folder name="Properties">
        <file name="AppManifest.xml" type="xml">
          <Deployment xmlns="http://schemas.microsoft.com/client/2007/deployment"
                  xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">
            &lt;Deployment.Parts>
            &lt;/Deployment.Parts>
          </Deployment>
        </file>
        <file name="AssemblyInfo.cs">
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

// General Information about an assembly is controlled through the following
// set of attributes. Change these attribute values to modify the information
// associated with an assembly.
[assembly: AssemblyTitle("<xsl:value-of select="$file-name"/>")]
[assembly: AssemblyDescription("")]
[assembly: AssemblyConfiguration("")]
[assembly: AssemblyCompany("")]
[assembly: AssemblyProduct("<xsl:value-of select="$file-name"/>")]
[assembly: AssemblyCopyright("")]
[assembly: AssemblyTrademark("")]
[assembly: AssemblyCulture("")]

// Setting ComVisible to false makes the types in this assembly not visible
// to COM components.  If you need to access a type in this assembly from
// COM, set the ComVisible attribute to true on that type.
[assembly: ComVisible(false)]

// The following GUID is for the ID of the typelib if this project is exposed to COM
[assembly: Guid("<xsl:value-of select="codegen:getGuid()"/>")]

// Version information for an assembly consists of the following four values:
//
//      Major Version
//      Minor Version
//      Build Number
//      Revision
//
// You can specify all the values or you can default the Revision and Build Numbers
// by using the '*' as shown below:
[assembly: AssemblyVersion("1.0.0.0")]
[assembly: AssemblyFileVersion("1.0.0.0")]
        </file>
      </folder>
  </xsl:template>

  <xsl:template name="codegen.project.file">
    <xsl:param name="file-name" select="codegen:getServiceName()"/>
    <xsl:param name="projectVersion"/>

    <file name="{$file-name}_VS{$projectVersion}.csproj" type="xml">

      <xsl:if test="$projectVersion=2008">
        &lt;Project ToolsVersion="3.5" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
      </xsl:if>
      <xsl:if test="$projectVersion=2010">
        &lt;Project ToolsVersion="4.0" DefaultTargets="Build" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
      </xsl:if>      

        <!--<xsl:if test="$projectVersion=2010">
          <PropertyGroup Condition="'$(MSBuildToolsVersion)' == '3.5'">
            <TargetFrameworkVersion>v3.5</TargetFrameworkVersion>
          </PropertyGroup>
        </xsl:if>-->

        <PropertyGroup>
          <Configuration Condition=" '$(Configuration)' == '' ">Debug</Configuration>
          <Platform Condition=" '$(Platform)' == '' ">AnyCPU</Platform>
          <!--<ProductVersion>8.0.50727</ProductVersion>-->
          <SchemaVersion>2.0</SchemaVersion>
          <ProjectGuid>{<xsl:value-of select="codegen:getGuid()"/>}</ProjectGuid>
          <ProjectTypeGuids>{A1591282-1198-4647-A2B1-27E5FF5F6F3B};{fae04ec0-301f-11d3-bf4b-00c04f79efbc}</ProjectTypeGuids>
          <OutputType>Library</OutputType>
          <AppDesignerFolder>Properties</AppDesignerFolder>
          <RootNamespace><xsl:value-of select="$file-name"/></RootNamespace>
          <AssemblyName><xsl:value-of select="$file-name"/></AssemblyName>
          <xsl:if test="$projectVersion=2008">
            <TargetFrameworkVersion>v3.5</TargetFrameworkVersion>
          </xsl:if>
          <xsl:if test="$projectVersion=2010">
            <TargetFrameworkVersion>v4.0</TargetFrameworkVersion>
          </xsl:if>
          <SilverlightApplication>true</SilverlightApplication>
          &lt;SupportedCultures>&lt;/SupportedCultures>
          <XapOutputs>true</XapOutputs>
          <GenerateSilverlightManifest>true</GenerateSilverlightManifest>
          <XapFilename><xsl:value-of select="$file-name"/>.xap</XapFilename>
          <SilverlightManifestTemplate>Properties\AppManifest.xml</SilverlightManifestTemplate>
          <SilverlightAppEntry><xsl:value-of select="$file-name"/>.App</SilverlightAppEntry>
          <TestPageFileName>TestPage.html</TestPageFileName>
          <CreateTestPage>true</CreateTestPage>
          <ValidateXaml>true</ValidateXaml>
          <ThrowErrorsInValidation>false</ThrowErrorsInValidation>

          <xsl:if test="$projectVersion=2010">
            <TargetFrameworkIdentifier>Silverlight</TargetFrameworkIdentifier>
            <SilverlightVersion>$(TargetFrameworkVersion)</SilverlightVersion>
            <FileUpgradeFlags>
            </FileUpgradeFlags>
            <UpgradeBackupLocation>
            </UpgradeBackupLocation>
            <OldToolsVersion>4.0</OldToolsVersion>
            <IsWebBootstrapper>false</IsWebBootstrapper>
            <PublishUrl>publish\</PublishUrl>
            <Install>true</Install>
            <InstallFrom>Disk</InstallFrom>
            <UpdateEnabled>false</UpdateEnabled>
            <UpdateMode>Foreground</UpdateMode>
            <UpdateInterval>7</UpdateInterval>
            <UpdateIntervalUnits>Days</UpdateIntervalUnits>
            <UpdatePeriodically>false</UpdatePeriodically>
            <UpdateRequired>false</UpdateRequired>
            <MapFileExtensions>true</MapFileExtensions>
            <ApplicationRevision>0</ApplicationRevision>
            <ApplicationVersion>1.0.0.%2a</ApplicationVersion>
            <UseApplicationTrust>false</UseApplicationTrust>
            <BootstrapperEnabled>true</BootstrapperEnabled>
          </xsl:if>

        </PropertyGroup>
        <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Debug|AnyCPU' ">
          <DebugSymbols>true</DebugSymbols>
          <DebugType>full</DebugType>
          <Optimize>false</Optimize>
          <OutputPath>Bin\Debug</OutputPath>
          <DefineConstants>DEBUG;TRACE;SILVERLIGHT</DefineConstants>
          <NoStdLib>true</NoStdLib>
          <NoConfig>true</NoConfig>
          <ErrorReport>prompt</ErrorReport>
          <WarningLevel>4</WarningLevel>
          <xsl:if test="$projectVersion=2010">
            <CodeAnalysisRuleSet>AllRules.ruleset</CodeAnalysisRuleSet>
          </xsl:if>
        </PropertyGroup>
        <PropertyGroup Condition=" '$(Configuration)|$(Platform)' == 'Release|AnyCPU' ">
          <DebugType>pdbonly</DebugType>
          <Optimize>true</Optimize>
          <OutputPath>Bin\Release</OutputPath>
          <DefineConstants>TRACE;SILVERLIGHT</DefineConstants>
          <NoStdLib>true</NoStdLib>
          <NoConfig>true</NoConfig>
          <ErrorReport>prompt</ErrorReport>
          <WarningLevel>4</WarningLevel>
          <xsl:if test="$projectVersion=2010">
            <CodeAnalysisRuleSet>AllRules.ruleset</CodeAnalysisRuleSet>
          </xsl:if>
        </PropertyGroup>
        <ItemGroup>
          <Reference Include="System.Windows" />
          <Reference Include="mscorlib" />
          <Reference Include="system" />
          <Reference Include="System.Core" />
          <Reference Include="System.Net" />
          <Reference Include="System.Xml" />
          <Reference Include="System.Windows.Browser" />
          <Reference Include="WeborbClient.dll, Culture=neutral, processorArchitecture=MSIL">
            <SpecificVersion>False</SpecificVersion>
            <HintPath>Bin\WeborbClient.dll</HintPath>
            <Private>True</Private>
          </Reference>

        </ItemGroup>
        <ItemGroup>
          <Compile Include="App.xaml.cs">
            <DependentUpon>App.xaml</DependentUpon>
          </Compile>
          <Compile Include="Page.xaml.cs">
            <DependentUpon>Page.xaml</DependentUpon>
          </Compile>
          <Compile Include="Properties\AssemblyInfo.cs" />

          <xsl:for-each select="//service">
            <xsl:variable name="temp" select="translate(@fullname,'.','\')"/>
            <xsl:variable name="sourceFilePath" select="substring($temp,1,string-length($temp)-string-length(@name)-1)"/>
            <Compile Include="{$sourceFilePath}\{@name}Service.cs" />
            <Compile Include="{$sourceFilePath}\I{@name}.cs" />
            <Compile Include="{$sourceFilePath}\{@name}Model.cs" />
          </xsl:for-each>

          <xsl:for-each select="//datatype">
            <xsl:variable name="temp" select="translate(@fullname,'.','\')"/>
            <xsl:variable name="sourceFilePath" select="substring($temp,1,string-length($temp)-string-length(@name)-1)"/>
            <Compile Include="{$sourceFilePath}\Types\{@name}.cs" />
          </xsl:for-each>
          <xsl:for-each select="//enum">
            <xsl:variable name="temp" select="translate(@fullname,'.','\')"/>
            <xsl:variable name="sourceFilePath" select="substring($temp,1,string-length($temp)-string-length(@name)-1)"/>
            <Compile Include="{$sourceFilePath}\Types\{@name}.cs" />
          </xsl:for-each>

        </ItemGroup>
        <ItemGroup>
          <ApplicationDefinition Include="App.xaml">
            <xsl:if test="$projectVersion=2008">
              <Generator>MSBuild:MarkupCompilePass1</Generator>
            </xsl:if>
            <xsl:if test="$projectVersion=2010">
              <Generator>MSBuild:Compile</Generator>
            </xsl:if>           
            <SubType>Designer</SubType>
          </ApplicationDefinition>
          <Page Include="Page.xaml">
            <xsl:if test="$projectVersion=2008">
              <Generator>MSBuild:MarkupCompilePass1</Generator>
            </xsl:if>
            <xsl:if test="$projectVersion=2010">
              <Generator>MSBuild:Compile</Generator>
            </xsl:if>
            <SubType>Designer</SubType>
          </Page>
        </ItemGroup>
        <ItemGroup>
          <None Include="Properties\AppManifest.xml" />
          <None Include="Bin\WeborbClient.dll" />
        </ItemGroup>

        <xsl:if test="$projectVersion=2008">
          <Import Project="$(MSBuildExtensionsPath)\Microsoft\Silverlight\v3.0\Microsoft.Silverlight.CSharp.targets" />
        </xsl:if>
        
        <xsl:if test="$projectVersion=2010">
          <ItemGroup>
            <BootstrapperPackage Include="Microsoft.Net.Client.3.5">
              <Visible>False</Visible>
              <ProductName>.NET Framework 3.5 SP1 Client Profile</ProductName>
              <Install>false</Install>
            </BootstrapperPackage>
            <BootstrapperPackage Include="Microsoft.Net.Framework.3.5.SP1">
              <Visible>False</Visible>
              <ProductName>.NET Framework 3.5 SP1</ProductName>
              <Install>true</Install>
            </BootstrapperPackage>
            <BootstrapperPackage Include="Microsoft.VisualBasic.PowerPacks.10.0">
              <Visible>False</Visible>
              <ProductName>Microsoft Visual Basic PowerPacks 10.0</ProductName>
              <Install>true</Install>
            </BootstrapperPackage>
            <BootstrapperPackage Include="Microsoft.Windows.Installer.3.1">
              <Visible>False</Visible>
              <ProductName>Windows Installer 3.1</ProductName>
              <Install>true</Install>
            </BootstrapperPackage>
          </ItemGroup>
          <Import Project="$(MSBuildExtensionsPath32)\Microsoft\Silverlight\$(SilverlightVersion)\Microsoft.Silverlight.CSharp.targets" />
        </xsl:if>

        <ProjectExtensions>
          <VisualStudio>            
            <FlavorProperties GUID="{concat('{','A1591282-1198-4647-A2B1-27E5FF5F6F3B','}')}" xmlns="">
              <SilverlightProjectProperties>
              </SilverlightProjectProperties>
            </FlavorProperties>
          </VisualStudio>
        </ProjectExtensions>

      &lt;/Project>     
    </file>
  </xsl:template>

  <xsl:template name="codegen.service">
      <file name="{@name}Service.cs">
        <xsl:call-template name="codegen.code" />
      </file>
      <file name="I{@name}.cs">
        <xsl:call-template name="codegen.interface" />
      </file>
      <file name="{@name}Model.cs">
        <xsl:call-template name="codegen.model" />
      </file>     
  </xsl:template>

  <xsl:template name="codegen.vo.folder">
    <xsl:param name="version" select="3" />
    <xsl:if test="count(datatype) != 0">
      <folder name="Types">
        <xsl:for-each select="datatype">
          <xsl:call-template name="codegen.sl.vo">
            <xsl:with-param name="version" select="$version" />
          </xsl:call-template>
        </xsl:for-each>
        <xsl:for-each select="enum">
          <xsl:call-template name="codegen.sl.enum">
              <xsl:with-param name="version" select="$version" />
          </xsl:call-template>
        </xsl:for-each>
      </folder>
    </xsl:if>
  </xsl:template>

  <xsl:template name="codegen.sl.enum">
      <file name="{@name}.cs">
          <xsl:call-template name="codegen.description">
              <xsl:with-param name="file-name" select="concat(@name,'.cs')" />
          </xsl:call-template>
          using System;
          using System.Collections.Generic;
          <!--<xsl:for-each select="//datatype[not(preceding-sibling::datatype/@typeNamespace=@typeNamespace or @typeNamespace = current()/@typeNamespace)]">
        using <xsl:value-of select="@typeNamespace" />;
      </xsl:for-each>
      <xsl:for-each select="//enum[not(preceding-sibling::datatype/@typeNamespace=@typeNamespace or //datatype/@typeNamespace=@typeNamespace or @typeNamespace = current()/@typeNamespace)]">
        using <xsl:value-of select="@typeNamespace" />;
      </xsl:for-each>-->
          namespace <xsl:value-of select="@typeNamespace" />
          {
          public enum <xsl:value-of select="@name"/> <xsl:if test="@parentName">
              : <xsl:value-of select="@parentNamespace"/>.<xsl:value-of select="@parentName"/>
          </xsl:if>
            {
              <xsl:for-each select="field">
                <xsl:value-of select="@name"/><xsl:if test="position() != last()">,</xsl:if>
              </xsl:for-each>
            }
          }
      </file>
  </xsl:template>

  <xsl:template name="codegen.sl.vo">
    <file name="{@name}.cs">
      <xsl:call-template name="codegen.description">
        <xsl:with-param name="file-name" select="concat(@name,'.cs')" />
      </xsl:call-template>
        using System;
        using System.Collections.Generic;
      <!--<xsl:for-each select="//datatype[not(preceding-sibling::datatype/@typeNamespace=@typeNamespace or @typeNamespace = current()/@typeNamespace)]">
        using <xsl:value-of select="@typeNamespace" />;
      </xsl:for-each>
      <xsl:for-each select="//enum[not(preceding-sibling::datatype/@typeNamespace=@typeNamespace or //datatype/@typeNamespace=@typeNamespace or @typeNamespace = current()/@typeNamespace)]">
        using <xsl:value-of select="@typeNamespace" />;
      </xsl:for-each>-->
       namespace <xsl:value-of select="@typeNamespace" />
        {
        public class <xsl:value-of select="@name"/> <xsl:if test="@parentName"> : <xsl:value-of select="@parentNamespace"/>.<xsl:value-of select="@parentName"/></xsl:if>
        {
        <xsl:for-each select="const">
          public const <xsl:value-of select="@nativetype"/><xsl:text> </xsl:text><xsl:value-of select="@name"/> = <xsl:if test="@type='String'">"</xsl:if><xsl:value-of select="@value"/><xsl:if test="@type='String'">"</xsl:if>;
        </xsl:for-each>
        <xsl:for-each select="field">
          public <xsl:value-of select="@nativetype"/><xsl:text> </xsl:text><xsl:value-of select="@name"/>;
        </xsl:for-each>
        }
      }
    </file>
  </xsl:template>  
  
  <xsl:template name="codegen.invoke.method.name">
    m_service.<xsl:value-of select="@name"/>
  </xsl:template>
  
  <xsl:template name="codegen.code">
    <xsl:call-template name="codegen.description">
      <xsl:with-param name="file-name" select="concat(concat(@name,'Service'),'.cs')" />
    </xsl:call-template>
    <xsl:call-template name="comment.service" />
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using Weborb.Client;
    <xsl:for-each select="//namespace[datatype]">
    using <xsl:value-of select="@fullname" />;
    </xsl:for-each>

    namespace <xsl:value-of select="@namespace" />
    {
    public class <xsl:value-of select="@name"/>Service
    {
      private WeborbClient weborbClient;
      private <xsl:value-of select="concat('I',@name)" /> proxy;
      private <xsl:value-of select="@name"/>Model model;

      public <xsl:value-of select="@name"/>Service() : this( new <xsl:value-of select="@name"/>Model() )
      {
      }
      
      public <xsl:value-of select="@name"/>Service( <xsl:value-of select="@name"/>Model model )
      {
        this.model = model;
        weborbClient = new WeborbClient("weborb.aspx"); 
        proxy = weborbClient.Bind&lt;<xsl:value-of select="concat('I',@name)" />&gt;();
      }

      public <xsl:value-of select="@name"/>Model GetModel()
      {
        return this.model;
      }
    <xsl:for-each select="method">
      public <xsl:if test="@type='void'">void</xsl:if><xsl:if test="@type!='void'">AsyncToken&lt;<xsl:value-of select="@nativetype" />&gt;</xsl:if><xsl:text> </xsl:text><xsl:value-of select="@name"/>( <xsl:for-each select="arg"><xsl:value-of select="@nativetype" /><xsl:text> </xsl:text><xsl:value-of select="@name"/><xsl:if test="position() != last()">,</xsl:if><xsl:text> </xsl:text></xsl:for-each> )
      {<xsl:choose>
        <xsl:when test="@type != 'void'">
            AsyncToken&lt;<xsl:value-of select="@nativetype" />&gt;<xsl:text> </xsl:text> asyncToken = proxy.<xsl:value-of select="@name"/>(<xsl:for-each select="arg"><xsl:if test="position() != 1">,</xsl:if><xsl:value-of select="@name"/></xsl:for-each>);
            asyncToken.ResultListener += <xsl:value-of select="@name" />ResultHandler;
            return asyncToken;
      </xsl:when>
        <xsl:otherwise>
            proxy.<xsl:value-of select="@name"/>(<xsl:for-each select="arg"><xsl:if test="position() != 1">,</xsl:if><xsl:value-of select="@name"/></xsl:for-each>);
      </xsl:otherwise>
</xsl:choose>}
    </xsl:for-each>
    
    <xsl:for-each select="method">     
     <xsl:if test="@type != 'void'">
      void <xsl:value-of select="@name" />ResultHandler(<xsl:value-of select="@nativetype" /> result)
      {
        model.<xsl:value-of select="@name" />Result = result;
      }</xsl:if>
    </xsl:for-each>
    }
  } 
  </xsl:template>
  
  <xsl:template name="codegen.interface">
    <xsl:call-template name="codegen.description">
      <xsl:with-param name="file-name" select="concat('I',concat(@name,'.cs'))" />
    </xsl:call-template>
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using Weborb.Client;
    <xsl:for-each select="//namespace[datatype]">
    using <xsl:value-of select="@fullname" />;
    </xsl:for-each>

    namespace <xsl:value-of select="@namespace" />
    {
      public interface I<xsl:value-of select="@name"/>
      {<xsl:for-each select="method">
        <xsl:choose>
            <xsl:when test="@type != 'void'">
                AsyncToken&lt;<xsl:value-of select="@nativetype" />&gt; <xsl:value-of select="@name"/>(<xsl:for-each select="arg"><xsl:value-of select="concat(@nativetype, ' ')" /> <xsl:value-of select="@name"/><xsl:if test="position() != last()">,</xsl:if></xsl:for-each>);
      </xsl:when>
            <xsl:otherwise>
                void <xsl:value-of select="@name"/>(<xsl:for-each select="arg"><xsl:value-of select="concat(@nativetype, ' ')" /> <xsl:value-of select="@name"/><xsl:if test="position() != last()">,</xsl:if></xsl:for-each>);
            </xsl:otherwise>
    </xsl:choose>
    </xsl:for-each>}
  } 
  </xsl:template>
  
  <xsl:template name="codegen.model">
    <xsl:call-template name="codegen.description">
      <xsl:with-param name="file-name" select="concat(@name,'Model.cs')" />
    </xsl:call-template>

    using System;
    using System.Collections.Generic;
    <xsl:for-each select="//namespace[datatype]">
    using <xsl:value-of select="@fullname" />;
    </xsl:for-each>

    namespace <xsl:value-of select="@namespace" />
    { 
      public class <xsl:value-of select="@name"/>Model
      {<xsl:for-each select="method"><xsl:if test="@type != 'void'">     
        public <xsl:value-of select="@nativetype" /><xsl:text> </xsl:text><xsl:value-of select="@name" />Result;</xsl:if></xsl:for-each>
      }
    }
  </xsl:template>
  
  <xsl:template name="codegen.instructions">
  <xsl:param name="file-name" select="codegen:getServiceName()"/>
    <file name="{$file-name}-instructions.txt" overwrite="false">
      The generated code enables remoting operations between a Silverlight client and the 
      selected service (<xsl:value-of select="$file-name"/>).
      
      Generated classes include:
      
      1. Service facade (<xsl:value-of select="//service/@namespace" />.<xsl:value-of select="$file-name"/>Service) - Contains the same 
          methods as the remote service. Includes functionality for creating a proxy, handling 
          RPC invocations and updating the model.
          
      2. Model class (<xsl:value-of select="//service/@namespace" />.<xsl:value-of select="$file-name"/>Model) - Contains properties 
         updated by the Service facade when it receives results from the remote method invocations.
          
      3. Remote service interface (<xsl:value-of select="//service/@namespace" />.I<xsl:value-of select="$file-name"/>) - An interface 
          with the same methods as the remote service, but modified return values to reflect 
          the asynchronous nature of the client/server invocations.
    </file>
  </xsl:template>  
</xsl:stylesheet>

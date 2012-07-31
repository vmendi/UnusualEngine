package es.desafiate
{
	 import mx.rpc.xml.Schema
	 public class BaseMainServiceSchema
	{
		 public var schemas:Array = new Array();
		 public var targetNamespaces:Array = new Array();
		 public function BaseMainServiceSchema():void
		{
			 var xsdXML0:XML = <s:schema xmlns:s="http://www.w3.org/2001/XMLSchema" xmlns:http="http://schemas.xmlsoap.org/wsdl/http/" xmlns:mime="http://schemas.xmlsoap.org/wsdl/mime/" xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns:soap12="http://schemas.xmlsoap.org/wsdl/soap12/" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:tm="http://microsoft.com/wsdl/mime/textMatching/" xmlns:tns="http://tempuri.org/" xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" attributeFormDefault="unqualified" elementFormDefault="qualified" targetNamespace="http://tempuri.org/">
    <s:element name="sessionStart">
        <s:complexType>
            <s:sequence>
                <s:element minOccurs="0" name="cFacebookString" type="s:string"/>
            </s:sequence>
        </s:complexType>
    </s:element>
    <s:element name="sessionStartResponse">
        <s:complexType>
            <s:sequence>
                <s:element minOccurs="0" name="sessionStartResult" type="s:string"/>
            </s:sequence>
        </s:complexType>
    </s:element>
    <s:element name="sessionStartNew">
        <s:complexType>
            <s:sequence>
                <s:element minOccurs="0" name="cFacebookString" type="s:string"/>
                <s:element minOccurs="0" name="cSessionID" type="s:string"/>
            </s:sequence>
        </s:complexType>
    </s:element>
    <s:element name="sessionStartNewResponse">
        <s:complexType>
            <s:sequence>
                <s:element minOccurs="0" name="sessionStartNewResult" type="s:string"/>
            </s:sequence>
        </s:complexType>
    </s:element>
    <s:element name="keepAlive">
        <s:complexType>
            <s:sequence>
                <s:element minOccurs="0" name="cFacebookString" type="s:string"/>
                <s:element minOccurs="0" name="nIdSesion" type="s:string"/>
            </s:sequence>
        </s:complexType>
    </s:element>
    <s:element name="keepAliveResponse">
        <s:complexType>
            <s:sequence>
                <s:element minOccurs="0" name="keepAliveResult" type="s:string"/>
            </s:sequence>
        </s:complexType>
    </s:element>
    <s:element name="getChecker">
        <s:complexType/>
    </s:element>
    <s:element name="getCheckerResponse">
        <s:complexType>
            <s:sequence>
                <s:element minOccurs="0" name="getCheckerResult" type="s:string"/>
            </s:sequence>
        </s:complexType>
    </s:element>
    <s:element name="getHOF">
        <s:complexType/>
    </s:element>
    <s:element name="getHOFResponse">
        <s:complexType>
            <s:sequence>
                <s:element minOccurs="0" name="getHOFResult" type="tns:ArrayOfUserData"/>
            </s:sequence>
        </s:complexType>
    </s:element>
    <s:complexType name="ArrayOfUserData">
        <s:sequence>
            <s:element maxOccurs="unbounded" minOccurs="0" name="UserData" type="tns:UserData"/>
        </s:sequence>
    </s:complexType>
    <s:complexType name="UserData">
        <s:sequence>
            <s:element minOccurs="0" name="Usuario" type="s:string"/>
            <s:element minOccurs="0" name="Puntuacion" type="s:string"/>
        </s:sequence>
    </s:complexType>
    <s:element name="getUsuario">
        <s:complexType>
            <s:sequence>
                <s:element minOccurs="0" name="cFacebookString" type="s:string"/>
                <s:element minOccurs="0" name="nIdSesion" type="s:string"/>
                <s:element minOccurs="0" name="cUserCheck" type="s:string"/>
            </s:sequence>
        </s:complexType>
    </s:element>
    <s:element name="getUsuarioResponse">
        <s:complexType>
            <s:sequence>
                <s:element minOccurs="0" name="getUsuarioResult" type="s:string"/>
            </s:sequence>
        </s:complexType>
    </s:element>
    <s:element name="saveUsuario">
        <s:complexType>
            <s:sequence>
                <s:element minOccurs="0" name="cFacebookString" type="s:string"/>
                <s:element minOccurs="0" name="nIdSesion" type="s:string"/>
                <s:element minOccurs="0" name="cxmlProperties" type="s:string"/>
                <s:element minOccurs="0" name="cUserCheck" type="s:string"/>
            </s:sequence>
        </s:complexType>
    </s:element>
    <s:element name="saveUsuarioResponse">
        <s:complexType>
            <s:sequence>
                <s:element minOccurs="0" name="saveUsuarioResult" type="s:string"/>
            </s:sequence>
        </s:complexType>
    </s:element>
    <s:element name="savePuntuacion">
        <s:complexType>
            <s:sequence>
                <s:element minOccurs="0" name="cFacebookString" type="s:string"/>
                <s:element minOccurs="0" name="nIdSesion" type="s:string"/>
                <s:element minOccurs="0" name="cEvento" type="s:string"/>
                <s:element name="nPuntuacion" type="s:int"/>
                <s:element minOccurs="0" name="cUserCheck" type="s:string"/>
            </s:sequence>
        </s:complexType>
    </s:element>
    <s:element name="savePuntuacionResponse">
        <s:complexType>
            <s:sequence>
                <s:element minOccurs="0" name="savePuntuacionResult" type="s:string"/>
            </s:sequence>
        </s:complexType>
    </s:element>
    <s:element name="addLogro">
        <s:complexType>
            <s:sequence>
                <s:element minOccurs="0" name="cFacebookString" type="s:string"/>
                <s:element minOccurs="0" name="nIdSesion" type="s:string"/>
                <s:element minOccurs="0" name="cEvento" type="s:string"/>
                <s:element minOccurs="0" name="cLogro" type="s:string"/>
                <s:element minOccurs="0" name="cUserCheck" type="s:string"/>
            </s:sequence>
        </s:complexType>
    </s:element>
    <s:element name="addLogroResponse">
        <s:complexType>
            <s:sequence>
                <s:element minOccurs="0" name="addLogroResult" type="s:string"/>
            </s:sequence>
        </s:complexType>
    </s:element>
    <s:element name="string" nillable="true" type="s:string"/>
    <s:element name="ArrayOfUserData" nillable="true" type="tns:ArrayOfUserData"/>
</s:schema>
;
			 var xsdSchema0:Schema = new Schema(xsdXML0);
			schemas.push(xsdSchema0);
			targetNamespaces.push(new Namespace('','http://tempuri.org/'));
		}
	}
}
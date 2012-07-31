package com.embellecetupiel
{
	 import mx.rpc.xml.Schema
	 public class BaseDoveWebServiceSchema
	{
		 public var schemas:Array = new Array();
		 public var targetNamespaces:Array = new Array();
		 public function BaseDoveWebServiceSchema():void
		{
			 var xsdXML0:XML = <s:schema xmlns:s="http://www.w3.org/2001/XMLSchema" xmlns:http="http://schemas.xmlsoap.org/wsdl/http/" xmlns:mime="http://schemas.xmlsoap.org/wsdl/mime/" xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns:soap12="http://schemas.xmlsoap.org/wsdl/soap12/" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:tm="http://microsoft.com/wsdl/mime/textMatching/" xmlns:tns="http://embellecetupiel.com/Services" xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" attributeFormDefault="unqualified" elementFormDefault="qualified" targetNamespace="http://embellecetupiel.com/Services">
    <s:element name="SaveTestResult">
        <s:complexType>
            <s:sequence>
                <s:element minOccurs="0" name="answers" type="tns:ArrayOfString"/>
            </s:sequence>
        </s:complexType>
    </s:element>
    <s:complexType name="ArrayOfString">
        <s:sequence>
            <s:element maxOccurs="unbounded" minOccurs="0" name="string" nillable="true" type="s:string"/>
        </s:sequence>
    </s:complexType>
    <s:element name="SaveTestResultResponse">
        <s:complexType>
            <s:sequence>
                <s:element name="SaveTestResultResult" type="s:int"/>
            </s:sequence>
        </s:complexType>
    </s:element>
    <s:element name="SaveRegister">
        <s:complexType>
            <s:sequence>
                <s:element minOccurs="0" name="registerFields" type="tns:RegisterFields"/>
            </s:sequence>
        </s:complexType>
    </s:element>
    <s:complexType name="RegisterFields">
        <s:sequence>
            <s:element name="SkinTestId" type="s:int"/>
            <s:element minOccurs="0" name="Nombre" type="s:string"/>
            <s:element minOccurs="0" name="Apellidos" type="s:string"/>
            <s:element minOccurs="0" name="eMail" type="s:string"/>
            <s:element minOccurs="0" name="Sexo" type="s:string"/>
            <s:element minOccurs="0" name="FechaNacimiento" type="s:string"/>
            <s:element minOccurs="0" name="Telf" type="s:string"/>
            <s:element minOccurs="0" name="Ciudad" type="s:string"/>
            <s:element minOccurs="0" name="Provincia" type="s:string"/>
        </s:sequence>
    </s:complexType>
    <s:element name="SaveRegisterResponse">
        <s:complexType>
            <s:sequence>
                <s:element minOccurs="0" name="SaveRegisterResult" type="s:string"/>
            </s:sequence>
        </s:complexType>
    </s:element>
</s:schema>
;
			 var xsdSchema0:Schema = new Schema(xsdXML0);
			schemas.push(xsdSchema0);
			targetNamespaces.push(new Namespace('','http://embellecetupiel.com/Services'));
		}
	}
}
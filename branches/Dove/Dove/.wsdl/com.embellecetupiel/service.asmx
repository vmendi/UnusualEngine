<?xml version="1.0" encoding="UTF-8"?><wsdl:definitions xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" xmlns:http="http://schemas.xmlsoap.org/wsdl/http/" xmlns:mime="http://schemas.xmlsoap.org/wsdl/mime/" xmlns:s="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns:soap12="http://schemas.xmlsoap.org/wsdl/soap12/" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:tm="http://microsoft.com/wsdl/mime/textMatching/" xmlns:tns="http://embellecetupiel.com/Services" targetNamespace="http://embellecetupiel.com/Services">
  <wsdl:types>
    <s:schema elementFormDefault="qualified" targetNamespace="http://embellecetupiel.com/Services">
      <s:element name="SaveTestResult">
        <s:complexType>
          <s:sequence>
            <s:element maxOccurs="1" minOccurs="0" name="answers" type="tns:ArrayOfString"/>
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
            <s:element maxOccurs="1" minOccurs="1" name="SaveTestResultResult" type="s:int"/>
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="SaveRegister">
        <s:complexType>
          <s:sequence>
            <s:element maxOccurs="1" minOccurs="0" name="registerFields" type="tns:RegisterFields"/>
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:complexType name="RegisterFields">
        <s:sequence>
          <s:element maxOccurs="1" minOccurs="1" name="SkinTestId" type="s:int"/>
          <s:element maxOccurs="1" minOccurs="0" name="Nombre" type="s:string"/>
          <s:element maxOccurs="1" minOccurs="0" name="Apellidos" type="s:string"/>
          <s:element maxOccurs="1" minOccurs="0" name="eMail" type="s:string"/>
          <s:element maxOccurs="1" minOccurs="0" name="Sexo" type="s:string"/>
          <s:element maxOccurs="1" minOccurs="0" name="FechaNacimiento" type="s:string"/>
          <s:element maxOccurs="1" minOccurs="0" name="Telf" type="s:string"/>
          <s:element maxOccurs="1" minOccurs="0" name="Ciudad" type="s:string"/>
          <s:element maxOccurs="1" minOccurs="0" name="Provincia" type="s:string"/>
        </s:sequence>
      </s:complexType>
      <s:element name="SaveRegisterResponse">
        <s:complexType>
          <s:sequence>
            <s:element maxOccurs="1" minOccurs="0" name="SaveRegisterResult" type="s:string"/>
          </s:sequence>
        </s:complexType>
      </s:element>
    </s:schema>
  </wsdl:types>
  <wsdl:message name="SaveRegisterSoapOut">
    <wsdl:part element="tns:SaveRegisterResponse" name="parameters">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="SaveTestResultSoapOut">
    <wsdl:part element="tns:SaveTestResultResponse" name="parameters">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="SaveRegisterSoapIn">
    <wsdl:part element="tns:SaveRegister" name="parameters">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="SaveTestResultSoapIn">
    <wsdl:part element="tns:SaveTestResult" name="parameters">
    </wsdl:part>
  </wsdl:message>
  <wsdl:portType name="ServiceSoap">
    <wsdl:operation name="SaveTestResult">
      <wsdl:input message="tns:SaveTestResultSoapIn">
    </wsdl:input>
      <wsdl:output message="tns:SaveTestResultSoapOut">
    </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="SaveRegister">
      <wsdl:input message="tns:SaveRegisterSoapIn">
    </wsdl:input>
      <wsdl:output message="tns:SaveRegisterSoapOut">
    </wsdl:output>
    </wsdl:operation>
  </wsdl:portType>
  <wsdl:binding name="ServiceSoap12" type="tns:ServiceSoap">
    <soap12:binding transport="http://schemas.xmlsoap.org/soap/http"/>
    <wsdl:operation name="SaveTestResult">
      <soap12:operation soapAction="http://embellecetupiel.com/Services/SaveTestResult" style="document"/>
      <wsdl:input>
        <soap12:body use="literal"/>
      </wsdl:input>
      <wsdl:output>
        <soap12:body use="literal"/>
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="SaveRegister">
      <soap12:operation soapAction="http://embellecetupiel.com/Services/SaveRegister" style="document"/>
      <wsdl:input>
        <soap12:body use="literal"/>
      </wsdl:input>
      <wsdl:output>
        <soap12:body use="literal"/>
      </wsdl:output>
    </wsdl:operation>
  </wsdl:binding>
  <wsdl:binding name="ServiceSoap" type="tns:ServiceSoap">
    <soap:binding transport="http://schemas.xmlsoap.org/soap/http"/>
    <wsdl:operation name="SaveTestResult">
      <soap:operation soapAction="http://embellecetupiel.com/Services/SaveTestResult" style="document"/>
      <wsdl:input>
        <soap:body use="literal"/>
      </wsdl:input>
      <wsdl:output>
        <soap:body use="literal"/>
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="SaveRegister">
      <soap:operation soapAction="http://embellecetupiel.com/Services/SaveRegister" style="document"/>
      <wsdl:input>
        <soap:body use="literal"/>
      </wsdl:input>
      <wsdl:output>
        <soap:body use="literal"/>
      </wsdl:output>
    </wsdl:operation>
  </wsdl:binding>
  <wsdl:service name="Service">
    <wsdl:port binding="tns:ServiceSoap" name="ServiceSoap">
      <soap:address location="http://www.embellecetupiel.com/services/service.asmx"/>
    </wsdl:port>
    <wsdl:port binding="tns:ServiceSoap12" name="ServiceSoap12">
      <soap12:address location="http://www.embellecetupiel.com/services/service.asmx"/>
    </wsdl:port>
  </wsdl:service>
</wsdl:definitions>
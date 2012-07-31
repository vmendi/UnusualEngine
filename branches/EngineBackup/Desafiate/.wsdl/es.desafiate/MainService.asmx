<?xml version="1.0" encoding="UTF-8"?><wsdl:definitions xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" xmlns:http="http://schemas.xmlsoap.org/wsdl/http/" xmlns:mime="http://schemas.xmlsoap.org/wsdl/mime/" xmlns:s="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns:soap12="http://schemas.xmlsoap.org/wsdl/soap12/" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:tm="http://microsoft.com/wsdl/mime/textMatching/" xmlns:tns="http://tempuri.org/" targetNamespace="http://tempuri.org/">
  <wsdl:types>
    <s:schema elementFormDefault="qualified" targetNamespace="http://tempuri.org/">
      <s:element name="sessionStart">
        <s:complexType>
          <s:sequence>
            <s:element maxOccurs="1" minOccurs="0" name="cFacebookString" type="s:string"/>
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="sessionStartResponse">
        <s:complexType>
          <s:sequence>
            <s:element maxOccurs="1" minOccurs="0" name="sessionStartResult" type="s:string"/>
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="sessionStartNew">
        <s:complexType>
          <s:sequence>
            <s:element maxOccurs="1" minOccurs="0" name="cFacebookString" type="s:string"/>
            <s:element maxOccurs="1" minOccurs="0" name="cSessionID" type="s:string"/>
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="sessionStartNewResponse">
        <s:complexType>
          <s:sequence>
            <s:element maxOccurs="1" minOccurs="0" name="sessionStartNewResult" type="s:string"/>
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="keepAlive">
        <s:complexType>
          <s:sequence>
            <s:element maxOccurs="1" minOccurs="0" name="cFacebookString" type="s:string"/>
            <s:element maxOccurs="1" minOccurs="0" name="nIdSesion" type="s:string"/>
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="keepAliveResponse">
        <s:complexType>
          <s:sequence>
            <s:element maxOccurs="1" minOccurs="0" name="keepAliveResult" type="s:string"/>
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="getChecker">
        <s:complexType/>
      </s:element>
      <s:element name="getCheckerResponse">
        <s:complexType>
          <s:sequence>
            <s:element maxOccurs="1" minOccurs="0" name="getCheckerResult" type="s:string"/>
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="getHOF">
        <s:complexType/>
      </s:element>
      <s:element name="getHOFResponse">
        <s:complexType>
          <s:sequence>
            <s:element maxOccurs="1" minOccurs="0" name="getHOFResult" type="tns:ArrayOfUserData"/>
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
          <s:element maxOccurs="1" minOccurs="0" name="Usuario" type="s:string"/>
          <s:element maxOccurs="1" minOccurs="0" name="Puntuacion" type="s:string"/>
        </s:sequence>
      </s:complexType>
      <s:element name="getUsuario">
        <s:complexType>
          <s:sequence>
            <s:element maxOccurs="1" minOccurs="0" name="cFacebookString" type="s:string"/>
            <s:element maxOccurs="1" minOccurs="0" name="nIdSesion" type="s:string"/>
            <s:element maxOccurs="1" minOccurs="0" name="cUserCheck" type="s:string"/>
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="getUsuarioResponse">
        <s:complexType>
          <s:sequence>
            <s:element maxOccurs="1" minOccurs="0" name="getUsuarioResult" type="s:string"/>
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="saveUsuario">
        <s:complexType>
          <s:sequence>
            <s:element maxOccurs="1" minOccurs="0" name="cFacebookString" type="s:string"/>
            <s:element maxOccurs="1" minOccurs="0" name="nIdSesion" type="s:string"/>
            <s:element maxOccurs="1" minOccurs="0" name="cxmlProperties" type="s:string"/>
            <s:element maxOccurs="1" minOccurs="0" name="cUserCheck" type="s:string"/>
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="saveUsuarioResponse">
        <s:complexType>
          <s:sequence>
            <s:element maxOccurs="1" minOccurs="0" name="saveUsuarioResult" type="s:string"/>
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="savePuntuacion">
        <s:complexType>
          <s:sequence>
            <s:element maxOccurs="1" minOccurs="0" name="cFacebookString" type="s:string"/>
            <s:element maxOccurs="1" minOccurs="0" name="nIdSesion" type="s:string"/>
            <s:element maxOccurs="1" minOccurs="0" name="cEvento" type="s:string"/>
            <s:element maxOccurs="1" minOccurs="1" name="nPuntuacion" type="s:int"/>
            <s:element maxOccurs="1" minOccurs="0" name="cUserCheck" type="s:string"/>
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="savePuntuacionResponse">
        <s:complexType>
          <s:sequence>
            <s:element maxOccurs="1" minOccurs="0" name="savePuntuacionResult" type="s:string"/>
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="addLogro">
        <s:complexType>
          <s:sequence>
            <s:element maxOccurs="1" minOccurs="0" name="cFacebookString" type="s:string"/>
            <s:element maxOccurs="1" minOccurs="0" name="nIdSesion" type="s:string"/>
            <s:element maxOccurs="1" minOccurs="0" name="cEvento" type="s:string"/>
            <s:element maxOccurs="1" minOccurs="0" name="cLogro" type="s:string"/>
            <s:element maxOccurs="1" minOccurs="0" name="cUserCheck" type="s:string"/>
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="addLogroResponse">
        <s:complexType>
          <s:sequence>
            <s:element maxOccurs="1" minOccurs="0" name="addLogroResult" type="s:string"/>
          </s:sequence>
        </s:complexType>
      </s:element>
      <s:element name="string" nillable="true" type="s:string"/>
      <s:element name="ArrayOfUserData" nillable="true" type="tns:ArrayOfUserData"/>
    </s:schema>
  </wsdl:types>
  <wsdl:message name="getUsuarioHttpPostIn">
    <wsdl:part name="cFacebookString" type="s:string">
    </wsdl:part>
    <wsdl:part name="nIdSesion" type="s:string">
    </wsdl:part>
    <wsdl:part name="cUserCheck" type="s:string">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="sessionStartSoapIn">
    <wsdl:part element="tns:sessionStart" name="parameters">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="sessionStartHttpPostIn">
    <wsdl:part name="cFacebookString" type="s:string">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="getCheckerHttpPostIn">
  </wsdl:message>
  <wsdl:message name="sessionStartNewSoapOut">
    <wsdl:part element="tns:sessionStartNewResponse" name="parameters">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="getHOFHttpPostIn">
  </wsdl:message>
  <wsdl:message name="saveUsuarioSoapOut">
    <wsdl:part element="tns:saveUsuarioResponse" name="parameters">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="getUsuarioSoapIn">
    <wsdl:part element="tns:getUsuario" name="parameters">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="addLogroHttpPostOut">
    <wsdl:part element="tns:string" name="Body">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="getCheckerHttpPostOut">
    <wsdl:part element="tns:string" name="Body">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="getHOFSoapIn">
    <wsdl:part element="tns:getHOF" name="parameters">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="keepAliveSoapOut">
    <wsdl:part element="tns:keepAliveResponse" name="parameters">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="savePuntuacionHttpPostOut">
    <wsdl:part element="tns:string" name="Body">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="keepAliveHttpPostOut">
    <wsdl:part element="tns:string" name="Body">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="getUsuarioSoapOut">
    <wsdl:part element="tns:getUsuarioResponse" name="parameters">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="saveUsuarioSoapIn">
    <wsdl:part element="tns:saveUsuario" name="parameters">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="savePuntuacionSoapIn">
    <wsdl:part element="tns:savePuntuacion" name="parameters">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="getHOFSoapOut">
    <wsdl:part element="tns:getHOFResponse" name="parameters">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="sessionStartSoapOut">
    <wsdl:part element="tns:sessionStartResponse" name="parameters">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="addLogroSoapIn">
    <wsdl:part element="tns:addLogro" name="parameters">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="savePuntuacionSoapOut">
    <wsdl:part element="tns:savePuntuacionResponse" name="parameters">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="keepAliveHttpPostIn">
    <wsdl:part name="cFacebookString" type="s:string">
    </wsdl:part>
    <wsdl:part name="nIdSesion" type="s:string">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="getUsuarioHttpPostOut">
    <wsdl:part element="tns:string" name="Body">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="sessionStartNewHttpPostOut">
    <wsdl:part element="tns:string" name="Body">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="sessionStartNewHttpPostIn">
    <wsdl:part name="cFacebookString" type="s:string">
    </wsdl:part>
    <wsdl:part name="cSessionID" type="s:string">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="saveUsuarioHttpPostIn">
    <wsdl:part name="cFacebookString" type="s:string">
    </wsdl:part>
    <wsdl:part name="nIdSesion" type="s:string">
    </wsdl:part>
    <wsdl:part name="cxmlProperties" type="s:string">
    </wsdl:part>
    <wsdl:part name="cUserCheck" type="s:string">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="sessionStartNewSoapIn">
    <wsdl:part element="tns:sessionStartNew" name="parameters">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="keepAliveSoapIn">
    <wsdl:part element="tns:keepAlive" name="parameters">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="sessionStartHttpPostOut">
    <wsdl:part element="tns:string" name="Body">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="getCheckerSoapIn">
    <wsdl:part element="tns:getChecker" name="parameters">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="getHOFHttpPostOut">
    <wsdl:part element="tns:ArrayOfUserData" name="Body">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="addLogroHttpPostIn">
    <wsdl:part name="cFacebookString" type="s:string">
    </wsdl:part>
    <wsdl:part name="nIdSesion" type="s:string">
    </wsdl:part>
    <wsdl:part name="cEvento" type="s:string">
    </wsdl:part>
    <wsdl:part name="cLogro" type="s:string">
    </wsdl:part>
    <wsdl:part name="cUserCheck" type="s:string">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="addLogroSoapOut">
    <wsdl:part element="tns:addLogroResponse" name="parameters">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="getCheckerSoapOut">
    <wsdl:part element="tns:getCheckerResponse" name="parameters">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="savePuntuacionHttpPostIn">
    <wsdl:part name="cFacebookString" type="s:string">
    </wsdl:part>
    <wsdl:part name="nIdSesion" type="s:string">
    </wsdl:part>
    <wsdl:part name="cEvento" type="s:string">
    </wsdl:part>
    <wsdl:part name="nPuntuacion" type="s:string">
    </wsdl:part>
    <wsdl:part name="cUserCheck" type="s:string">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="saveUsuarioHttpPostOut">
    <wsdl:part element="tns:string" name="Body">
    </wsdl:part>
  </wsdl:message>
  <wsdl:portType name="MainServiceSoap">
    <wsdl:operation name="sessionStart">
      <wsdl:input message="tns:sessionStartSoapIn">
    </wsdl:input>
      <wsdl:output message="tns:sessionStartSoapOut">
    </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="sessionStartNew">
      <wsdl:input message="tns:sessionStartNewSoapIn">
    </wsdl:input>
      <wsdl:output message="tns:sessionStartNewSoapOut">
    </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="keepAlive">
      <wsdl:input message="tns:keepAliveSoapIn">
    </wsdl:input>
      <wsdl:output message="tns:keepAliveSoapOut">
    </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="getChecker">
      <wsdl:input message="tns:getCheckerSoapIn">
    </wsdl:input>
      <wsdl:output message="tns:getCheckerSoapOut">
    </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="getHOF">
      <wsdl:input message="tns:getHOFSoapIn">
    </wsdl:input>
      <wsdl:output message="tns:getHOFSoapOut">
    </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="getUsuario">
      <wsdl:input message="tns:getUsuarioSoapIn">
    </wsdl:input>
      <wsdl:output message="tns:getUsuarioSoapOut">
    </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="saveUsuario">
      <wsdl:input message="tns:saveUsuarioSoapIn">
    </wsdl:input>
      <wsdl:output message="tns:saveUsuarioSoapOut">
    </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="savePuntuacion">
      <wsdl:input message="tns:savePuntuacionSoapIn">
    </wsdl:input>
      <wsdl:output message="tns:savePuntuacionSoapOut">
    </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="addLogro">
      <wsdl:input message="tns:addLogroSoapIn">
    </wsdl:input>
      <wsdl:output message="tns:addLogroSoapOut">
    </wsdl:output>
    </wsdl:operation>
  </wsdl:portType>
  <wsdl:portType name="MainServiceHttpPost">
    <wsdl:operation name="sessionStart">
      <wsdl:input message="tns:sessionStartHttpPostIn">
    </wsdl:input>
      <wsdl:output message="tns:sessionStartHttpPostOut">
    </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="sessionStartNew">
      <wsdl:input message="tns:sessionStartNewHttpPostIn">
    </wsdl:input>
      <wsdl:output message="tns:sessionStartNewHttpPostOut">
    </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="keepAlive">
      <wsdl:input message="tns:keepAliveHttpPostIn">
    </wsdl:input>
      <wsdl:output message="tns:keepAliveHttpPostOut">
    </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="getChecker">
      <wsdl:input message="tns:getCheckerHttpPostIn">
    </wsdl:input>
      <wsdl:output message="tns:getCheckerHttpPostOut">
    </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="getHOF">
      <wsdl:input message="tns:getHOFHttpPostIn">
    </wsdl:input>
      <wsdl:output message="tns:getHOFHttpPostOut">
    </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="getUsuario">
      <wsdl:input message="tns:getUsuarioHttpPostIn">
    </wsdl:input>
      <wsdl:output message="tns:getUsuarioHttpPostOut">
    </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="saveUsuario">
      <wsdl:input message="tns:saveUsuarioHttpPostIn">
    </wsdl:input>
      <wsdl:output message="tns:saveUsuarioHttpPostOut">
    </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="savePuntuacion">
      <wsdl:input message="tns:savePuntuacionHttpPostIn">
    </wsdl:input>
      <wsdl:output message="tns:savePuntuacionHttpPostOut">
    </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="addLogro">
      <wsdl:input message="tns:addLogroHttpPostIn">
    </wsdl:input>
      <wsdl:output message="tns:addLogroHttpPostOut">
    </wsdl:output>
    </wsdl:operation>
  </wsdl:portType>
  <wsdl:binding name="MainServiceSoap" type="tns:MainServiceSoap">
    <soap:binding transport="http://schemas.xmlsoap.org/soap/http"/>
    <wsdl:operation name="sessionStart">
      <soap:operation soapAction="http://tempuri.org/sessionStart" style="document"/>
      <wsdl:input>
        <soap:body use="literal"/>
      </wsdl:input>
      <wsdl:output>
        <soap:body use="literal"/>
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="sessionStartNew">
      <soap:operation soapAction="http://tempuri.org/sessionStartNew" style="document"/>
      <wsdl:input>
        <soap:body use="literal"/>
      </wsdl:input>
      <wsdl:output>
        <soap:body use="literal"/>
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="keepAlive">
      <soap:operation soapAction="http://tempuri.org/keepAlive" style="document"/>
      <wsdl:input>
        <soap:body use="literal"/>
      </wsdl:input>
      <wsdl:output>
        <soap:body use="literal"/>
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="getChecker">
      <soap:operation soapAction="http://tempuri.org/getChecker" style="document"/>
      <wsdl:input>
        <soap:body use="literal"/>
      </wsdl:input>
      <wsdl:output>
        <soap:body use="literal"/>
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="getHOF">
      <soap:operation soapAction="http://tempuri.org/getHOF" style="document"/>
      <wsdl:input>
        <soap:body use="literal"/>
      </wsdl:input>
      <wsdl:output>
        <soap:body use="literal"/>
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="getUsuario">
      <soap:operation soapAction="http://tempuri.org/getUsuario" style="document"/>
      <wsdl:input>
        <soap:body use="literal"/>
      </wsdl:input>
      <wsdl:output>
        <soap:body use="literal"/>
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="saveUsuario">
      <soap:operation soapAction="http://tempuri.org/saveUsuario" style="document"/>
      <wsdl:input>
        <soap:body use="literal"/>
      </wsdl:input>
      <wsdl:output>
        <soap:body use="literal"/>
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="savePuntuacion">
      <soap:operation soapAction="http://tempuri.org/savePuntuacion" style="document"/>
      <wsdl:input>
        <soap:body use="literal"/>
      </wsdl:input>
      <wsdl:output>
        <soap:body use="literal"/>
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="addLogro">
      <soap:operation soapAction="http://tempuri.org/addLogro" style="document"/>
      <wsdl:input>
        <soap:body use="literal"/>
      </wsdl:input>
      <wsdl:output>
        <soap:body use="literal"/>
      </wsdl:output>
    </wsdl:operation>
  </wsdl:binding>
  <wsdl:binding name="MainServiceSoap12" type="tns:MainServiceSoap">
    <soap12:binding transport="http://schemas.xmlsoap.org/soap/http"/>
    <wsdl:operation name="sessionStart">
      <soap12:operation soapAction="http://tempuri.org/sessionStart" style="document"/>
      <wsdl:input>
        <soap12:body use="literal"/>
      </wsdl:input>
      <wsdl:output>
        <soap12:body use="literal"/>
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="sessionStartNew">
      <soap12:operation soapAction="http://tempuri.org/sessionStartNew" style="document"/>
      <wsdl:input>
        <soap12:body use="literal"/>
      </wsdl:input>
      <wsdl:output>
        <soap12:body use="literal"/>
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="keepAlive">
      <soap12:operation soapAction="http://tempuri.org/keepAlive" style="document"/>
      <wsdl:input>
        <soap12:body use="literal"/>
      </wsdl:input>
      <wsdl:output>
        <soap12:body use="literal"/>
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="getChecker">
      <soap12:operation soapAction="http://tempuri.org/getChecker" style="document"/>
      <wsdl:input>
        <soap12:body use="literal"/>
      </wsdl:input>
      <wsdl:output>
        <soap12:body use="literal"/>
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="getHOF">
      <soap12:operation soapAction="http://tempuri.org/getHOF" style="document"/>
      <wsdl:input>
        <soap12:body use="literal"/>
      </wsdl:input>
      <wsdl:output>
        <soap12:body use="literal"/>
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="getUsuario">
      <soap12:operation soapAction="http://tempuri.org/getUsuario" style="document"/>
      <wsdl:input>
        <soap12:body use="literal"/>
      </wsdl:input>
      <wsdl:output>
        <soap12:body use="literal"/>
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="saveUsuario">
      <soap12:operation soapAction="http://tempuri.org/saveUsuario" style="document"/>
      <wsdl:input>
        <soap12:body use="literal"/>
      </wsdl:input>
      <wsdl:output>
        <soap12:body use="literal"/>
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="savePuntuacion">
      <soap12:operation soapAction="http://tempuri.org/savePuntuacion" style="document"/>
      <wsdl:input>
        <soap12:body use="literal"/>
      </wsdl:input>
      <wsdl:output>
        <soap12:body use="literal"/>
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="addLogro">
      <soap12:operation soapAction="http://tempuri.org/addLogro" style="document"/>
      <wsdl:input>
        <soap12:body use="literal"/>
      </wsdl:input>
      <wsdl:output>
        <soap12:body use="literal"/>
      </wsdl:output>
    </wsdl:operation>
  </wsdl:binding>
  <wsdl:binding name="MainServiceHttpPost" type="tns:MainServiceHttpPost">
    <http:binding verb="POST"/>
    <wsdl:operation name="sessionStart">
      <http:operation location="/sessionStart"/>
      <wsdl:input>
        <mime:content type="application/x-www-form-urlencoded"/>
      </wsdl:input>
      <wsdl:output>
        <mime:mimeXml part="Body"/>
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="sessionStartNew">
      <http:operation location="/sessionStartNew"/>
      <wsdl:input>
        <mime:content type="application/x-www-form-urlencoded"/>
      </wsdl:input>
      <wsdl:output>
        <mime:mimeXml part="Body"/>
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="keepAlive">
      <http:operation location="/keepAlive"/>
      <wsdl:input>
        <mime:content type="application/x-www-form-urlencoded"/>
      </wsdl:input>
      <wsdl:output>
        <mime:mimeXml part="Body"/>
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="getChecker">
      <http:operation location="/getChecker"/>
      <wsdl:input>
        <mime:content type="application/x-www-form-urlencoded"/>
      </wsdl:input>
      <wsdl:output>
        <mime:mimeXml part="Body"/>
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="getHOF">
      <http:operation location="/getHOF"/>
      <wsdl:input>
        <mime:content type="application/x-www-form-urlencoded"/>
      </wsdl:input>
      <wsdl:output>
        <mime:mimeXml part="Body"/>
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="getUsuario">
      <http:operation location="/getUsuario"/>
      <wsdl:input>
        <mime:content type="application/x-www-form-urlencoded"/>
      </wsdl:input>
      <wsdl:output>
        <mime:mimeXml part="Body"/>
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="saveUsuario">
      <http:operation location="/saveUsuario"/>
      <wsdl:input>
        <mime:content type="application/x-www-form-urlencoded"/>
      </wsdl:input>
      <wsdl:output>
        <mime:mimeXml part="Body"/>
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="savePuntuacion">
      <http:operation location="/savePuntuacion"/>
      <wsdl:input>
        <mime:content type="application/x-www-form-urlencoded"/>
      </wsdl:input>
      <wsdl:output>
        <mime:mimeXml part="Body"/>
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="addLogro">
      <http:operation location="/addLogro"/>
      <wsdl:input>
        <mime:content type="application/x-www-form-urlencoded"/>
      </wsdl:input>
      <wsdl:output>
        <mime:mimeXml part="Body"/>
      </wsdl:output>
    </wsdl:operation>
  </wsdl:binding>
  <wsdl:service name="MainService">
    <wsdl:port binding="tns:MainServiceHttpPost" name="MainServiceHttpPost">
      <http:address location="http://www.desafiate.es/services/MainService.asmx"/>
    </wsdl:port>
    <wsdl:port binding="tns:MainServiceSoap12" name="MainServiceSoap12">
      <soap12:address location="http://www.desafiate.es/services/MainService.asmx"/>
    </wsdl:port>
    <wsdl:port binding="tns:MainServiceSoap" name="MainServiceSoap">
      <soap:address location="http://www.desafiate.es/services/MainService.asmx"/>
    </wsdl:port>
  </wsdl:service>
</wsdl:definitions>
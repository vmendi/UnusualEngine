<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="NotLoggedInFacebook.aspx.cs" Inherits="SoccerServerV1.NotLoggedInFacebook" %>
<%@ Register TagPrefix="FBWeb" Namespace="Facebook.Web" Assembly="Facebook.Web" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <div>Hacer login autoriza la app automaticamente. Esto no se renderiza por usar un CanvasIFrameLoginControl</div>
    <div>Aqui podria ir una demo en vez del CanvasIFrameLoginControl...</div>
    <div>El CanvasIFrameLoginControl sabe seleccionar si es un login o una autorizacion lo que hace falta</div>

    <FBWeb:CanvasIFrameLoginControl runat="server" ID="login"  RequireLogin="true"/>
</body>
</html>

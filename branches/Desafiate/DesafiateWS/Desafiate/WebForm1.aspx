<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebForm1.aspx.cs" Inherits="Desafiate.WebForm1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title></title>
    <style type="text/css">
        body 
        {
            font-family: Verdana, Arial, Helvetica;
            font-size: 12px;
        }
        h2 
        {
            border-bottom: 1px solid gray;
            padding: 10px 0;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <h2>Estad&iacute;sticas de uso</h2>
        <asp:GridView ID="stats" runat="server"></asp:GridView>
        <h2>Comprobaciones de coherencia</h2>
        <% Response.Write(getUserCheck()); %>
    </div>
    </form>
</body>
</html>

<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Cheats.aspx.cs" Inherits="Desafiate.Cheats" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <div>
    <!--
        <asp:Label ID="MyLabel01" runat="server" Text=""></asp:Label>
        <br />
        <asp:Label ID="MyLabel02" runat="server" Text=""></asp:Label>
        <br />
    -->
        <asp:Label ID="MyLabel03" runat="server" Text=""></asp:Label>
        <br />
        <br />
        <asp:Table ID="MyTable01" runat="server" BorderStyle="Solid" GridLines="Both" CellPadding="3"></asp:Table>

		<br />
        <br />
		<asp:Label ID="MyLabelInnocents" runat="server" Text=""></asp:Label>
		<br />
        <br />
		<asp:Label ID="MyLabelCheaters" runat="server" Text=""></asp:Label>
		<br />
        <br />
		<asp:Table ID="FinalRanking" runat="server" BorderStyle="Solid" GridLines="Both" CellPadding="3"></asp:Table>
		<asp:Table ID="HofTable" runat="server" BorderStyle="Solid" GridLines="Both" CellPadding="3"></asp:Table>
    </div>
</body>
</html>
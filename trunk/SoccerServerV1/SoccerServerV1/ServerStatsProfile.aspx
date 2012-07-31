<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ServerStatsProfile.aspx.cs" Inherits="SoccerServerV1.ServerStatsProfile" %>
<%@ Register TagPrefix="local" TagName="MatchesControl" Src="~/ServerStatsMatchesControl.ascx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <asp:Label ID="MyPlayerName" runat="server" />
        <br />
        <asp:Label ID="MyTeamName" runat="server" />
        <br />
        <asp:Label ID="MyDateCreated" runat="server" />
        <br />
        <asp:Label ID="MyLiked" runat="server" />
        <br />
        <asp:Label ID="MyNumSessions" runat="server" />
        <br />
        <asp:Label ID="MyTrueSkill" runat="server" />        
        <br />
        <asp:Label ID="MyXP" runat="server" />        
        <br />
        <asp:Label ID="MySkillPoints" runat="server" />        
        <br />
        <asp:Label ID="MyFitness" runat="server" />        
        <br />
        <asp:Label ID="MySpecialTrainings" runat="server" />        
        <br />
        <br />
        
        <local:MatchesControl runat="server" id="MyProfileMatches" />

        <br />
        <br />

        <asp:HyperLink ID="HyperLink1" runat="server" Text="Back to home" NavigateUrl="~/ServerStats.aspx" />
    </form>
</body>
</html>

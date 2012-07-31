<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ServerStats.aspx.cs" Inherits="SoccerServerV1.ServerStats" MaintainScrollPositionOnPostback="true" %> 

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
	<form id="ServerStatsForm" runat="server">
    
		<asp:ScriptManager ID="MyScriptManager" runat="server">		
		</asp:ScriptManager>

		<!-- Para que funcione la conservacion de la posicion de la barra de scroll despues de un post-back -->
		<script type="text/javascript">
			var prm = Sys.WebForms.PageRequestManager.getInstance();
			prm.add_beginRequest(beginRequest);
			function beginRequest() {
				prm._scrollPosition = null;
			}
		</script>

        <asp:Timer ID="MyUpdateTimer" runat="server" Interval="3000" ontick="MyTimer_Tick">
		</asp:Timer>
		
		<asp:UpdatePanel ID="MyUpdatePanel" runat="server" updatemode="Conditional">
			<Triggers>
                <asp:AsyncPostBackTrigger controlid="MyUpdateTimer" eventname="Tick" />
            </Triggers>
			<ContentTemplate>
                <asp:Panel DefaultButton="" runat="server">
				    <asp:Label runat="server" ID="MyNumCurrentMatchesLabel" /><br />
                    <asp:Label runat="server" ID="MyNumPeopleInRooms" /><br />
                    <asp:Label runat="server" ID="MyPeopleLookingForMatch" /><br />
                    <asp:Label runat="server" ID="MyNumConnnectionsLabel" /><br />
                    <asp:Label runat="server" ID="MyMaxConcurrentConnectionsLabel" /><br />
                    <asp:Label runat="server" ID="MyCumulativeConnectionsLabel" /><br />
                    <asp:Label runat="server" ID="MyUpSinceLabel" />
                    <span>&nbsp&nbsp</span><asp:Button ID="MyRunButton" runat="server" Text="Run" onclick="Run_Click"  />
                    <br /><br />
                </asp:Panel>
			</ContentTemplate>
		</asp:UpdatePanel>

        <asp:Panel DefaultButton="MyBroadcastMsgButtton" runat="server">
            <div style="border-style:solid;border-width:1px;padding-left:5px; padding-right:5px;width:390px">
                    <asp:TextBox ID="MyBroadcastMsgTextBox" runat="server" Width="300"/>
                    <asp:Button ID="MyBroadcastMsgButtton" runat="server" Text="Broadcast" onclick="MyBroadcastMsgButtton_Click" />
                    <br /><br />
                    <asp:Label ID="MyCurrentBroadcastMsgLabel" runat="server" />
            </div>
            <br /><br />
        </asp:Panel>
    
        <asp:Label runat="server" id="MyTotalPlayersLabel"></asp:Label><br />
        <asp:Label runat="server" id="MyNumLikesLabel"></asp:Label><br />
		<asp:Label runat="server" id="MyTotalMatchesLabel"></asp:Label><br />   
        <asp:Label runat="server" id="MyTodayMatchesLabel"></asp:Label><br />     
		<asp:Label runat="server" id="MyTooManyTimes"></asp:Label><br />
		<asp:Label runat="server" id="MyNonFinishedMatchesLabel"></asp:Label><br />
		<asp:Label runat="server" id="MyAbandonedMatchesLabel"></asp:Label><br />
		<asp:Label runat="server" id="MyAbandonedSameIPMatchesLabel"></asp:Label><br />
		<asp:Label runat="server" id="MyUnjustMatchesLabel"></asp:Label>

		<br />
		<br />
		<br />		
        <asp:HyperLink ID="HyperLink1" runat="server" Text="Ir a estadísticas de partidos" NavigateUrl="~/ServerStatsGlobalMatches.aspx" />        
        <br />
		<br />

        <!--
        <asp:Button ID="RefreshTrueskillButton" runat="server" Text="Refresh Trueskill" OnClick="RefreshTrueskill_Click" />        
        <asp:HyperLink ID="HyperLink2" runat="server" Text="Ir a ranking" NavigateUrl="~/ServerStatsRanking.aspx" />
        -->
					
	</form>

</body>
</html>
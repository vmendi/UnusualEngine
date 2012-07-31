<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ServerStatsRanking.aspx.cs" Inherits="SoccerServerV1.ServerStatsRanking" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <asp:GridView ID="MyRankingTable" runat="server" AutoGenerateColumns="false" AllowPaging="true" PageSize="10" CellPadding="4" ForeColor="#333333" GridLines="Vertical"
			OnRowCommand="MyRankingTable_OnRowCommand" DataSourceID="MyRankingLinQDataSource" Width="1024" >
			<AlternatingRowStyle BackColor="White" ForeColor="#284775" />
			<EditRowStyle BackColor="#999999" />
			<FooterStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
			<HeaderStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
			<PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Center" />
			<RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
			<SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />

			<Columns>
                <asp:TemplateField HeaderText="Team name" ItemStyle-Width="220px">
                    <ItemTemplate>
						<asp:LinkButton ID="LinkButton1" runat="server" Text='<%# ((SoccerServerV1.BDDModel.Team)Container.DataItem).Name %>'
                            CommandName="ViewProfile" CommandArgument='<%# Eval("TeamID") %>'/>
                    </ItemTemplate>
                </asp:TemplateField>

				<asp:TemplateField HeaderText="Facebook Profile">
                    <ItemTemplate>
						<div style="float:left; margin-right:10px;">
							<asp:HyperLink ID="HyperLink1" runat="server"
							ImageUrl='<%# "http://graph.facebook.com/" + Eval("Player.FacebookID") + "/picture" %>'
							NavigateUrl = '<%# "http://www.facebook.com/profile.php?id=" + Eval("Player.FacebookID") %>' />
						</div>
						<div style="margin-top:15px;">
							<asp:HyperLink ID="HyperLink2" runat="server" Text='<%# GetFacebookUserName((SoccerServerV1.BDDModel.Team)Container.DataItem)%>'
							NavigateUrl = '<%# "http://www.facebook.com/profile.php?id=" + Eval("Player.FacebookID") %>'  />
						</div>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:BoundField HeaderText="TrueSkill" DataField="TrueSkill" ItemStyle-HorizontalAlign="Center"/>
                <asp:BoundField HeaderText="Mean" DataField="Mean" DataFormatString="{0:N2}" ItemStyle-HorizontalAlign="Center"/>
				<asp:BoundField HeaderText="SD" DataField="StandardDeviation" DataFormatString="{0:N2}" ItemStyle-HorizontalAlign="Center"/>

				<asp:TemplateField HeaderText="Total Matches" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="50">
                    <ItemTemplate>
						<asp:Label ID="Label1" runat="server" Text='<%# GetTotalMatchesCount((SoccerServerV1.BDDModel.Team)Container.DataItem) %>' />
                    </ItemTemplate>
                </asp:TemplateField>

				<asp:TemplateField HeaderText="Won Matches" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="50">
					<ItemTemplate>
					<asp:Label ID="Label2" runat="server" Text="<%# GetWonMatchesCount((SoccerServerV1.BDDModel.Team)Container.DataItem) %>" />
					</ItemTemplate>
				</asp:TemplateField>

				<asp:TemplateField HeaderText="Lost Matches" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="50">
					<ItemTemplate>
					<asp:Label ID="Label3" runat="server" Text="<%# GetLostMatchesCount((SoccerServerV1.BDDModel.Team)Container.DataItem) %>" />
					</ItemTemplate>
				</asp:TemplateField>

				<asp:TemplateField HeaderText="Goals Scored" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="50">
					<ItemTemplate>
					<asp:Label ID="Label4" runat="server" Text="<%# GetTotalGoalsScored((SoccerServerV1.BDDModel.Team)Container.DataItem) %>" />
					</ItemTemplate>
				</asp:TemplateField>

				<asp:TemplateField HeaderText="Goals Received" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="50">
					<ItemTemplate>
					<asp:Label ID="Label5" runat="server" Text="<%# GetTotalGoalsReceived((SoccerServerV1.BDDModel.Team)Container.DataItem) %>" />
					</ItemTemplate>
				</asp:TemplateField>
			</Columns>
		</asp:GridView>

        <br />
        <br />
        <br />

        <asp:HyperLink ID="HyperLink1" runat="server" Text="Back to home" NavigateUrl="~/ServerStats.aspx" />

        <asp:LinqDataSource ID="MyRankingLinQDataSource"
			ContextTypeName="SoccerServerV1.SoccerDataModelDataContext" TableName="Teams" 
			runat="server" OrderBy="TrueSkill desc, TeamID asc">
		</asp:LinqDataSource>
    </form>
</body>
</html>

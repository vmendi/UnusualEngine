<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ServerStatsMatchesControl.ascx.cs" Inherits="SoccerServerV1.ServerStatsMatchesControl" %>

<asp:GridView ID="MyMatchGridView" runat="server" AutoGenerateColumns="false" AllowPaging="true" 
    PageSize="10" CellPadding="4" ForeColor="#333333" GridLines="Vertical" Width="1200" OnPageIndexChanging="GridView_PageIndexChanging" >

    <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
	<EditRowStyle BackColor="#999999" />
	<FooterStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
	<HeaderStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
	<PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Center" />
	<RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
    <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />

    <Columns>
		<asp:BoundField HeaderText="MatchID" DataField="MatchID"/>
		<asp:BoundField HeaderText="DateStarted" DataField="DateStarted" ItemStyle-Width="220" ItemStyle-HorizontalAlign='Center' />

		<asp:TemplateField HeaderText="Duration" ItemStyle-Width="40">
			<ItemTemplate>
				<asp:Label ID="Label3" runat="server" Text="<%# GetDurationOfMatch((SoccerServerV1.BDDModel.Match)Container.DataItem) %>" />
			</ItemTemplate>
		</asp:TemplateField>

        <asp:TemplateField HeaderText="Player1" ItemStyle-Width="200">
			<ItemTemplate>
				<asp:HyperLink ID="Label4" runat="server" Text="<%# GetPlayerNameOfMatch((SoccerServerV1.BDDModel.Match)Container.DataItem, 0) %>"
                                                          NavigateUrl="<%# GetProfileLinkOfMatch((SoccerServerV1.BDDModel.Match)Container.DataItem, 0) %>" />
			</ItemTemplate>
		</asp:TemplateField>

		<asp:TemplateField HeaderText="Player2" ItemStyle-Width="200">
			<ItemTemplate>
				<asp:HyperLink ID="Label5" runat="server" Text="<%# GetPlayerNameOfMatch((SoccerServerV1.BDDModel.Match)Container.DataItem, 1) %>"
                                                          NavigateUrl="<%# GetProfileLinkOfMatch((SoccerServerV1.BDDModel.Match)Container.DataItem, 1) %>" />
			</ItemTemplate>
		</asp:TemplateField>

        <asp:TemplateField HeaderText="Goals Player1" ItemStyle-Width="30">
			<ItemTemplate>
				<asp:Label ID="Label4" runat="server" Text="<%# GetGoalsOfMatch((SoccerServerV1.BDDModel.Match)Container.DataItem, 0) %>" />
			</ItemTemplate>
		</asp:TemplateField>

        <asp:TemplateField HeaderText="Goals Player2" ItemStyle-Width="30">
			<ItemTemplate>
				<asp:Label ID="Label4" runat="server" Text="<%# GetGoalsOfMatch((SoccerServerV1.BDDModel.Match)Container.DataItem, 1) %>" />
			</ItemTemplate>
		</asp:TemplateField>

		<asp:BoundField HeaderText="TooManyTimes" DataField="WasTooManyTimes" ItemStyle-HorizontalAlign='Center'/>
		<asp:BoundField HeaderText="Just" DataField="WasJust" ItemStyle-HorizontalAlign='Center'/>
		<asp:BoundField HeaderText="Abandoned" DataField="WasAbandoned" ItemStyle-HorizontalAlign='Center'/>
		<asp:BoundField HeaderText="AbaSameIP" DataField="WasAbandonedSameIP" ItemStyle-HorizontalAlign='Center'/>

	</Columns>
</asp:GridView>
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SoccerServerV1.BDDModel;

namespace SoccerServerV1
{
	public partial class TestCreateSession : System.Web.UI.Page
	{
		protected void Page_Load(object sender, EventArgs e)
		{
			string sessionID = "0";

			if (Request.QueryString.AllKeys.Contains("FakeSessionKey"))
				sessionID = Request.QueryString["FakeSessionKey"];

			using (SoccerDataModelDataContext theContext = new SoccerDataModelDataContext())
			{
				Player player = Default.EnsurePlayerIsCreated(theContext, sessionID, null);
				Default.EnsureSessionIsCreated(theContext, player, sessionID);

				theContext.SubmitChanges();
			}
		}
	}
}
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using SoccerServerV1.BDDModel;
using System.Collections.Specialized;

namespace SoccerServerV1
{
    public partial class TestForm : System.Web.UI.Page
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

            // Lo hacemos en un IFrame para que la recarga sea darle a un boton
            MyFrame.Attributes.Add("src", "SoccerClientV1/SoccerClientV1.html?" + Request.QueryString.ToString());
        }
    }
}
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Weborb.Util.Logging;

namespace SoccerServerV1
{
	public partial class Deauthorize : System.Web.UI.Page
	{
		protected void Page_Load(object sender, EventArgs e)
		{
			Log.log("DEAUTHORIZE", "Deauthorize!");
		}
	}
}
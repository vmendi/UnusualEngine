using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Script.Serialization;
using System.Net;
using System.IO;

namespace SoccerServerV1
{
    public partial class ServerStatsRanking : System.Web.UI.Page
    {
        SoccerDataModelDataContext mDC;

        public ServerStatsRanking()
		{
			mDC = new SoccerDataModelDataContext();
		}

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        public string GetFacebookUserName(BDDModel.Team team)
        {
            return team.Player.Name + " " + team.Player.Surname;
        }

        public string GetFacebookUserNameFromAPI(string facebookID)
        {
            JavaScriptSerializer deserializer = new JavaScriptSerializer();

            WebClient theWebClient = new WebClient();
            Stream theStream = theWebClient.OpenRead("http://graph.facebook.com/" + facebookID);
            StreamReader theReader = new StreamReader(theStream);
            string json = theReader.ReadToEnd();

            var objDeserialized = deserializer.DeserializeObject(json);

            return (objDeserialized as Dictionary<string, object>)["name"] as string;
        }

        public int GetTotalMatchesCount(BDDModel.Team team)
        {
            return (from p in mDC.MatchParticipations
                    where p.TeamID == team.TeamID
                    select p).Count();
        }

        public int GetWonMatchesCount(BDDModel.Team team)
        {
            return (from p in mDC.MatchParticipations
                    where p.TeamID == team.TeamID && p.Goals > p.Match.MatchParticipations.Single(o => o != p).Goals
                    select p).Count();
        }

        public int GetLostMatchesCount(BDDModel.Team team)
        {
            return (from p in mDC.MatchParticipations
                    where p.TeamID == team.TeamID && p.Goals < p.Match.MatchParticipations.Single(o => o != p).Goals
                    select p).Count();
        }

        public int GetTotalGoalsScored(BDDModel.Team team)
        {
            return (from p in mDC.MatchParticipations
                    where p.TeamID == team.TeamID
                    select p.Goals).ToArray().Sum();
        }

        public int GetTotalGoalsReceived(BDDModel.Team team)
        {
            return (from p in mDC.MatchParticipations
                    where p.TeamID == team.TeamID
                    select p.Match.MatchParticipations.Single(o => o != p).Goals).ToArray().Sum();
        }

        public void MyRankingTable_OnRowCommand(Object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ViewProfile")
            {
                Response.Redirect("ServerStatsProfile.aspx?TeamID=" + e.CommandArgument as string);
            }
        }
    }
}
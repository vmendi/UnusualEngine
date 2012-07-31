using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SoccerServerV1
{
    public partial class ServerStatsProfile : System.Web.UI.Page
    {
        private SoccerDataModelDataContext mDC;
        private int mTeamID;
        private BDDModel.Player mPlayer;

        public ServerStatsProfile()
		{
			mDC = new SoccerDataModelDataContext();
		}

        protected void Page_Load(object sender, EventArgs e)
        {
            mTeamID =  int.Parse(Request.QueryString["TeamID"]);
            mPlayer = (from p in mDC.Players where p.Team.TeamID == mTeamID select p).First();

            FillProfile();
        }

        public void FillProfile()
        {
            LinqDataSource matchesForProfileLinQ = new LinqDataSource();
            matchesForProfileLinQ.ContextTypeName = "SoccerServerV1.SoccerDataModelDataContext";
            matchesForProfileLinQ.TableName = "Matches";
            matchesForProfileLinQ.OrderBy = "MatchID desc";
            matchesForProfileLinQ.Where = "MatchParticipations.Any(TeamID == " + mTeamID + ")";
            MyProfileMatches.DataSource = matchesForProfileLinQ;
            
            MyPlayerName.Text = "Player name: " + mPlayer.Name + " " + mPlayer.Surname;
            MyTeamName.Text = "Team Name: " + mPlayer.Team.Name;
            MyDateCreated.Text = "Date created: " + mPlayer.CreationDate.ToString();
            MyLiked.Text = "Liked: " + mPlayer.Liked.ToString();
            MyNumSessions.Text = "Sessions: " + GetNumSessions().ToString();
            MyTrueSkill.Text = "TrueSkill " + GetTrueSkill().ToString();
            MyXP.Text = "XP: " + mPlayer.Team.XP.ToString();
            MySkillPoints.Text = "SkillPoints: " + mPlayer.Team.SkillPoints.ToString();
            MyFitness.Text = "Fitness: " + mPlayer.Team.Fitness.ToString();

            string specialTrainings = "";
            foreach(var training in mPlayer.Team.SpecialTrainings)
            {
                specialTrainings += training.SpecialTrainingDefinition.Name + "/";
            }
            MySpecialTrainings.Text = "SpecialTrainings: " + specialTrainings.TrimEnd('/');
        }

        public int GetNumSessions()
        {
            return (from s in mDC.Sessions
                    where s.Player.PlayerID == mPlayer.PlayerID select s).Count();
        }

        public int GetTrueSkill()
        {
            return (int)(mPlayer.Team.Mean - 3 * mPlayer.Team.StandardDeviation); 
        }

    }
}
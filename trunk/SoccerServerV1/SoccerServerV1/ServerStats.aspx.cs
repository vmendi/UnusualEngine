using System;
using System.Linq;

using Weborb.Messaging;
using Weborb.Messaging.Server;
using Weborb.Messaging.Api;
using SoccerServerV1.NetEngine;
using SoccerServerV1.BDDModel;

namespace SoccerServerV1
{
	public partial class ServerStats : System.Web.UI.Page
	{
		SoccerDataModelDataContext mDC;

		public ServerStats()
		{
			mDC = new SoccerDataModelDataContext();
		}

		protected void Page_Load(object sender, EventArgs e)
		{
			if (!IsPostBack)
			{
				UpdateRealtimeData();

                MyTotalPlayersLabel.Text = "Total players: " + GetTotalPlayers();
                MyNumLikesLabel.Text = "Num likes: " + GetNumLikes();
				MyTotalMatchesLabel.Text = "Total played matches: " + GetTotalPlayedMatches();
                MyTodayMatchesLabel.Text = "Matches today: " + GetMatchesForToday();
				MyTooManyTimes.Text = "Total too many times matches: " + GetTooManyTimes();
				MyNonFinishedMatchesLabel.Text = "Total non-ended matches: " + GetNonEndedMatchesCount();
				MyAbandonedMatchesLabel.Text = "Abandoned matches: " + GetAbandonedMatchesCount();
				MyAbandonedSameIPMatchesLabel.Text = "Same IP abandoned matches: " + GetSameIPAbandondedMatchesCount();
                MyUnjustMatchesLabel.Text = "Unjust matches: " + GetUnjustMatchesCount();
			}
		}


        private int GetTotalPlayers()
        {
            return (from p in mDC.Players
                    select p).Count();
        }

        private int GetNumLikes()
        {
            return (from p in mDC.Players
                    where p.Liked
                    select p).Count();
        }


        public int GetMatchesForToday()
        {
            return (from p in mDC.Matches
                    where p.DateStarted.Date == DateTime.Today.Date
                    select p).Count();
        }


		public int GetTooManyTimes()
		{
			var ret = (from m in mDC.Matches
					   where m.WasTooManyTimes.Value
					   select m).Count();
			return ret;
		}

		public int GetUnjustMatchesCount()
		{
			var ret = (from m in mDC.Matches
					   where !m.WasJust.Value
					   select m).Count();
			return ret;
		}

		public int GetNonEndedMatchesCount()
		{
			var ret = (from m in mDC.Matches
					   where m.DateEnded == null
					   select m).Count();
			return ret;
		}

		public int GetTotalPlayedMatches()
		{
			var ret = (from m in mDC.Matches
					   select m).Count();
			return ret;
		}

		public int GetAbandonedMatchesCount()
		{
			var ret = (from m in mDC.Matches
					   where m.WasAbandoned.Value
					   select m).Count();
			return ret;
		}

		public int GetSameIPAbandondedMatchesCount()
		{
			var ret = (from m in mDC.Matches
					   where m.WasAbandonedSameIP.Value
					   select m).Count();
			return ret;
		}

		protected void MyTimer_Tick(object sender, EventArgs e)
		{
            UpdateRealtimeData();
		}

        protected void Run_Click(object sender, EventArgs e)
        {
            NetEngineMain netEngineMain = (NetEngineMain)Application["NetEngineMain"];

            if (!netEngineMain.NetServer.IsRunning)
            {
                netEngineMain.Start();
            }
            else
            {
                netEngineMain.Stop();
            }

            UpdateRealtimeData();
        }

        protected void RefreshTrueskill_Click(object sender, EventArgs e)
        {
            foreach (Team theTeam in mDC.Teams)
            {
                var rating = new Moserware.Skills.Rating(theTeam.Mean, theTeam.StandardDeviation);
                theTeam.TrueSkill = (int)(TrueSkillHelper.MyConservative(rating) * TrueSkillHelper.MULTIPLIER);
            }

            mDC.SubmitChanges();
        }

        private void UpdateRealtimeData()
		{
            NetEngineMain netEngineMain = Application["NetEngineMain"] as NetEngineMain;

            if (netEngineMain.NetServer.IsRunning)
            {
                Realtime theMainRealtime = netEngineMain.NetServer.NetClientApp as Realtime;
                MyNumCurrentMatchesLabel.Text = "Currently in play matches: " + theMainRealtime.GetNumMatches().ToString();
                MyNumPeopleInRooms.Text = "People in rooms: " + theMainRealtime.GetNumTotalPeopleInRooms().ToString();
                MyPeopleLookingForMatch.Text = "People looking for match: " + theMainRealtime.GetPeopleLookingForMatch().ToString();
                MyNumConnnectionsLabel.Text = "Current connections: " + netEngineMain.NetServer.NumCurrentSockets.ToString();
                MyCumulativeConnectionsLabel.Text = "Cumulative connections: " + netEngineMain.NetServer.NumCumulativePlugs.ToString();
                MyMaxConcurrentConnectionsLabel.Text = "Max Concurrent connections: " + netEngineMain.NetServer.NumMaxConcurrentSockets.ToString();
                MyUpSinceLabel.Text = "Up since: " + netEngineMain.NetServer.LastStartTime.ToString();
                MyRunButton.Text = "Stop";
                MyCurrentBroadcastMsgLabel.Text = "Current msg: " + theMainRealtime.GetBroadcastMsg(null);
            }
            else
            {
                MyNumCurrentMatchesLabel.Text = "Not running";
                MyNumPeopleInRooms.Text = "Not running";
                MyPeopleLookingForMatch.Text = "Not running";
                MyNumConnnectionsLabel.Text = "Not running";
                MyCumulativeConnectionsLabel.Text = "Not running";
                MyMaxConcurrentConnectionsLabel.Text = "Not running";
                MyUpSinceLabel.Text = "Up since: " + netEngineMain.NetServer.LastStartTime.ToString();
                MyRunButton.Text = "Run";
                MyCurrentBroadcastMsgLabel.Text = "Not running";
            }
		}

        protected void MyBroadcastMsgButtton_Click(object sender, EventArgs e)
        {
            NetEngineMain netEngineMain = Application["NetEngineMain"] as NetEngineMain;

            if (netEngineMain.NetServer.IsRunning)
            {
                Realtime theMainRealtime = netEngineMain.NetServer.NetClientApp as Realtime;
                theMainRealtime.SetBroadcastMsg(MyBroadcastMsgTextBox.Text);

                UpdateRealtimeData();
            }
        }
	}
}
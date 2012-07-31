using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;


namespace SoccerServerV1
{
    public partial class ServerStatsDaily : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string csvString = GenerateCSV(GenerateStats());
            
            Response.Clear();
            Response.AddHeader("Content-Disposition", "attachment; filename=" + "dailyStats.csv");
            Response.AddHeader("Content-Length", csvString.Length.ToString());
            Response.ContentType = "application/octet-stream";
            Response.Write(csvString);
            Response.End();
        }

        string GenerateCSV(List<List<float>> stats)
        {
            string ret = "";
            for (int matchesIdx = 0; matchesIdx < stats[0].Count; ++matchesIdx)
            {
                for (int dayIdx = 0; dayIdx < stats.Count; ++dayIdx)
                {
                    if (dayIdx == 0)
                        ret += stats[dayIdx][matchesIdx].ToString("F") + "%";
                    else
                        ret += "," + stats[dayIdx][matchesIdx].ToString("F") + "%";
                }
                ret += "\n";
            }
            return ret;
        }

        List<List<float>> GenerateStats()
        {
            SoccerDataModelDataContext dc = new SoccerDataModelDataContext();

            List<List<float>> stats = new List<List<float>>();

            for (int c = 0; c < 11; c++)
            {
                var innerList = new List<float>();

                for (int d = 0; d < 12; d++)
                    innerList.Add(0);

                stats.Add(innerList);
            }

            foreach (var player in dc.Players)
            {
                var creationDate = player.CreationDate.Date;

                for (int dayIdx = 0; dayIdx < 11; ++dayIdx)
                {
                    var currentDate = creationDate.AddDays(dayIdx);

                    // Número de partidos que se echó el día N
                    int matchesCount = 0;

                    if (dayIdx < 10)
                    {
                        matchesCount = (from m in dc.MatchParticipations
                                        where m.Team.Player.PlayerID == player.PlayerID &&
                                              m.Match.DateStarted.Date == currentDate
                                        select m).Count();
                    }
                    else
                    {
                        matchesCount = (from m in dc.MatchParticipations
                                        where m.Team.Player.PlayerID == player.PlayerID &&
                                              m.Match.DateStarted.Date >= currentDate
                                        select m).Count();
                    }

                    if (matchesCount <= 10)
                        stats[dayIdx][matchesCount]++;
                    else
                        stats[dayIdx][11]++;
                }
            }

            // Pasamos a %
            int numPlayers = dc.Players.Count();

            if (numPlayers != 0)
            {
                for (int c = 0; c < 11; c++)
                {
                    for (int d = 0; d < 12; d++)
                    {
                        stats[c][d] = 100 * stats[c][d] / numPlayers;
                    }
                }
            }

            return stats;
        }

    }
}
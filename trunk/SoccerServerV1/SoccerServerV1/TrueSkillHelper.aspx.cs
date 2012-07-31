using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Moserware.Skills;

namespace SoccerServerV1
{
    public partial class TrueSkillHelper : System.Web.UI.Page
    {
        //
        // http://dl.dropbox.com/u/1083108/Moserware/Skill/The%20Math%20Behind%20TrueSkill.pdf
        //
        static double INITIAL_MEAN = 25.0;
        static double INITIAL_SD = INITIAL_MEAN / 3;
        static double BETA = 10;                             // Distancia entre los 80%-20% (en cadena)
        static double DYNAMIC_FACTOR = INITIAL_MEAN / 100;   // Volatilidad de subida / bajada
        static double DRAW = 0.3;
        static double CONSERVATIVE_FACTOR = 3;

        public static double CUTOFF = 20;                           // Valor a partir del cual no queremos considerar el partido matchmakingable
        public static double MULTIPLIER = 100;                      // Para mostrarlo al usuario, multiplicamos el MyConservative

        protected void Page_Load(object sender, EventArgs e)
        {
            Rating ratingPlayer1 = new Rating(INITIAL_MEAN, INITIAL_SD);
            Rating ratingPlayer2 = new Rating(INITIAL_MEAN, INITIAL_SD);

            Rating reservePlayer = new Rating(INITIAL_MEAN, INITIAL_SD);

            Printa(ratingPlayer1, ratingPlayer2);

            /*
            for (int c = 0; c < 100; c++)
            {
                ratingPlayer2 = reservePlayer;

                for (int d = 0; d < 100; d++)
                {
                    if (IsJustResult(ratingPlayer1, ratingPlayer2, 1, 0))
                    {
                        RecomputeRatings(ref ratingPlayer1, ref ratingPlayer2, 1, 0);
                        Printa(ratingPlayer1, ratingPlayer2);
                    }
                    else
                    {
                        reservePlayer = new Rating(ratingPlayer1.Mean, ratingPlayer1.StandardDeviation);
                        d = 100; c = 100;
                    }
                }
            }

            //ratingPlayer2 = reservePlayer;

            for (int c = 0; c < 100; c++)
            {
                RecomputeRatings(ref ratingPlayer1, ref ratingPlayer2, 0, 1);
                Printa(ratingPlayer1, ratingPlayer2);
            }
             * */

            for (int c = 0; c < 10; c++)
            {
                for (int d = 0; d < 10; d++)
                {
                    if (!IsJustResult(ratingPlayer1, ratingPlayer2, 1, 0))
                        break;

                    RecomputeRatings(ref ratingPlayer1, ref ratingPlayer2, 1, 0);
                    Printa(ratingPlayer1, ratingPlayer2);
                }
                
                Rating swap = ratingPlayer1;
                ratingPlayer1 = ratingPlayer2;
                ratingPlayer2 = swap;
            }
        }

        private void Printa(Rating ratingPlayer1, Rating ratingPlayer2)
        {
            Response.Write(ratingPlayer1.ToString() + "<br/>");
            Response.Write(ratingPlayer2.ToString() + "<br/>");

            Response.Write(Math.Round(MyConservative(ratingPlayer1)).ToString() + "<br/>");
            Response.Write(Math.Round(MyConservative(ratingPlayer2)).ToString() + "<br/>");

            Response.Write("---------------------------------<br/>");
        }

        static public bool IsJustResult(Rating ratingPlayer1, Rating ratingPlayer2, int goalsPlayer1, int goalsPlayer2)
        {
            bool bRet = true;

            if (goalsPlayer1 > goalsPlayer2)
            {
                if (MyConservative(ratingPlayer1) - MyConservative(ratingPlayer2) > CUTOFF)
                    bRet = false;
            }
            else
            if (goalsPlayer1 < goalsPlayer2)
            {
                if (MyConservative(ratingPlayer2) - MyConservative(ratingPlayer1) > CUTOFF)
                    bRet = false;
            }

            return bRet;
        }

        static public double MyConservative(Rating player)
        {
            return player.Mean - (CONSERVATIVE_FACTOR * player.StandardDeviation);
        }

        static public void RecomputeRatings(ref Rating ratingPlayer1, ref Rating ratingPlayer2, int goalsPlayer1, int goalsPlayer2)
        {
            var calculator = new Moserware.Skills.TrueSkill.TwoPlayerTrueSkillCalculator();

            var player1 = new Moserware.Skills.Player(1);
            var player2 = new Moserware.Skills.Player(2);

            var team1 = new Moserware.Skills.Team(player1, ratingPlayer1);
            var team2 = new Moserware.Skills.Team(player2, ratingPlayer2);

            var gameInfo = new Moserware.Skills.GameInfo(INITIAL_MEAN, INITIAL_SD, BETA, DYNAMIC_FACTOR, DRAW);

            int rankingPlayer1 = 1;
            int rankingPlayer2 = 1;

            if (goalsPlayer1 > goalsPlayer2)
            {
                rankingPlayer1 = 1;
                rankingPlayer2 = 2;
            }
            else if (goalsPlayer1 < goalsPlayer2)
            {
                rankingPlayer1 = 2;
                rankingPlayer2 = 1;
            }

            var newRatings = calculator.CalculateNewRatings(gameInfo, Moserware.Skills.Teams.Concat(team1, team2), rankingPlayer1, rankingPlayer2);

            ratingPlayer1 = newRatings[player1];
            ratingPlayer2 = newRatings[player2];

            if (MyConservative(ratingPlayer1) < 0)
                ratingPlayer1 = new Rating(ratingPlayer1.StandardDeviation * CONSERVATIVE_FACTOR, ratingPlayer1.StandardDeviation);

            if (MyConservative(ratingPlayer2) < 0)
                ratingPlayer2 = new Rating(ratingPlayer2.StandardDeviation * CONSERVATIVE_FACTOR, ratingPlayer2.StandardDeviation);
        }
    }
}
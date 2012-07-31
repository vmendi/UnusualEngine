using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Diagnostics;

namespace Desafiate
{
    public partial class Cheats : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
                return;

            mContext = new DesafiateDataContext();
            
            mHof = (from u in mContext.Usuarios
                    let maxPunt = (from p in u.Puntuaciones select p.nPuntuacion).Max()
                    orderby maxPunt descending
                    select u).Take(100).ToList();
            
            CheckMaxScores();
            CheckSumaPuntuaciones();
            CheckFlagUsers();
            CheckFlagPuntuaciones();

            DiscardInnocents();
            PrintCheaters();
			PrintFinalRanking();
			PrintHof();
        }

        private void CheckMaxScores()
        {
            foreach (Usuarios user in mHof)
            {
                foreach (Puntuaciones punt in user.Puntuaciones)
                {
                    if (punt.cEvento == "MiniGameEndedGeekQuiz" && punt.nPuntuacion > 1000)
                        AddReasonToCheater(user, " GeekQuiz > 1000 puntos");

                    if (punt.cEvento == "MiniGameEndedGuessPassword" && punt.nPuntuacion > 1000)
                        AddReasonToCheater(user, " GuessPassword > 1000 puntos");

                    if (punt.cEvento == "MiniGameEndedPowerShellBug" && punt.nPuntuacion > 1000)
                        AddReasonToCheater(user, " PowerShellBug > 1000 puntos");

                    if (punt.cEvento == "MiniGameEndedGuessPassword2" && punt.nPuntuacion > 1000)
                        AddReasonToCheater(user, " GuessPassword2 > 1000 puntos");

                    if (punt.cEvento == "MiniGameEndedSilverFlash" && punt.nPuntuacion > 800)
                        AddReasonToCheater(user, " Silverlight > 800 puntos");

                    if (punt.cEvento == "MiniGameEndedVendingMachine" && punt.nPuntuacion > 1000)
                        AddReasonToCheater(user, " VendingMachine > 1000 puntos");

                    if (punt.cEvento == "MiniGameEndedSuenoDelGeek" && punt.nPuntuacion > 3600)
                        AddReasonToCheater(user, " SuenoDelGeek > 3600 puntos");

					if (punt.cEvento.Contains("TM") && punt.nPuntuacion > 90000)
						AddReasonToCheater(user, " Puntuacion en un Time Management > 90000 puntos");
                }
            }
        }

        private void CheckFlagPuntuaciones()
        {
            foreach (Usuarios user in mHof)
            {
                var flageadas = from flageada in user.Puntuaciones
                                where flageada.nFlag == 1
                                select flageada;

                for (int c = 0; c < flageadas.Count(); c++)
                    AddReasonToCheater(user, " puntuaciones enviadas manualmente");
            }
        }

        private void CheckFlagUsers()
        {
            foreach (Usuarios user in mHof)
            {
                if (user.nFlag == 1)
                    AddReasonToCheater(user, " operacion de sesión hecha manualmente");
            }
        }

        private void DiscardInnocents()
        {
			List<int> mInnocents = new List<int>();
			mInnocents.Add(1307);
			mInnocents.Add(4552);
			mInnocents.Add(6058);
			mInnocents.Add(447);
			mInnocents.Add(574);
			mInnocents.Add(977);
			mInnocents.Add(284);
			mInnocents.Add(445);
			mInnocents.Add(1721);
			mInnocents.Add(478);
			mInnocents.Add(511);
			mInnocents.Add(2940);
			mInnocents.Add(3994);

			mInnocents.Sort(delegate(int a, int b)
			{
				return mHof.IndexOf(mHof.Find(user => user.nIdUsuario == a)).CompareTo(mHof.IndexOf(mHof.Find(user => user.nIdUsuario == b)));
			});

			foreach (int userID in mInnocents)
			{
				Usuarios theUser = mHof.Find(user => user.nIdUsuario == userID);
				mCheaters.Remove(theUser);
				MyLabelInnocents.Text += "Pos:" + mHof.IndexOf(theUser) + " UserID: " + userID + "<br/>";
			}
			
            // Bye por encima del 50
            for (int c = 0; c < mCheaters.Keys.Count; c++)
            {
                if (mHof.IndexOf(mCheaters.Keys.ElementAt(c)) >= 50)
                {
                    mCheaters.Remove(mCheaters.Keys.ElementAt(c));
                    c--;
                }
            }
        }

		private void PrintStats()
		{
			var puntFlageadas = from punts in mContext.Puntuaciones
								where punts.nFlag == 1
								select punts;

			var cheaters = (from cheater in puntFlageadas
							select cheater.nIdUsuario).Distinct();

			MyLabel01.Text = puntFlageadas.Count().ToString() + " puntuaciones enviadas manualmente, hechas por " + cheaters.Count().ToString() + " jugadores";
		}

		private void PrintHof()
		{
			foreach(Usuarios user in mHof)
			{
				TableRow theRow = new TableRow();
				theRow.VerticalAlign = VerticalAlign.Top;

				TableCell thePositionInHofCell = new TableCell();
				thePositionInHofCell.Text = (mHof.IndexOf(user) + 1).ToString();

				TableCell theOldPositionInHofCell = new TableCell();
				theOldPositionInHofCell.Text = mHof.IndexOf(user).ToString();

				TableCell userIDCell = new TableCell();
				HyperLink daLink = new HyperLink();
				daLink.NavigateUrl = "IndividualReport.aspx?UserID=" + user.nIdUsuario.ToString();
				daLink.Text = user.nIdUsuario.ToString();
				userIDCell.Controls.Add(daLink);

				TableCell theFacebookIDCell = new TableCell();
				theFacebookIDCell.Text = user.cFacebookString;

				TableCell emailLink = new TableCell();
				emailLink.Text = "<a href=\"http://www.facebook.com/?sk=messages&compose=1&id=" + user.cFacebookString + "&subject=XXXX&message=XXXXX\">Facebook mail</a>";

				theRow.Cells.Add(thePositionInHofCell);
				theRow.Cells.Add(theOldPositionInHofCell);
				theRow.Cells.Add(userIDCell);
				theRow.Cells.Add(theFacebookIDCell);
				theRow.Cells.Add(emailLink);

				HofTable.Rows.Add(theRow);
			}
		}

		private void PrintFinalRanking()
		{
			int numPrinted = 0;
			int hofCounter = 0;
			while (numPrinted < 20 && hofCounter < mHof.Count)
			{
				if (mCheaters.ContainsKey(mHof[hofCounter]))
				{
					hofCounter++;
					continue;
				}

				Usuarios user = mHof[hofCounter];

				TableRow theRow = new TableRow();
				theRow.VerticalAlign = VerticalAlign.Top;

				TableCell thePositionInHofCell = new TableCell();
				thePositionInHofCell.Text = (numPrinted + 1).ToString();

				TableCell theOldPositionInHofCell = new TableCell();
				theOldPositionInHofCell.Text = mHof.IndexOf(user).ToString();

				TableCell userIDCell = new TableCell();
				HyperLink daLink = new HyperLink();
				daLink.NavigateUrl = "IndividualReport.aspx?UserID=" + user.nIdUsuario.ToString();
				daLink.Text = user.nIdUsuario.ToString();
				userIDCell.Controls.Add(daLink);

				TableCell theFacebookIDCell = new TableCell();
				theFacebookIDCell.Text = user.cFacebookString;

				TableCell emailLink = new TableCell();
				emailLink.Text = "<a href=\"http://www.facebook.com/?sk=messages&compose=1&id=" + user.cFacebookString + "&subject=XXXX&message=XXXXX\">Facebook mail</a>";

				theRow.Cells.Add(thePositionInHofCell);
				theRow.Cells.Add(theOldPositionInHofCell);
				theRow.Cells.Add(userIDCell);
				theRow.Cells.Add(theFacebookIDCell);
				theRow.Cells.Add(emailLink);

				FinalRanking.Rows.Add(theRow);

				hofCounter++;
				numPrinted++;
			}
		}

		private void PrintCheaters()
        {
            foreach (Usuarios user in mCheaters.Keys.OrderBy(user => mHof.IndexOf(user)))
            {
                TableRow theRow = new TableRow();
                theRow.VerticalAlign = VerticalAlign.Top;

                TableCell thePositionInHofCell = new TableCell();
                thePositionInHofCell.Text = mHof.IndexOf(user).ToString();

                TableCell userIDCell = new TableCell();
                HyperLink daLink = new HyperLink();
                daLink.NavigateUrl = "IndividualReport.aspx?UserID=" + user.nIdUsuario.ToString();
                daLink.Text = user.nIdUsuario.ToString();
                userIDCell.Controls.Add(daLink);

                TableCell theFacebookIDCell = new TableCell();
                theFacebookIDCell.Text = user.cFacebookString;

                TableCell reasonsCell = new TableCell();
                foreach (string reason in mCheaters[user].Keys)
                    reasonsCell.Text += mCheaters[user][reason].ToString() + reason + "<br/>";

				TableCell emailLink = new TableCell();
				emailLink.Text = "<a href=\"http://www.facebook.com/?sk=messages&compose=1&id=" + user.cFacebookString + "&subject=XXXX&message=XXXXX\">Facebook mail</a>";

                theRow.Cells.Add(thePositionInHofCell);
                theRow.Cells.Add(userIDCell);
                theRow.Cells.Add(theFacebookIDCell);
                theRow.Cells.Add(reasonsCell);
				theRow.Cells.Add(emailLink);

                MyTable01.Rows.Add(theRow);

				MyLabelCheaters.Text += user.nIdUsuario + "<br/>";
            }

            MyLabel03.Text = "Número de tramposos: " + mCheaters.Keys.Count;
        }

        private void CheckSumaPuntuaciones()
        {
            foreach (Usuarios user in mHof)
            {
                int globalScore = 0;
                for (int c = 0; c < user.Puntuaciones.Count(); c++)
                {
                    Puntuaciones punt = user.Puntuaciones.ElementAt(c);

                    if (punt.nPuntuacion == -1)
                        continue;

                    if (c == user.Puntuaciones.Count() - 1)
                    {
                        if (punt.cEvento == "GlobalScore" || punt.cEvento == "Restart")
                        {
                            // Comparamos la suma
                            if (globalScore != punt.nPuntuacion)
                                AddReasonToCheater(user, " partidas enviadas no suman la puntuacion final");
                        }
                        else
                        {
                            // El orden esta cambiado
                            globalScore += punt.nPuntuacion;

                            if (user.Puntuaciones.ElementAt(c-1).cEvento != "GlobalScore")
                                throw new Exception("Cosa rara...");

                            if (globalScore != user.Puntuaciones.ElementAt(c-1).nPuntuacion)
                                AddReasonToCheater(user, " partidas enviadas no suman la puntuacion final");
                        }
                    }
                    else
                    if (punt.cEvento == "Restart")
                    {
                        int diff = punt.nPuntuacion - globalScore;
                        if (diff != 0)
                            AddReasonToCheater(user, " partidas enviadas no suman la puntuacion final");
                        
                        // Leemos la siguiente partida
                        globalScore = 0;
                    }
                    else
                    if (punt.cEvento != "GlobalScore")
                        globalScore += punt.nPuntuacion;
                }
            }
        }

        private void AddReasonToCheater(Usuarios user, string reason)
        {
            if (!mCheaters.ContainsKey(user))
                mCheaters[user] = new Dictionary<string, int>();

            if (mCheaters[user].ContainsKey(reason))
                mCheaters[user][reason]++;
            else
                mCheaters[user][reason] = 1;
        }

        DesafiateDataContext mContext;
        List<Usuarios> mHof;

        // Usuario -> Razones
        Dictionary<Usuarios, Dictionary<string, int>> mCheaters = new Dictionary<Usuarios, Dictionary<string, int>>();
    }
}
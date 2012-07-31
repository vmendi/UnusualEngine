using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Diagnostics;

namespace Desafiate
{
    public partial class IndividualReport : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Request.QueryString.AllKeys.Contains("UserID"))
                return;

            int userID = int.Parse(Request["UserID"]);

            DesafiateDataContext context = new DesafiateDataContext();

            Usuarios user = (from userDB in context.Usuarios where userDB.nIdUsuario == userID select userDB).First();
            List<Puntuaciones> puntList = GetResortedPuntuaciones(user);

            foreach (Puntuaciones punt in puntList)
            {
                TableRow theRow = new TableRow();

                TableCell theCell = new TableCell();
                theCell.Text = puntList.IndexOf(punt).ToString();
                theRow.Cells.Add(theCell);

                theCell = new TableCell();
                theCell.Text = punt.cEvento;
                theRow.Cells.Add(theCell);

                theCell = new TableCell();
                theCell.Text = punt.nPuntuacion.ToString();
                theRow.Cells.Add(theCell);

                theCell = new TableCell();
                theCell.Text = punt.nFlag.ToString();
                theRow.Cells.Add(theCell);

                theCell = new TableCell();
                theCell.Text = punt.dFecha.ToString();
                theRow.Cells.Add(theCell);

                MyTable01.Rows.Add(theRow);

                if (punt.cEvento == "Restart")
                {
                    theCell = new TableCell();
                    theCell.Text = "&nbsp;";
                    theCell.ColumnSpan = theRow.Cells.Count;
                    theRow = new TableRow();
                    theRow.Cells.Add(theCell);
                    theRow.Cells.Add(theCell);
                    theRow.Cells.Add(theCell);
                    
                    MyTable01.Rows.Add(theRow);
                }
            }
        }

        static List<Puntuaciones> GetResortedPuntuaciones(Usuarios user)
        {
            List<Puntuaciones> ret = new List<Puntuaciones>();

            for (int c = 0; c < user.Puntuaciones.Count; c++)
            {
                Puntuaciones curr = user.Puntuaciones[c];

                if (curr.cEvento == "Restart")
                {
                    ret.Add(curr);
                }
                else
                {
                    if (curr.cEvento != "GlobalScore")
                    {
                        ret.Add(curr);

                        if (c != user.Puntuaciones.Count - 1 && curr.nPuntuacion != -1)
                        {
                            Puntuaciones next = user.Puntuaciones[c + 1];
                            if (next.cEvento == "GlobalScore")
                            {
                                ret.Add(next);
                                c++;
                            }
                        }
                    }
                    else
                    {
                        if (c != user.Puntuaciones.Count - 1)
                        {
                            Puntuaciones next = user.Puntuaciones[c + 1];
                            if (next.cEvento != "GlobalScore" && next.cEvento != "Restart")
                            {
                                ret.Add(next);
                                c++;
                            }
                        }
                        ret.Add(curr);
                    }
                }
            }

            Debug.Assert(ret.Count == user.Puntuaciones.Count);

            return ret;
        }
    }
}
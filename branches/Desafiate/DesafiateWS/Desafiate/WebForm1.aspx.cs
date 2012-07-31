using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;

namespace Desafiate
{
    public partial class WebForm1 : System.Web.UI.Page
    {
        private string connString = "Data Source=localhost;Initial Catalog=Desafiate;Integrated Security=True;MultipleActiveResultSets=True";
        SqlConnection myConn = new SqlConnection();

        protected void Page_Load(object sender, EventArgs e)
        {
            getUserStats();
        }
        /* Obtiene las estadísticas generales de uso */
        // TODO: Incluir valores porcentuales
        public void getUserStats()
        {
            //string result = "KO";
            myConn.ConnectionString = connString;
            myConn.Open();

            SqlCommand command = new SqlCommand("SELECT * FROM getStats", myConn);
            SqlDataReader reader = command.ExecuteReader();

            GridView table = new GridView();
            stats.DataSource = reader;
            stats.DataBind();

            myConn.Close();
            reader.Close();
        }
        public string getUserCheck ()
        {
            string result = "KO";
            myConn.ConnectionString = connString;
            myConn.Open();

            SqlCommand command = new SqlCommand("SELECT * FROM Usuarios", myConn);
            SqlDataReader reader = command.ExecuteReader();

            result = "<table border='1'>";
            while (reader.Read())
            {
                bool puntsCheck = getPuntsCheck(reader["nIdUsuario"].ToString());
                bool levelCheck = getLevelCheck(reader["nIdUsuario"].ToString());

                if (puntsCheck == true || levelCheck == true)
                {
                    result += "<tr><td>";
                    result += reader["nIdUsuario"].ToString();
                    result += "</td><td>";
                    result += reader["cFacebookString"].ToString();
                    result += "</td><td>";
                    result += puntsCheck.ToString();
                    result += "</td><td>";
                    result += levelCheck.ToString();
                    result += "</td></tr>";
                }
            }
            result += "</table>";
            reader.Close();
            return result;
        }

        /* Realiza la comprobación del orden de fases */
        private bool getLevelCheck(string nIdUsuario)
        {
            bool result = false;
            string[] levelorder = new string[3];
            levelorder[0] = "TM_01";
            levelorder[1] = "TM_02";
            levelorder[2] = "TM_03";

            string sql = "SELECT * FROM Puntuaciones where (cEvento = 'TM_01' OR cEvento = 'TM_02' OR cEvento = 'TM_03') AND nIdUsuario = " + nIdUsuario + " ORDER BY dFecha";
            SqlCommand command = new SqlCommand(sql, myConn);
            SqlDataReader reader = command.ExecuteReader();

            while (reader.Read())
            {
                int i = 0;
                if (levelorder[i] != reader["cEvento"].ToString())
                {
                    if (reader["cEvento"].ToString() != levelorder[0])
                    {
                        result = true;
                        break;
                    }
                }

                if (i < 2) i++;
                else i = 0;
            }
            return result;
        }

        /* Realiza la comprobación de la coherencia de puntos */
        private bool getPuntsCheck(string nIdUsuario) 
        {
            bool result = false;

            string sqlGlobScore = "SELECT TOP 1 nIdPuntuacion, nPuntuacion FROM Puntuaciones WHERE cEvento = 'GlobalScore' AND nIdUsuario = '" + nIdUsuario + "' ORDER BY nPuntuacion DESC";
            SqlCommand command = new SqlCommand(sqlGlobScore, myConn);
            SqlDataReader reader = command.ExecuteReader();

            if (reader.Read())
            {
                // Detalle de operaciones efectuadas
                if ((Convert.ToInt32(reader["nPuntuacion"].ToString()) - Convert.ToInt32(getPuntsSum(nIdUsuario, reader["nIdPuntuacion"].ToString()))) != 0)
                {
                    string wresult = nIdUsuario + " .- ";
                    wresult += reader["nPuntuacion"].ToString();
                    wresult += " - ";
                    wresult += getPuntsSum(nIdUsuario, reader["nIdPuntuacion"].ToString());
                    wresult += " = ";
                    wresult += (Convert.ToInt32(reader["nPuntuacion"].ToString()) - Convert.ToInt32(getPuntsSum(nIdUsuario, reader["nIdPuntuacion"].ToString())));
                    //Response.Write(wresult + "<br/>");
                }
                bool checkPuntuaciones = (Convert.ToInt32(reader["nPuntuacion"].ToString()) - Convert.ToInt32(getPuntsSum(nIdUsuario, reader["nIdPuntuacion"].ToString()))) != 0;
                result = checkPuntuaciones;
            }
            reader.Close();
            return result;
        }

        /* Obtiene la suma de puntos de todas las fases de un determinado jugador */
        private string getPuntsSum(string nIdUsuario, string nIdPuntuacion)
        {
            string result = "";
            string nIdBeginGame = "0";

            string sqlBeginGame = "SELECT nIdPuntuacion FROM Puntuaciones WHERE nIdPuntuacion < " + nIdPuntuacion + " AND nIdUsuario = '" + nIdUsuario + "' AND cEvento = 'MiniGameEndedGeekQuiz' order by dFecha DESC";
            SqlCommand command = new SqlCommand(sqlBeginGame, myConn);
            SqlDataReader reader = command.ExecuteReader();

            if (reader.Read())
            {
                nIdBeginGame = reader["nIdPuntuacion"].ToString();
            }
            reader.Close();

            string checkLastGame = "SELECT nIdPuntuacion FROM Puntuaciones WHERE nIdPuntuacion > " + nIdPuntuacion + " AND cEvento = 'Restart' AND nIdUsuario = '" + nIdUsuario + "'";
            command = new SqlCommand(checkLastGame, myConn);
            reader = command.ExecuteReader();

            string sqlGlobScore;
            if (reader.Read())
            {
                nIdPuntuacion = reader["nIdPuntuacion"].ToString();
                sqlGlobScore = "SELECT SUM(nPuntuacion) nMax FROM Puntuaciones WHERE nIdPuntuacion < " + nIdPuntuacion + " AND nIdPuntuacion >= " + nIdBeginGame + " AND cEvento <> 'GlobalScore' AND nPuntuacion <> -1 AND nIdUsuario = '" + nIdUsuario + "'";
            }
            else
            {
                sqlGlobScore = "SELECT SUM(nPuntuacion) nMax FROM Puntuaciones WHERE nIdPuntuacion >= " + nIdBeginGame + " AND cEvento <> 'GlobalScore' AND nPuntuacion <> -1 AND nIdUsuario = '" + nIdUsuario + "'";
            }

            command = new SqlCommand(sqlGlobScore, myConn);
            reader = command.ExecuteReader();

            if (reader.Read())
            {
                result += reader["nMax"].ToString();
                //result += " [" + sqlGlobScore + "]";
            }
            reader.Close();
            return result;
        }
    }
}

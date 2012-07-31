using System;
using System.ComponentModel;
using System.Linq;
using System.Xml.Linq;
using System.Collections.Generic;
using System.Diagnostics;
using System.Web.Services;
using System.Web;
using System.IO;

namespace Desafiate
{
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [ToolboxItem(false)]

    // Para permitir que se llame a este servicio web desde un script, usando ASP.NET AJAX, quite la marca de comentario de la línea siguiente. 
    // [System.Web.Script.Services.ScriptService]

    public class MainService : System.Web.Services.WebService
    {
        public String keyChecker = "SJR0ICBVF7XK2T2EGOR2";

        private const string _apiKey = "0311c819f5d81865ec7a0183543a5d54";
        private const string _secret = "53f9f1fd3577bd5489d6f15d38946a2d";

        DesafiateDataContext db = new DesafiateDataContext();

        [WebMethod]
        public string sessionStart(string cFacebookString)
        {
            string result = "KO";
            try
            {
                Sesiones session = new Sesiones();

                session.cFacebookString = cFacebookString;
                session.cIP = Context.Request.ServerVariables["REMOTE_ADDR"];
                session.dStart = DateTime.Now;
                session.dKeep = DateTime.Now;

                db.Sesiones.InsertOnSubmit(session);
                db.SubmitChanges();

                //Log("Inicio de sesión [" + Context.Request.ServerVariables["REMOTE_ADDR"].ToString() + ":" + cFacebookString + "]");

                result = session.nIdSesion.ToString();
            }
            catch (Exception e)
            { 
                Log ("Excepcion creación de sesión", e);
            }
            return result;
        }
        [WebMethod]
        public string sessionStartNew(string cFacebookString, string cSessionID)
        {
            string sessionCheck = CreateSession(cFacebookString, cSessionID);
            string result = "KO";
            if (sessionCheck != "KO")
            {
                try
                {
                    Sesiones session = new Sesiones();

                    session.cFacebookString = cFacebookString;
                    session.cIP = Context.Request.ServerVariables["REMOTE_ADDR"];
                    session.dStart = DateTime.Now;
                    session.dKeep = DateTime.Now;

                    db.Sesiones.InsertOnSubmit(session);
                    db.SubmitChanges();

                    //Log("Inicio de sesión [" + Context.Request.ServerVariables["REMOTE_ADDR"].ToString() + ":" + cFacebookString + "]");

                    result = session.nIdSesion.ToString();
                }
                catch (Exception e)
                { 
                    Log("Excepcion creación de sesión", e);
                }
            }
            else
            {
                Log("Comprobacion de sesión fallida: [" + sessionCheck + "]");
            }
            return result;
        }

        private string CreateSession(string MyUserID, string MyUserSessionKey)
        {
            string result = "KO";
            try
            {
                long MyUserIDi = Convert.ToInt64(MyUserID);
                Facebook.Session.ConnectSession ConnectSession = new Facebook.Session.ConnectSession(_apiKey, _secret);
                Facebook.Rest.Api Api = new Facebook.Rest.Api(ConnectSession);
                Api.Session.SessionKey = MyUserSessionKey; // the session key you saved 
                Api.Session.UserId = MyUserIDi; // the userid you saved
                var FBUser = Api.Users.GetInfo();

                //Log("FBUser : " + FBUser.ToString());
                result = "OK";
            }
            catch (Exception e)
            {
                Log("Excepcion creacion de sesión : " + MyUserID + " :: " + MyUserSessionKey + " - " + e.Message);
            }
            return result;
        } 

        [WebMethod]
        public string keepAlive(string cFacebookString, string nIdSesion)
        {
            string result = "NOSESSION";
            string cIP = Context.Request.ServerVariables["REMOTE_ADDR"];

            IEnumerable<Sesiones> sesion = (from s in db.Sesiones
                                           where s.cIP == cIP && s.cFacebookString == cFacebookString
                                           orderby s.dStart descending
                                           select s).Take(1);
            if (sesion.Count() > 0)
            {
                Sesiones tsesion = sesion.First();
                try
                {
                    if (tsesion.nIdSesion == Convert.ToInt64(nIdSesion))
                    {
                        DateTime dkeepalive = tsesion.dKeep;
                        DateTime dkeepcompare = DateTime.Now;
                        TimeSpan dresult = dkeepcompare - dkeepalive;

                        double dseconds = dresult.TotalSeconds;

                        if (dseconds <= 720)
                        {
                            tsesion.dKeep = DateTime.Now;
                            db.SubmitChanges();
                            //Log("KeepAlive OK [" + cIP + ":" + cFacebookString + "]");
                            result = "OK";
                        }
                        else
                        {
                            result = "EXPIRED";
                            Log("Sesión expirada [" + cIP + ":" + cFacebookString + "] :: (dseconds " + dseconds + ")");
                        }
                    }
                    else
                    {
                        Log("Sesión duplicada [" + cIP + ":" + cFacebookString + "]");
                        result = "EXPIRED";
                    }
                }
                catch (Exception e)
                {
                    Log("Excepcion de sesión [" + cIP + ":" + cFacebookString + "] ", e);
                    result = "KO";
                }
            }
            return result;
        }

        [WebMethod]
        public string getChecker() 
        {
            return getServerTime();
        }

        [WebMethod]
        public UserData[] getHOF()
        {
            UserData[] Users = null;    
            IEnumerable<Usuarios> hof = from u in db.Usuarios
                                        let maxPunt = (from p in u.Puntuaciones select p.nPuntuacion).Max()
                                        orderby maxPunt descending
                                        select u;
            int i = 0;
            if (hof.Count() < 20) 
                Users = new UserData[hof.Count()];
            else 
                Users = new UserData[20];
            foreach (Usuarios hofUser in hof)
            {
				if (IsCheater(hofUser))
					continue;
				 
                int maxP = 0;
                if (hofUser.Puntuaciones.Count() > 0)
                    maxP = hofUser.Puntuaciones.Max(puntParam => puntParam.nPuntuacion);
                Users[i].Usuario = hofUser.cFacebookString;
				Users[i].Puntuacion = "0";// maxP.ToString();
                if (i >= 19) break;
                i++;
            }
            return Users;
        }
		 

		private bool IsCheater(Usuarios user)
		{
			if (mCheaters == null)
			{
				mCheaters = new List<int>();

				try
				{
					string fileName = Path.Combine(HttpContext.Current.Request.PhysicalApplicationPath, "cheaters.txt");

					using (TextReader reader = File.OpenText(fileName))
					{
						string text = reader.ReadLine();
						while (text != null)
						{
							int userID = int.Parse(text);
							mCheaters.Add(userID);
							text = reader.ReadLine();
						}
					}
				}
				catch { }

			}

			return mCheaters.Contains(user.nIdUsuario);
		}

		private List<int> mCheaters = null;

        [WebMethod]
        public String getUsuario(string cFacebookString, string nIdSesion, string cUserCheck)
        {
            string sessionCheck = keepAlive(cFacebookString, nIdSesion);
            string ret = sessionCheck;

            if (sessionCheck == "OK")
            {
                try
                {
                    IEnumerable<String> users = (from c in db.Usuarios
                                                where c.cFacebookString == cFacebookString
                                                select c.cXmlProperties).Take(1);
                    if (users.Count() > 0)
                        ret = users.First();
                    else
                        ret = "NOTEXIST";
                }
                catch
                {
                    ret = "KO";
                }
            }
            return ret;
        }

        [WebMethod]
        public String saveUsuario(string cFacebookString, string nIdSesion, string cxmlProperties, string cUserCheck)
        {
            string sessionCheck = keepAlive(cFacebookString, nIdSesion);
            string ret = sessionCheck;

            byte cheatFlag = 0;
            if (getServerCheck(cUserCheck, cFacebookString) != 1) 
                cheatFlag = 1;

            if (sessionCheck == "OK")
            {
                var users = (from c in db.Usuarios
                            where c.cFacebookString == cFacebookString
                            select c).Take(1);

                try
                {
                    if (users.Count() == 1)
                    {
                        Usuarios user = users.First();
                        user.cXmlProperties = cxmlProperties;
                        if (cheatFlag == 1)
                            user.nFlag = cheatFlag;
                        db.SubmitChanges();
                        //Log("Salvado de usuario [" + Context.Request.ServerVariables["REMOTE_ADDR"].ToString() + ":" + cFacebookString + "-" + cheatFlag + "] ");
                        ret = "OK";
                    }
                    else
                    {
                        Usuarios user = new Usuarios();
                        user.cFacebookString = cFacebookString;
                        user.cXmlProperties = cxmlProperties;
                        if (cheatFlag == 1)
                            user.nFlag = cheatFlag;
                        db.Usuarios.InsertOnSubmit(user);
                        db.SubmitChanges();
                        //Log("Creación de usuario [" + Context.Request.ServerVariables["REMOTE_ADDR"].ToString() + ":" + cFacebookString + "-" + cheatFlag + "] ");
                        ret = "OK";
                    }
                }
                catch (Exception e)
                {
                    Log("Excepción salvado de usuario [" + Context.Request.ServerVariables["REMOTE_ADDR"].ToString() + ":" + cFacebookString + "] ", e);
                    ret = "KO";
                }
            }
            return ret;
        }

        [WebMethod]
        public String savePuntuacion(string cFacebookString, string nIdSesion, string cEvento, int nPuntuacion, string cUserCheck)
        {
			return "OK";

			/*
            string sessionCheck = keepAlive(cFacebookString, nIdSesion);
            string ret = sessionCheck;

            byte cheatFlag = 0;
            if (getServerCheck(cUserCheck, cFacebookString) != 1)
                cheatFlag = 1;

            if (sessionCheck == "OK")
            {
                IEnumerable<int> users = (from c in db.Usuarios
                                         where c.cFacebookString == cFacebookString
                                         select c.nIdUsuario).Take(1);

                int usuario = users.First();

                try
                {
                    if (users.Count() >= 1)
                    {
                        Puntuaciones punts = new Puntuaciones();
                        punts.nIdUsuario = usuario;
                        punts.cEvento = cEvento;
                        punts.nPuntuacion = nPuntuacion;
                        punts.dFecha = DateTime.Now;
                        if (cheatFlag == 1)
                            punts.nFlag = cheatFlag;
                        db.Puntuaciones.InsertOnSubmit(punts);

                        //Log("Salvado de puntuacion [" + Context.Request.ServerVariables["REMOTE_ADDR"].ToString() + ":" + cFacebookString + "-" + cheatFlag + "] ");
                        db.SubmitChanges();
                        ret = "OK";
                    }
                }
                catch (Exception e)
                {
                    Log("Excepción salvado de puntuacion [" + Context.Request.ServerVariables["REMOTE_ADDR"].ToString() + ":" + cFacebookString + "] ", e);
                    ret = "KO";
                }
            }
			
            return ret;  * */
		}

        [WebMethod]
        public String addLogro(string cFacebookString, string nIdSesion, string cEvento, string cLogro, string cUserCheck)
        {
            string sessionCheck = keepAlive(cFacebookString, nIdSesion);
            string ret = sessionCheck;

            byte cheatFlag = 0;
            if (getServerCheck(cUserCheck, cFacebookString) != 1)
                cheatFlag = 1;

            if (sessionCheck == "OK")
            {
                try
                {
                    IEnumerable<int> users = (from c in db.Usuarios
                                             where c.cFacebookString == cFacebookString
                                             select c.nIdUsuario).Take(1);
                    int usuario = users.First();

                    if (users.Count() >= 1)
                    {
                        Logros logr = new Logros();
                        logr.nIdUsuario = usuario;
                        logr.cEvento = cEvento;
                        logr.cLogro = cLogro;
                        logr.dFecha = DateTime.Now;
                        if (cheatFlag == 1)
                            logr.nFlag = cheatFlag;
                        db.Logros.InsertOnSubmit(logr);

                        db.SubmitChanges();
                        //Log("Salvado de logro [" + Context.Request.ServerVariables["REMOTE_ADDR"].ToString() + ":" + cFacebookString + "-" + cheatFlag + "] ");
                        ret = "OK";
                    }
                }
                catch (Exception e)
                {
                    Log("Excepción salvado de logro [" + Context.Request.ServerVariables["REMOTE_ADDR"].ToString() + ":" + cFacebookString + "] ", e);
                    ret = "KO";
                }
            }
            return ret;
        }

        public string GetMD5Hash(string input)
        {
            System.Security.Cryptography.MD5CryptoServiceProvider x = new System.Security.Cryptography.MD5CryptoServiceProvider();
            byte[] bs = System.Text.Encoding.UTF8.GetBytes(input);
            bs = x.ComputeHash(bs);
            System.Text.StringBuilder s = new System.Text.StringBuilder();
            foreach (byte b in bs)
            {
                s.Append(b.ToString("x2").ToLower());
            }
            string password = s.ToString();
            return password;
        }

        public string getServerTime()
        {
            DateTime dtThen = new DateTime(2001, 1, 1, 0, 0, 0, 0);
            DateTime dtNow = DateTime.Now;
            TimeSpan span = dtNow - dtThen;
            int timestamp = (int)span.TotalSeconds;
            string timestampstr = timestamp.ToString();
            string timestampsubstr = timestampstr.Substring(0, timestampstr.Length - 2);
            return timestampsubstr;
        }

        public byte getServerCheck(string resultCheck, string cFacebookString)
        {
            byte result = 0;
            int timecheck = Convert.ToInt32(getServerTime());
            int timecheck2 = timecheck + 1;
            int timecheck3 = timecheck - 1;

            string firstcheck = GetMD5Hash(cFacebookString + keyChecker + timecheck);
            string secondcheck = GetMD5Hash(cFacebookString + keyChecker + timecheck2);
            string thirdcheck = GetMD5Hash(cFacebookString + keyChecker + timecheck3);

            if (firstcheck == resultCheck || secondcheck == resultCheck || thirdcheck == resultCheck)
                result = 1;
            else
                Log("Check fallido de seguridad : [" + cFacebookString + "-" + firstcheck + " (" + timecheck + ") :: " + secondcheck + " (" + timecheck2 + ") :: " + thirdcheck + " (" + timecheck3 + ") :: " + resultCheck + "]");

            return result;
        }

        
        public static void Log(string Message)
        {
            Log(Message, null);
        }

        public static void Log(string Message, Exception Ex)
        {
            try
            {
                string fileName = Path.Combine(
                    HttpContext.Current.Request.PhysicalApplicationPath, "DesafUW.log");
                using (StreamWriter logFile = new StreamWriter(fileName, true))
                {
                    logFile.WriteLine("{0}: {1}", DateTime.Now, Message);
                    if (Ex != null)
                        logFile.WriteLine(Ex.ToString());
                    logFile.Close();
                }
            }
            finally
            { }    
        }


        public struct UserData
        {
            public String Usuario;
            public String Puntuacion;
        }
    }
}
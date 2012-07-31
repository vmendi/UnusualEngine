using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using Facebook;
using Facebook.Web;
using System.Text;
using System.Security.Cryptography;
using System.Diagnostics;
using Facebook.Utility;
using System.Threading;

using SoccerServerV1.BDDModel;
using Weborb.Util.Logging;

namespace SoccerServerV1
{
    public partial class Default : Facebook.Web.CanvasIFrameBasePage
    {
        public Default()
        {
            RequireLogin = true;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
			if (Api.Session.SessionKey != null)
			{
				if (VerifyFacebookSignature(Request.Form))
				{
					ProcessInFacebookSessionUser();
				}
				else
				{
					ProcessSessionError("Invalid signature");
				}
			}
			else
			{
				// Puede ser porque o no tenemos permisos todavia o no hay hecho el login.
				// Algunas opciones son:
				// - Usar el RequireLogin=true del constructor para pedir permisos de acceso basico o que haga login (hacer login da permisos automaticamente).
				// - Renderizar una demo del juego para que a pesar de no tener permisos o no estar hecho el login, se vea algo.
				// - Redireccionar a otra pagina para hacer login/pedir permisos. Response.Redirect("NotLoggedInFacebook.aspx");
				ProcessSessionError("Not logged in to facebook");
			}
        }

		private void ProcessSessionError(string msgError)
		{
			Log.log(DEFAULTASPX_LOG, msgError);
			MyCentralLabel.InnerHtml = msgError;
			Session.Abandon();
		}

		private void ProcessInFacebookSessionUser()
		{
			using (SoccerDataModelDataContext theContext = new SoccerDataModelDataContext())
			{
				Player player = EnsurePlayerIsCreated(theContext, Api.Session.UserId.ToString(), () => Api.Users.GetInfo() );
				
				string sessionKey = Request.Form["fb_sig_session_key"];

				if (sessionKey != null)
				{
					EnsureSessionIsCreated(theContext, player, sessionKey);
					theContext.SubmitChanges();

					string queryStringToClient = Request.Form.ToString();

					if (player.Liked)
						queryStringToClient += "&liked=true";
					
					// Seria mejor hacer un transfer, pero no sabemos como librarnos de la exception, a pesar del catch parece que la relanza??
					Response.Redirect("SoccerClientV1/SoccerClientV1.html?" + queryStringToClient, false);
				}
				else
				{
					ProcessSessionError("No session key");					
				}
			}
		}

		static public BDDModel.Session EnsureSessionIsCreated(SoccerDataModelDataContext theContext, Player thePlayer, string sessionKey)
		{
			var session = (from dbSession in theContext.Sessions
						   where dbSession.FacebookSession == sessionKey
						   select dbSession).FirstOrDefault();

			if (session == null)
			{
				session = new BDDModel.Session();
				session.Player = thePlayer;
				session.FacebookSession = sessionKey;
                session.CreationDate = DateTime.Now;    // En horario del servidor

				theContext.Sessions.InsertOnSubmit(session);
			}

            return session;
		}

		public delegate Facebook.Schema.user GetFBUserDelegate();

		static public Player EnsurePlayerIsCreated(SoccerDataModelDataContext theContext, string facebookUserID, GetFBUserDelegate theFBUser)
		{
			var player = (from dbPlayer in theContext.Players
						  where dbPlayer.FacebookID == facebookUserID
						  select dbPlayer).FirstOrDefault();

			if (player == null)
			{
				// Tenemos un nuevo jugador (unico punto donde se crea)
				player = new Player();

				player.FacebookID = facebookUserID;
				player.CreationDate = DateTime.Now;		// En horario del servidor...
				player.Liked = false;
				
				if (theFBUser != null)
				{
					// Probablemente llamada Rest
					Facebook.Schema.user theFBUSer = theFBUser();

					player.Name = theFBUSer.first_name;
					player.Surname = theFBUSer.last_name;
				}
				else
				{
					// Queremos evitar la llamada en los Test de debug
					player.Name = "PlayerName";
					player.Surname = "PlayerSurname";
				}

				theContext.Players.InsertOnSubmit(player);
			}

			return player;
		}

		private void PrintInfo()
		{
			MyCentralLabel.InnerHtml = Api.Session.UserId.ToString() + "<br/>" +
									   Api.Session.SessionKey + "<br/>" +
									   Api.Session.ExpiryTime + "<br/>" +
									   Api.Session.SessionExpires + "<br/>" +
									   Api.Users.GetInfo().first_name + "<br/>" +
									   Api.Users.GetInfo().last_name + "<br/>" +
									   Api.Users.GetInfo().sex;
		}

        /// <summary>
        /// http://wiki.developers.facebook.com/index.php/Verifying_The_Signature
        /// </summary>
        /// <param name="nameValueCollection"></param>
        /// <returns></returns>
        private bool VerifyFacebookSignature(System.Collections.Specialized.NameValueCollection nameValueCollection)
        {
            string signature = nameValueCollection["fb_sig"];
            if (String.IsNullOrEmpty(signature))
                return false;

            string s = (from key in nameValueCollection.AllKeys
                        where key.StartsWith("fb_sig_")
                        orderby key
                        select key.Substring(7) + "=" + nameValueCollection[key])
                        .Append() + Api.Session.ApplicationSecret;

            StringBuilder computedSignature = new StringBuilder();
            MD5.Create().ComputeHash(Encoding.UTF8.GetBytes(s)).ToList().ForEach(b => computedSignature.AppendFormat("{0:x2}", b));

            return computedSignature.ToString().ToLowerInvariant() == signature.ToLowerInvariant();
        }

		private const string DEFAULTASPX_LOG = "DEFAULTASPX_LOG";
    }

	public static class AppendStaticClass
	{
		public static string Append(this IEnumerable<string> list)
		{
			StringBuilder sb = new StringBuilder();
			list.ToList().ForEach(s => sb.Append(s));
			return sb.ToString();
		}
	}
}
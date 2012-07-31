using System;
using System.Linq;
using System.Web;

using Weborb.Util.Logging;

using SoccerServerV1.BDDModel;
using System.IO;

namespace SoccerServerV1
{
	public partial class MainService
	{
		public const String MAINSERVICE = "MAINSERVICE";
		public const String CLIENT_ERROR = "CLIENT_ERROR";

        public MainService()
        {
            if (!Log.isLogging(MainService.MAINSERVICE))
                Log.startLogging(MainService.MAINSERVICE);

            if (!Log.isLogging(MainService.CLIENT_ERROR))
                Log.startLogging(MainService.CLIENT_ERROR);
        }

        private SoccerDataModelDataContext CreateDataForRequest()
        {
            mContext = new SoccerDataModelDataContext();

            HttpContext theCurrentHttp = HttpContext.Current;

            if (!theCurrentHttp.Request.QueryString.AllKeys.Contains("SessionKey"))
                throw new Exception("SessionKey is missing");

            string sessionKey = theCurrentHttp.Request.QueryString["SessionKey"];

            mSession = (from s in mContext.Sessions
                        where s.FacebookSession == sessionKey
                        select s).FirstOrDefault();

            if (mSession == null)
                throw new Exception("Invalid SessionKey: " + sessionKey);

            mPlayer = mSession.Player;

            return mContext;
        }

		public enum VALID_NAME
		{
			VALID,
			DUPLICATED,
			INAPPROPIATE,
			TOO_SHORT,
			WHITE_SPACE_TRIM,
			TOO_MANY_WHITESPACES,
			EMPTY
		}

		public bool HasTeam()
		{
            using (CreateDataForRequest())
            {
                return mPlayer.Team != null;
            }
		}

		public VALID_NAME IsNameValid(string name)
		{
            using (CreateDataForRequest())
            {
                return IsNameValidInner(name);
            }
		}

        private VALID_NAME IsNameValidInner(string name)
        {
            VALID_NAME ret = VALID_NAME.VALID;

            if (name == "")
                ret = VALID_NAME.EMPTY;
            else
            if (name.Length <= 3)
                ret = VALID_NAME.TOO_SHORT;
            else
            if (IsNameInappropiate(name))
                ret = VALID_NAME.INAPPROPIATE;
            else
            if (HasNameWhitespacesAtStartOrEnd(name))
                ret = VALID_NAME.WHITE_SPACE_TRIM;
            else
            if (HasTooManyWhitespaces(name))
                ret = VALID_NAME.TOO_MANY_WHITESPACES;
            else
            {
                bool dup = (from t in mContext.Teams
                            where t.Name == name
                            select t).Count() > 0;
                if (dup)
                    ret = VALID_NAME.DUPLICATED;
            }
            
            return ret;
        }

		static private bool HasNameWhitespacesAtStartOrEnd(string name)
		{
			bool bRet = false;
			if (name.StartsWith(" ") || name.EndsWith(" "))
				bRet = true;
			return bRet;
		}

		static private bool HasTooManyWhitespaces(string name)
		{
			bool bRet = false;
			if (name.Count(theChar => theChar == ' ') > 3)
				bRet = true;
			return bRet;
		}

		static private bool IsNameInappropiate(string name)
		{
			String[] PROFANE_WORDS = { "puta", "puto", "coño", "coña", "conyo", "caca", "mierda", "joder", 
									   "gilipollas", "polla", "culo", "imbecil", "idiota", "tonto", "tonta",
									   "estupido", "estupida", };

			name = name.ToLower();
			name = name.Replace("á", "a");
			name = name.Replace("é", "e");
			name = name.Replace("í", "i");
			name = name.Replace("ó", "o");
			name = name.Replace("ú", "u");

			name = name.Replace("à", "a");
			name = name.Replace("è", "e");
			name = name.Replace("ì", "i");
			name = name.Replace("ò", "o");
			name = name.Replace("ù", "u");

			bool bRet = PROFANE_WORDS.Any(word => name.Contains(word));

			return bRet;
		}
		
		static private string PlayerToString(Player player)
		{
			return "Name: " + player.Name + " " + player.Surname + " FacebookID: " + player.FacebookID;
		}

		public void OnError(string msg)
		{
			Log.log(CLIENT_ERROR, msg);
		}

		public int OnLiked()
		{
            using (CreateDataForRequest())
            {
                mPlayer.Liked = true;

                // El mismo entrenamiento se ocupara de submitear cambios. La habilidad 1 tiene todos los requerimientos a 0, por lo que esta sola
                // llamada provocara su consecucion.
                TrainSpecial(1);
            }

			return 1;
		}

		SoccerDataModelDataContext mContext = null;
		Player mPlayer = null;
		Session mSession = null;
	}
}
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Weborb.Security;
using System.Security.Principal;
using Weborb.Message;

namespace SoccerServerV1
{
	public class SoccerServerAuthHandler : IAuthenticationHandler
	{
		public IPrincipal CheckCredentials(string userid, string password, Request message)
		{
			string[] roles = { "SoccerServerUser" };
			GenericIdentity identity = new GenericIdentity(userid);
			GenericPrincipal principal = new GenericPrincipal(identity, roles);
			return principal;
		}
	}
}
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Weborb.Util.Logging;

namespace SoccerServerV1.NetEngine
{
    public class NetEngineMain
    {
        internal const String NETENGINE_DEBUG = "NETENGINE DEBUG";
        internal const String NETENGINE_DEBUG_BUFFER = "NETENGINE DEBUG BUFFER";
        internal const String NETENGINE_DEBUG_THREADING = "NETENGINE DEBUG THREADING";
        internal const String NETENGINE_DEBUG_KEEPALIVE = "NETENGINE DEBUG KEEPALIVE";

        public NetEngineMain(INetClientApp clientApp)
        {
            mPolicyServer = new NetServer(true, null);
            mNetServer = new NetServer(false, clientApp);            
        }

        public void Start()
        {
            Log.startLogging(NETENGINE_DEBUG);
            //Log.startLogging(NETENGINE_DEBUG_BUFFER);
            //Log.startLogging(NETENGINE_DEBUG_THREADING);
            //Log.startLogging(NETENGINE_DEBUG_KEEPALIVE);

            mPolicyServer.Start();
            mNetServer.Start();
        }

        public void Stop()
        {
            mNetServer.Stop();
            mPolicyServer.Stop();
        }

        public NetServer NetServer
        {
            get { return mNetServer; }
        }

        readonly NetServer mNetServer;
        readonly NetServer mPolicyServer;
    }

    public sealed class NetEngineException : Exception
    {
        public NetEngineException(string msg) : base(msg) { } 
    }
}
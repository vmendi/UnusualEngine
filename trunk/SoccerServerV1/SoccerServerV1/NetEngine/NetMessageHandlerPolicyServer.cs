using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Weborb.Util.Logging;

namespace SoccerServerV1.NetEngine
{
    internal class NetMessageHandlerPolicyServer : NetMessageHandler
    {
        override internal void HandleStringMessage(NetPlug from, byte[] theString, int stringLength)
        {
            const string POLICY = "<?xml version=\"1.0\" encoding=\"utf-8\" ?>" +
                                  "<cross-domain-policy xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"" +
                                  "xsi:noNamespaceSchemaLocation=\"http://www.adobe.com/xml/schemas/PolicyFileSocket.xsd\">" +
                                  "<allow-access-from domain=\"*\" to-ports=\"*\" secure=\"false\" />" +
                                  "</cross-domain-policy>";

            string msg = System.Text.Encoding.UTF8.GetString(theString, 0, stringLength);

            if (msg.IndexOf("<policy-file-request/>") != -1)
                from.SendStringSuffix(POLICY);
            else
                Log.log(NetEngineMain.NETENGINE_DEBUG, "Failed policy request");
            
            from.CloseRequest();
        }

        override internal void HandleBinaryMessage(NetPlug from, byte[] message, int messageLength)
        {
            throw new NetEngineException("Not supported");
        }
    }
}
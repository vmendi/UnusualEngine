using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SoccerServerV1.NetEngine
{
    public abstract class INetClientApp
    {
        abstract public void OnAppStart(NetServer server);
        abstract public void OnAppEnd();

        // The server will stop in a few moments. 
        // First message to be received in the close sequence. 
        // Received in another thread, in parallel with current messages.
        // Then, you will receive OnClientLeft(s) for every remaining client.
        // Last message to be received in the close sequence is OnAppEnd.
        abstract public void OnServerAboutToShutdown();

        abstract public void OnClientConnected(NetPlug client);
        abstract public void OnClientLeft(NetPlug client);
    }
}
using System;
using System.Collections.Generic;
using System.Threading;
using System.Net.Sockets;
using System.Net;
using Weborb.Util.Logging;

namespace SoccerServerV1.NetEngine
{
    // - SAEA pool
    // - Extreme: NetConnection pool. Warning: As we are giving them to the client, implementing a Reset is difficult.
    //
    // - SAEA pool for the Accepts
    // - Research this: Nada mas aceptar una conexion se puede seguir aceptando inmediatamente.
    //                  Ahora mismo se procesan primero los receives (syncronos) de la NetConnection.
    //                  Supongo que todo el concepto se aplica a cuando el accept es asynchrono.          
    //
    // TODO: IDisposable!
    //
    public class NetServer
    {
        const int MAX_CONNECTIONS = 60000;
        const int BACKLOG_CONNECTIONS = 2048;
        const int POLICY_SERVER_PORT = 843;
        const int REGULAR_PORT = 2020;
        const int GHOST_TIME = 120;             // Seconds

        
        /// <param name="bPolicyServerMode">Adobe policy server behaviour *only*</param>
        public NetServer(bool bPolicyServerMode, INetClientApp netClientApp)
        {
            mPolicyServerMode = bPolicyServerMode;
            mNetClientApp = netClientApp;

            mMaxConnectionsEnforcer = new Semaphore(MAX_CONNECTIONS, MAX_CONNECTIONS);

            if (mPolicyServerMode)
            {
                mNetMessageHandler = new NetMessageHandlerPolicyServer();
                mBufferManager = new BufferManager(8192, 512);
            }
            else
            {
                mNetMessageHandler = new NetMessageHandler();
                mBufferManager = new BufferManager(MAX_CONNECTIONS * 2, 4096);
            }
         }

        public INetClientApp NetClientApp
        {
            get { return mNetClientApp; }
        }

        public int NumCurrentSockets
        {
            get { lock (mNetPlugsLock) return mNetPlugs.Count; }
        }

        public int NumMaxConcurrentSockets
        {
            get { lock (mNetPlugsLock) return mMaxConcurrentPlugs; }
        }

        public int NumCumulativePlugs
        {
            get { lock (mNetPlugsLock) return mCumulativePlugs; }
        }

        public DateTime LastStartTime
        {
            get { return mLastStartTime; }
        }


        public void Start()
        {
            try
            {
                if (IsRunning)
                    throw new NetEngineException("Already started. Stopping.");

                mNetMessageHandler.Start(this);

                IPEndPoint localEndPoint = new IPEndPoint(IPAddress.Any, mPolicyServerMode ? POLICY_SERVER_PORT : REGULAR_PORT);

                mListeningSocket = new Socket(localEndPoint.AddressFamily, SocketType.Stream, ProtocolType.Tcp);
                mListeningSocket.Bind(localEndPoint);

                // "backlog" means pending connections. max # for backlog can be limited by the operating system.
                // The backlog number is the number of clients that can wait for a SocketAsyncEventArg object that will do an accept operation.
                // The listening socket keeps the backlog as a queue. The backlog allows for a certain # of excess clients waiting to be connected.
                // If the backlog is maxed out, then the client will receive an error when trying to connect.
                mListeningSocket.Listen(BACKLOG_CONNECTIONS);

                mGhostsCleanupThread = new Thread(GhostsCleanupThread);
                mGhostsCleanupThread.Name = "GhostsCleanupThread";
                mGhostsCleanupThread.Start();

                mLastStartTime = DateTime.Now;

                StartAccept(null);
            }
            catch (Exception exc)
            {
                Log.log(NetEngineMain.NETENGINE_DEBUG, exc.ToString());
                Stop();
                throw;
            }
        }

        public void Stop()
        {
            try
            {
                // The following line causes an exception to be thrown 
                // in ThreadMethod if newThread is currently blocked
                // or becomes blocked in the future.
                mGhostsCleanupThread.Interrupt();
                mGhostsCleanupThread.Join();
                mGhostsCleanupThread = null;
                
                InnerStopCloseListeningSocket();

                // In parallel with the current InvokeNetClientApp(s)
                if (mNetClientApp != null)
                    mNetClientApp.OnServerAboutToShutdown();

                // Only after signaling the INetClientApp that we are about to close, we close the NetPlugs
                InnerStopCloseNetPlugs();

                if (mNetPlugs.Count != 0)
                    throw new NetEngineException("WTF - NetPlugs accepted?");

                // The remaining OnClientLefts will be executed. No more messages should be entering the Queue as we have closed all the NetPlugs
                // and we are no longer listening to connections
                mNetMessageHandler.Stop();

                mBufferManager.Reset();
            }
            catch (Exception exc)
            {
                Log.log(NetEngineMain.NETENGINE_DEBUG, exc.ToString());
            }
        }

        private void InnerStopCloseNetPlugs()
        {
            // CollectionModified exception avoided by cloning
            List<NetPlug> cloned = null;

            lock (mNetPlugsLock)
            {
                cloned = new List<NetPlug>(mNetPlugs);
            }

            foreach (NetPlug np in cloned)
            {
                // If not closed yet, this will reenter us into OnConnectionClosed.
                np.CloseRequest();
            }
        }

        private void InnerStopCloseListeningSocket()
        {
            lock (mListeningSocketLock)
            {
                if (IsRunning)
                {
                    try
                    {
                        mListeningSocket.Close();
                    }
                    finally
                    {
                        // No more connections are accepted after this. IsRunning == false
                        mListeningSocket = null;
                    }
                }
            }
        }

        public bool IsRunning
        {
            get { lock (mListeningSocketLock) return mListeningSocket != null; }
        }

        private void StartAccept(SocketAsyncEventArgs acceptSAEA)
        {
            if (acceptSAEA == null)
            {
                acceptSAEA = new SocketAsyncEventArgs();
                acceptSAEA.Completed += new EventHandler<SocketAsyncEventArgs>(AcceptSAEA_Completed);
            }

            bool bAsyncOp = false;
            while (!bAsyncOp)
            {
                // We wait until the semaphore signals that we are below the connection limit
                mMaxConnectionsEnforcer.WaitOne();

                // Socket must be cleared since the context object is being reused
                acceptSAEA.AcceptSocket = null;

                // A Close operation can't happen here. We have narrowed the critical section as much as possible, 
                // with the intention that if there are a million pending accepts, we close the server as soon as 
                // possible and don't wait until all of them are accepted. Locking at the start of this function 
                // for the duration of the whole function would preclude the server of being shutdown until all 
                // the connections were accepted, *if* the accepts where synchronous and we were looping here.
                lock (mListeningSocketLock) 
                {
                    if (!IsRunning)
                        return;

                    if (!(bAsyncOp = mListeningSocket.AcceptAsync(acceptSAEA)))
                        ProcessAccept(acceptSAEA);
                }
            }
        }

        private void AcceptSAEA_Completed(object sender, SocketAsyncEventArgs acceptSAEA)
        {
            try
            {
                ProcessAccept(acceptSAEA);
                StartAccept(acceptSAEA);
            }
            catch (Exception exc)
            {
                Log.log(NetEngineMain.NETENGINE_DEBUG, exc.ToString());
            }
        }

        private void ProcessAccept(SocketAsyncEventArgs acceptSAEA)
        {
            if (acceptSAEA.SocketError != SocketError.Success)
            {
                // acceptSAEA.SocketError == SocketError.OperationAborted. This will happen for example when we close the listening 
                // socket inside the server Stop. We make sure then that accepting socket is cleaned up.
                acceptSAEA.AcceptSocket.Close();
            }
            else
            {
                if (mListeningSocket == null)
                    throw new NetEngineException("WTF");

                // If we are a policy server, message mode will be always string suffixed.
                NetPlug.MessageMode messageMode = mPolicyServerMode ? NetPlug.MessageMode.StringSuffixMode : NetPlug.MessageMode.BinaryPrefixMode;
                NetPlug newNetConnection = null;

                lock (mNetPlugsLock)
                {
                    // For the Policy Server, we add a BIG number to the ID just to make it easier to debug
                    newNetConnection = new NetPlug(this, mCumulativePlugs + (mPolicyServerMode ? 100000000 : 0), acceptSAEA.AcceptSocket, messageMode);

                    mNetPlugs.Add(newNetConnection);

                    if (mNetPlugs.Count > mMaxConcurrentPlugs)
                        mMaxConcurrentPlugs = mNetPlugs.Count;

                    mCumulativePlugs++;

                    Log.log(NetEngineMain.NETENGINE_DEBUG_BUFFER, "NetPlugs: " + mNetPlugs.Count + " Allocated: " + mBufferManager.AllocatedCount );
                }
                
                newNetConnection.Start();
            }
        }
        
        internal void OnConnectionClosed(NetPlug np)
        {
            lock (mNetPlugsLock)
            {
                mNetPlugs.Remove(np);
            }

            // One connection available!
            mMaxConnectionsEnforcer.Release();
        }

        public IList<NetPlug> GetNetPlugs()
        {
            lock (mNetPlugsLock)
            {
                return new List<NetPlug>(mNetPlugs);
            }
        }

        internal int Timestamp
        {
            get { return mTimestamp; }
        }

        public void GhostsCleanupThread()
        {
            try
            {
                List<NetPlug> dead = new List<NetPlug>();
                int currentIdx = 0;
                int i;
                
                while (true)
                {
                    lock (mNetPlugsLock)
                    {
                        // Only a bunch every time
                        for (i = currentIdx; i < currentIdx + 1000; i++)
                        {
                            if (i >= mNetPlugs.Count)
                            {
                                i = 0;  // Loop to mNetPlugs begin
                                break;
                            }

                            // No action in the last XX seconds => dead
                            if (mTimestamp - mNetPlugs[i].LastActionTimestamp >= GHOST_TIME)
                                dead.Add(mNetPlugs[i]);
                        }
                        currentIdx = i;
                    }

                    if (dead.Count != 0)
                        Log.log(NetEngineMain.NETENGINE_DEBUG, "There are dead NetPlugs: " + dead.Count);

                    foreach (NetPlug np in dead)
                        np.CloseRequest();
                    dead.Clear();
                 
                    // Another second (or so) goes...
                    Interlocked.Increment(ref mTimestamp);
                    Thread.Sleep(1000);
                }
            }
            catch (ThreadInterruptedException)
            {
                Log.log(NetEngineMain.NETENGINE_DEBUG, "GhostCleanupThread interrupted");
            }
            catch (Exception exc)
            {
                Log.log(NetEngineMain.NETENGINE_DEBUG, "GhostCleanupThread: " + exc.ToString());
            }
        }

        internal NetMessageHandler NetMessageHandler { get { return mNetMessageHandler; } }
        internal BufferManager BufferManager { get { return mBufferManager; } }

        readonly bool mPolicyServerMode;                // Our only use is to be an Adobe policy server 
        readonly INetClientApp mNetClientApp;

        readonly object mListeningSocketLock = new object();
        Socket mListeningSocket;
                
        readonly NetMessageHandler mNetMessageHandler;  // Only one instance to be used by all plugs
        readonly BufferManager mBufferManager;

        readonly object mNetPlugsLock = new object();
        readonly List<NetPlug> mNetPlugs = new List<NetPlug>();

        int mCumulativePlugs;           // Total accepted
        int mMaxConcurrentPlugs;        // Watermark, max simultaneous

        Thread mGhostsCleanupThread;
        int mTimestamp;

        DateTime mLastStartTime;
       
        readonly Semaphore mMaxConnectionsEnforcer;
    }
}
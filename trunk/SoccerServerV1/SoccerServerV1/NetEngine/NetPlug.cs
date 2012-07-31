using System;
using System.Net.Sockets;
using System.Threading;
using Weborb.Util.Logging;
using System.Net;
using System.Collections.Generic;

namespace SoccerServerV1.NetEngine
{
    /*
     * It represents a particular connection to a particular client, once the socket has been acepted.
     * Manages sends and receives.
     *
     * - TODO: I hate the way we Free the SAEAs.
     * - TODO: Socket exceptions.
     */
    public class NetPlug
    {
        public int ID
        { 
            get { return mID; }
        }

        public object UserData
        {
            get { return mUserData; }
            set { mUserData = value; }
        }

        public bool IsClosed
        {
            get
            {
                lock (mSocketLock)
                {
                    return mSocket == null;
                }
            }
        }

        public void Invoke(string methodName, params object[] args)
        {
            try
            {
                // From server to client we never want return
                SendBinaryPrefix(NetMessageHandler.GenerateInvoke(NextInvokationID, -1, false, methodName, args));
            }
            catch (Exception e)
            {
                Log.log(NetEngineMain.NETENGINE_DEBUG, e.ToString());
            }
        }

        public string RemoteAddress
        {
            get { return mRemoteAddress; }
        }

        internal NetPlug(NetServer netMain, int ID, Socket theSocket, MessageMode receiveMessageMode)
        {
            mNetServer = netMain;
            mSocket = theSocket;
            mRemoteAddress = (mSocket.RemoteEndPoint as IPEndPoint).Address.ToString();
            mReceiveMessageMode = receiveMessageMode;
            
            mID = ID;

            mReceived = new MessageHelper(new byte[mNetServer.BufferManager.MaxBufferSize]);
            mReceiveSAEA = new SocketAsyncEventArgs();
            mReceiveSAEA.Completed += new EventHandler<SocketAsyncEventArgs>(ReceiveSAEA_Completed);
            mNetServer.BufferManager.AllocBuffer(mReceiveSAEA);

            mSendSAEA = new SocketAsyncEventArgs();
            mSendSAEA.Completed += new EventHandler<SocketAsyncEventArgs>(SendSAEA_Completed);
            mNetServer.BufferManager.AllocBuffer(mSendSAEA);
            
            RefreshLastActionTimestamp();

            if (mRandomDelay != null)
                Log.log(NetEngineMain.NETENGINE_DEBUG, "====== Using network emulation delay ======");
        }

        internal enum MessageMode
        {
            BinaryPrefixMode,
            StringSuffixMode
        }

        internal MessageMode ReceiveMessageMode
        {
            // Inmmutable, we want to make our life easier by disallowing mode changes for the lifetime of the connection
            get { return mReceiveMessageMode; }
        }

        internal void Start()
        {
            if (IsClosed)
                throw new NetEngineException("NetPlug cannot be reused at the moment");

            mNetServer.NetMessageHandler.HandleConnectMessage(this);
            StartReceiving();
        }

        private void StartReceiving()
        {
            bool bDone = false;
            while (!bDone)
            {
                // At start and after every receive => we aren't ghosts
                RefreshLastActionTimestamp();

                lock (mSocketLock)
                {
                    if (IsClosed)
                    {
                        Log.log(NetEngineMain.NETENGINE_DEBUG_BUFFER, "StartReceiving(): FREEOP" + ID);

                        // We won't reenter a ReceiveAsync => free resources
                        mNetServer.BufferManager.FreeBuffer(mReceiveSAEA);
                        bDone = true;
                    }
                    else
                    {
                        if (mSocket.ReceiveAsync(mReceiveSAEA))
                            bDone = true;
                    }
                } 
                
                if (!bDone)
                    ProcessReceive(mReceiveSAEA);
            }
        }
      
        private void ReceiveSAEA_Completed(object sender, SocketAsyncEventArgs e)
        {
            if (mRandomDelay != null)
                System.Threading.Thread.Sleep(mRandomDelay.Next(500));

            try
            {
                ProcessReceive(mReceiveSAEA);
                StartReceiving();
            }
            catch (Exception exc)
            {
                Log.log(NetEngineMain.NETENGINE_DEBUG, exc.ToString());

                // Any bad behaviour from the client => we disconnect it
                CloseRequest();

                // We are sure that we won't call ReceiveAsync again. SAEA.SetBuffer(null, 0, 0) causes 
                // an exception inside the Native PerformIOCompletion if we are still waiting for a ReceiveAsync.
                mNetServer.BufferManager.FreeBuffer(mReceiveSAEA);
            }
        }

        private void ProcessReceive(SocketAsyncEventArgs e)
        {
            if (e.BytesTransferred == 0 || e.SocketError != SocketError.Success)
            {
                Log.log(NetEngineMain.NETENGINE_DEBUG_THREADING, "Exiting through ProcessReceive " + ID + " - " + e.SocketError + " - " + e.BytesTransferred);

                // No data was received => Normal. The remote host closed the connection.
                // Socket error => Not normal. Close anyway.
                CloseRequest();
            }
            else
            {
                // While we are processing:  The SAEA won't be freed && The socket CAN be freed without problems
                if (mReceiveMessageMode == MessageMode.BinaryPrefixMode)
                    ProcessReceiveBinaryPrefixMode(e);
                else
                    ProcessReceiveStringSuffixMode(e);
            }
        }

        private void ProcessReceiveStringSuffixMode(SocketAsyncEventArgs e)
        {
            int idxToProcess = 0;
            while (idxToProcess != e.BytesTransferred)
            {
                mReceived.Msg[mReceived.BytesSoFar] = e.Buffer[e.Offset + idxToProcess];
                mReceived.BytesSoFar++;

                if (e.Buffer[e.Offset + idxToProcess] == 0)
                {
                    // Lock leaked!!! NetMessageHandlerPolicyServer.HandleStringMessage call backs here, but will be executed in the same thread.
                    mNetServer.NetMessageHandler.HandleStringMessage(this, mReceived.Msg, mReceived.BytesSoFar - 1);

                    // Reset message buffer
                    mReceived.BytesSoFar = 0;
                }
                idxToProcess++;
            }
        }

        private void ProcessReceiveBinaryPrefixMode(SocketAsyncEventArgs e)
        {
            int bytesProcessedSoFar = 0;
            int bytesRemainigToProcess = e.BytesTransferred; // e.BytesTransferred = bytesProcessedSoFar + bytesRemainigToProcess (It's just a Helper)

            while (bytesRemainigToProcess != 0)
            {
                if (mReceived.BytesSoFar < 4)    // message still in the header?
                {
                    int availableHeaderBytes = bytesRemainigToProcess >= 4 - mReceived.BytesSoFar ?
                                                4 - mReceived.BytesSoFar : bytesRemainigToProcess;

                    Buffer.BlockCopy(e.Buffer, e.Offset + bytesProcessedSoFar,                   // bytesProcessedSoFar -> pointer inside the buffer to current read pos
                                        mReceived.Msg, mReceived.BytesSoFar,
                                        availableHeaderBytes);

                    mReceived.BytesSoFar += availableHeaderBytes;
                    bytesProcessedSoFar += availableHeaderBytes;
                    bytesRemainigToProcess = e.BytesTransferred - bytesProcessedSoFar;
                }

                if (mReceived.BytesSoFar >= 4)
                {
                    int messageLength = BitConverter.ToInt32(mReceived.Msg, 0); // Includes the header

                    if (messageLength == 0)
                        throw new NetEngineException("The 0 length shit happened again");

                    // It happens, for instance, when the flash client tries to send the policy request to our regular NetServer.
                    if (messageLength < 0 || messageLength > mReceived.Msg.Length)
                        throw new NetEngineException("Message Length too big");

                    if (messageLength != 4) 
                    {
                        int availablePayloadBytes = bytesRemainigToProcess >= messageLength - mReceived.BytesSoFar ?
                                                    messageLength - mReceived.BytesSoFar : bytesRemainigToProcess;

                        Buffer.BlockCopy(e.Buffer, e.Offset + bytesProcessedSoFar,
                                         mReceived.Msg, mReceived.BytesSoFar,
                                         availablePayloadBytes);

                        mReceived.BytesSoFar += availablePayloadBytes;
                        bytesProcessedSoFar += availablePayloadBytes;
                        bytesRemainigToProcess = e.BytesTransferred - bytesProcessedSoFar;

                        if (mReceived.BytesSoFar == messageLength)
                        {
                            // Consume the message... lock leaked!!! but no problem because HandleBinaryMessage doesn't call anywhere relevant
                            mNetServer.NetMessageHandler.HandleBinaryMessage(this, mReceived.Msg, mReceived.BytesSoFar);

                            // New message
                            mReceived.BytesSoFar = 0;
                        }
                    }
                    else
                    {
                        Log.log(NetEngineMain.NETENGINE_DEBUG_KEEPALIVE, "Keep alive from NetPlug: " + ID);

                        // The message was a Keep-Alive => next
                        mReceived.BytesSoFar = 0;
                    }
                }
            }
        }

        public void CloseRequest()
        {
            try
            {
                lock (mSocketLock)
                {
                    if (IsClosed)
                        return;

                    Log.log(NetEngineMain.NETENGINE_DEBUG_THREADING, "Exiting through CloseRequest " + ID);
                    
                    try
                    {
                        // http://msdn.microsoft.com/en-us/library/system.net.sockets.socket.shutdown.aspx
                        mSocket.Shutdown(SocketShutdown.Both);
                    }
                    catch (Exception ex)
                    {
                        Log.log(NetEngineMain.NETENGINE_DEBUG, "Exception: " + ex.ToString());
                    }
                    finally
                    {
                        // Close doesn't throw, according to the docs
                        mSocket.Close();
                        
                        // We use this value set to null to indicate it has been closed. Internal state is left as it was, we don't care, the Netplug
                        // can't be reused. If you are going to implement the NetPlug pool, you need to Reset values here.
                        mSocket = null;
                    }
                }

                lock (mSendLock)
                {
                    // No pending operation, time to free resources
                    if (mSendSAEA.UserToken == null)
                    {
                        Log.log(NetEngineMain.NETENGINE_DEBUG_BUFFER, "CloseRequest(): FREEOP" + ID);
                        mNetServer.BufferManager.FreeBuffer(mSendSAEA);
                        mSendQueue.Clear();
                    }
                }

                // Push message to the client
                mNetServer.NetMessageHandler.HandleDisconnectMessage(this);

                // There CAN be a closed connection in the server list, because we are NOT locked when we call here.
                // We do it this way because we don't want to leak the lock in order to avoid potential deadlocks.
                mNetServer.OnConnectionClosed(this);                
            }
            catch (Exception ex)
            {
                Log.log(NetEngineMain.NETENGINE_DEBUG, "Exception: " + ex.ToString());
            }
        }

        internal void SendStringSuffix(string msg)
        {
            // We allocate 1 additional byte for the Suffix delimiter (null)
            byte[] sendBuffer = new byte[msg.Length + 1];
            System.Text.Encoding.UTF8.GetBytes(msg, 0, msg.Length, sendBuffer, 0);

            StartSending(sendBuffer);
        }

        internal void SendBinaryPrefix(byte[] msg)
        {
            int messageLength = msg.Length + 4;
            byte[] sendBuffer = new byte[messageLength];
            Buffer.BlockCopy(System.BitConverter.GetBytes(messageLength), 0, sendBuffer, 0, 4);
            Buffer.BlockCopy(msg, 0, sendBuffer, 4, msg.Length);

            StartSending(sendBuffer);
        }
    
        private void StartSending(byte[] msg)
        {
            if (mRandomDelay != null)
                System.Threading.Thread.Sleep(mRandomDelay.Next(500));

            var helper = new MessageHelper(msg);

            lock (mSendLock)
            {
                if (IsClosed)
                    return;
                
                mSendQueue.Enqueue(helper);
                NextSendInQueue();
            }
        }

        private void NextSendInQueue()
        {
            while (mSendQueue.Count > 0 && mSendSAEA.UserToken == null)
            {
                // We use the UserToken to store the pending operation
                mSendSAEA.UserToken = mSendQueue.Dequeue();
                SendUntilDoneOrPending();
            }
        }

        private void SendUntilDoneOrPending()
        {
            var helper = mSendSAEA.UserToken as MessageHelper;

            while (mSendSAEA.UserToken != null && helper.RemainingBytes > 0)
            {
                int bytesToSend = helper.RemainingBytes > mNetServer.BufferManager.MaxBufferSize ?
                                  mNetServer.BufferManager.MaxBufferSize : helper.RemainingBytes;

                mSendSAEA.SetBuffer(mSendSAEA.Offset, bytesToSend);

                Buffer.BlockCopy(helper.Msg, helper.BytesSoFar, mSendSAEA.Buffer, mSendSAEA.Offset, bytesToSend);

                lock (mSocketLock)
                {
                    if (IsClosed)
                    {
                        // Stop all ulterior processing
                        mSendSAEA.UserToken = null;
                        mSendQueue.Clear();
                    }
                    else
                    {
                        if (mSocket.SendAsync(mSendSAEA))
                            return;
                        else
                            ProcessSend();
                    }
                }
            }
        }

        private void ProcessSend()
        {
            if (mSendSAEA.SocketError != SocketError.Success || mSendSAEA.BytesTransferred == 0)
            {
                Log.log(NetEngineMain.NETENGINE_DEBUG_THREADING, "Exiting through ProcessSend " + ID + " - " + mSendSAEA.SocketError + " - " + mSendSAEA.BytesTransferred);

                // We leave the Receive process in charge of the CloseRequest
                mSendSAEA.UserToken = null;
                mSendQueue.Clear();
            }
            else
            {
                if (mSendSAEA.BytesTransferred != mSendSAEA.Count)
                    throw new NetEngineException("Shouldn't happen");

                MessageHelper helper = mSendSAEA.UserToken as MessageHelper;
                helper.BytesSoFar += mSendSAEA.BytesTransferred;

                // This is the way we signal that the current op has ended
                if (helper.RemainingBytes == 0)
                    mSendSAEA.UserToken = null;
            }
        }

        private void SendSAEA_Completed(object sender, SocketAsyncEventArgs sendSAEA)
        {
            try
            {
                lock (mSendLock)
                {
                    lock (mSocketLock)
                    {
                        if (IsClosed && mSendSAEA.UserToken != null)
                        {
                            Log.log(NetEngineMain.NETENGINE_DEBUG_BUFFER, "SendSAEA_Completed: FREEOP" + ID);

                            // CloseRequest couldn't free resources because there was a pending operation. Time to free ourselves.
                            mNetServer.BufferManager.FreeBuffer(mSendSAEA);
                            mSendQueue.Clear();

                            // We leave UserToken there so that we don't delete again if CloseRequest is waiting for mSendLock. I hate this.
                            return;
                        }
                    }

                    ProcessSend();
                    SendUntilDoneOrPending();
                    NextS
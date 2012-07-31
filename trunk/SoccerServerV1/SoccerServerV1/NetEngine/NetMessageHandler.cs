using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Threading;
using System.Collections;
using Weborb.Util.Logging;
using System.Reflection;
using Weborb.Reader;
using Weborb.Types;

namespace SoccerServerV1.NetEngine
{
    internal class NetMessageHandler
    {
        internal void Start(NetServer netServer)
        {
            if (mMessageThread != null)
                throw new NetEngineException("WTF: Need to call Stop first");

            mClientApp = netServer.NetClientApp;

            // If we don't have a client app, we don't bother starting the pumping thread
            if (mClientApp != null)
            {
                mClientApp.OnAppStart(netServer);

                mAbortRequested = false;
                mMessageThread = new Thread(new ThreadStart(MessageProcessingThread));
                mMessageThread.Name = "MessageProcessingThread";
                mMessageThread.Start();
            }
        }

        internal void Stop()
        {
            lock (mMessageQueueLock)
            {
                mAbortRequested = true;

                // We need to release the thread, it is probably waiting
                mQueueNotEmptySignal.Set();
            }

            // Wait until all the remaining messages are processed
            if (mMessageThread != null)
            {
                mMessageThread.Join();
                mMessageThread = null;
            }

            lock (mMessageQueueLock)
            {
                if (mMessageQueue.Count != 0)
                {
                    // Shouldn't happen. The NetServer called CloseRequest on the NetPlugs, all the OnClientLeft must be processed, no
                    // more messages should arrive after the CloseRequests calls
                    Log.log(NetEngineMain.NETENGINE_DEBUG, "WTF: Messages lost!");
                }
            }
        }

        private void MessageProcessingThread()
        {
            try
            {
                bool bAbort = false;
                while (!bAbort)
                {
                    mQueueNotEmptySignal.WaitOne();

                    List<QueuedNetInvokeMessage> messagesToProcess = null;

                    lock (mMessageQueueLock)
                    {                        
                        // Between the WaitOne and the lock there could have been a million Sets and message Adds
                        messagesToProcess = new List<QueuedNetInvokeMessage>(mMessageQueue);
                        mMessageQueue.Clear();
                        mQueueNotEmptySignal.Reset();

                        // By signaling here we make sure that we make another pass to the loop below and process the final messages
                        if (mAbortRequested)
                            bAbort = true;
                    }

                    // Process pending messages
                    foreach (QueuedNetInvokeMessage msg in messagesToProcess)
                    {
                        InvokeNetClientApp(msg);
                    }
                }

                mClientApp.OnAppEnd();
                mClientApp = null;
            }
            catch (Exception e)
            {
                Log.log(NetEngineMain.NETENGINE_DEBUG, e.ToString());
            }
        }

        private void InvokeNetClientApp(QueuedNetInvokeMessage msg)
        {
            Type t = mClientApp.GetType();

            try
            {
                // We wait until we know the possible method signature in order to do the final adaptation
                MethodInfo info = t.GetMethod(msg.MethodName);

                if (info == null)
                    throw new NetEngineException("Unknown method: " + msg.MethodName);

                ParameterInfo[] parametersInfo = info.GetParameters();

                // First parameter always the NetPlug
                if (parametersInfo.Length == 0 || parametersInfo[0].ParameterType != msg.Source.GetType())
                    throw new NetEngineException("Incorrect method signature: " + msg.MethodName);

                if ((msg.Params == null && parametersInfo.Length != 1) ||
                    (msg.Params != null && parametersInfo.Length != msg.Params.Length + 1))
                    throw new NetEngineException("Incorrect number of parameters: " + msg.MethodName);

                object[] finalParams = new object[parametersInfo.Length];
                finalParams[0] = msg.Source;

                for (int c = 1; c < parametersInfo.Length; c++)
                {
                    IAdaptingType adapting = (msg.Params.GetValue(c - 1) as IAdaptingType);
                    Type targetType = parametersInfo[c].ParameterType;

                    if (!adapting.canAdaptTo(targetType))
                        throw new NetEngineException("Incorrect parameter type: " + msg.MethodName);

                    finalParams[c] = adapting.adapt(targetType);
                }

                object ret = info.Invoke(mClientApp, finalParams);

                // Handle the return for the Invoke
                if (msg.WantsReturn)
                {
                    msg.Source.SendBinaryPrefix(GenerateInvoke(msg.InvokationID, msg.Source.NextInvokationID, false, msg.MethodName, ret));
                }
            }
            catch (NetEngineException exc)
            {
                Log.log(NetEngineMain.NETENGINE_DEBUG, exc.ToString());

                // Any bad behaviour from the client => we disconnect it
                msg.Source.CloseRequest();
            }
            catch (Exception e)
            {
                Log.log(NetEngineMain.NETENGINE_DEBUG, e.ToString());
            }
        }

        virtual internal void HandleStringMessage(NetPlug from, byte[] theString, int stringLength)
        {
            throw new NetEngineException("Not implemented");
        }

        virtual internal void HandleBinaryMessage(NetPlug from, byte[] message, int messageLength)
        {
            // If we don't have a clientApp, we don't need to enqueue messsages
            if (mClientApp == null)
                return;

            // If weborb supported an offset param, we could skip this copy
            byte[] intermediate = new byte[messageLength - 4];
            Buffer.BlockCopy(message, 4, intermediate, 0, messageLength - 4);
            object netInvokeMessage = Weborb.Util.AMFSerializer.DeserializeFromBytes(intermediate, true);
           
            var newMessage = AdaptNetInvokeMessage(from, netInvokeMessage);

            if (newMessage == null)
                throw new NetEngineException("Invalid message received");
            
            lock (mMessageQueueLock)
            {
                mMessageQueue.Add(newMessage);
                mQueueNotEmptySignal.Set();
            }
        }

        internal void HandleConnectMessage(NetPlug from)
        {
            if (mClientApp == null)
                return;

            var newMessage = new QueuedNetInvokeMessage(from, from.NextInvokationID, -1, false, "OnClientConnected", null);

            lock (mMessageQueueLock)
            {
                mMessageQueue.Add(newMessage);
                mQueueNotEmptySignal.Set();
            }
        }

        internal void HandleDisconnectMessage(NetPlug from)
        {
            if (mClientApp == null)
                return;

            var newMessage = new QueuedNetInvokeMessage(from, from.NextInvokationID, -1, false, "OnClientLeft", null);

            lock (mMessageQueueLock)
            {
                mMessageQueue.Add(newMessage);
                mQueueNotEmptySignal.Set();
            }
        }

        static private QueuedNetInvokeMessage AdaptNetInvokeMessage(NetPlug from, object netInvokeMessage)
        {
            AnonymousObject theObject = netInvokeMessage as AnonymousObject;

            if (theObject == null)
                return null;

            NumberObject invokationID = theObject.Properties["InvokationID"] as NumberObject;
            NumberObject returnID = theObject.Properties["ReturnID"] as NumberObject;
            BooleanType wantsReturn = theObject.Properties["WantsReturn"] as BooleanType;
            StringType methodName = theObject.Properties["MethodName"] as StringType;
            ArrayType paramsArray = theObject.Properties["Params"] as ArrayType;

            if (invokationID == null || returnID == null || wantsReturn == null || 
                methodName == null || paramsArray == null)
                return null;

            // We leave the params as IAdaptingType. We will adapt them when we know the actual types of the method we are calling.
            return new QueuedNetInvokeMessage(from, (int)invokationID.defaultAdapt(), (int)returnID.defaultAdapt(), 
                                              (bool)wantsReturn.defaultAdapt(), (string)methodName.defaultAdapt(), paramsArray.getArray() as Array);
        }

        static internal byte[] GenerateInvoke(int invokationID, int retID, bool w, string methodName, params object[] p)
        {
            var sendMe = new NetInvokeMessage(invokationID, retID, w, methodName, p);
            return Weborb.Util.AMFSerializer.SerializeToBytes(sendMe);
        }

        bool mAbortRequested = false;
        Thread mMessageThread;
        INetClientApp mClientApp;

        readonly object mMessageQueueLock = new object();
        readonly List<QueuedNetInvokeMessage> mMessageQueue = new List<QueuedNetInvokeMessage>();

        readonly ManualResetEvent mQueueNotEmptySignal = new ManualResetEvent(false);

        private class NetInvokeMessage
        {
            readonly public int    InvokationID;   // Call ID assigned from the invoker
            readonly public int    ReturnID;       // Call ID assigned from the returner, if there is return. -1 in the first trip.
            readonly public bool   WantsReturn;    // Does the invoker want return?
            readonly public string MethodName;
            readonly public Array  Params;

            public NetInvokeMessage(int invID, int retID, bool w, string f, Array p)
            {
                InvokationID = invID; ReturnID = retID; WantsReturn = w; MethodName = f; Params = p;
            }
        }

        // Used only to store in the message queue in order to send to the INetClientApp
        private class QueuedNetInvokeMessage
        {
            readonly public NetPlug Source;

            readonly public int  InvokationID;
            readonly public int  ReturnID;
            readonly public bool WantsReturn;
            readonly public string MethodName;
            readonly public Array Params;       // IAdaptingType(s)

            public QueuedNetInvokeMessage(NetPlug src, int invID, int retID, bool w, string f, Array p)
            {
                Source = src; InvokationID = invID; ReturnID = retID; WantsReturn = w; MethodName = f; Params = p;
            }
        }
    }

}
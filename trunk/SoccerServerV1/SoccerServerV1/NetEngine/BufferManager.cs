using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Net.Sockets;
using Weborb.Util.Logging;

namespace SoccerServerV1.NetEngine
{
    class BufferManager
    {
        // This class creates a single large buffer which can be divided up 
        // and assigned to SocketAsyncEventArgs objects for use with each 
        // socket I/O operation.  
        // This enables buffers to be easily reused and guards against 
        // fragmenting heap memory.
        // 
        //This buffer is a byte array which the Windows TCP buffer can copy its data to.


        public BufferManager(Int32 numSAEAs, Int32 totalBufferBytesInEachSaeaObject)
        {
            this.totalBytesInBufferBlock = totalBufferBytesInEachSaeaObject*numSAEAs;
            this.currentIndex = 0;
            this.bufferBytesAllocatedForEachSaea = totalBufferBytesInEachSaeaObject;
            this.freeIndexPool = new Stack<int>();
            this.bufferBlock = new byte[totalBytesInBufferBlock];
        }

        internal void Reset()
        {
            lock (mSyncLock)
            {
                this.freeIndexPool = new Stack<int>();
                this.currentIndex = 0;
            }
        }

        // Divide that one large buffer block out to each SocketAsyncEventArg object.
        // Assign a buffer space from the buffer block to the specified SocketAsyncEventArgs object.
        internal void AllocBuffer(SocketAsyncEventArgs args)
        {
            lock (mSyncLock)
            {
                if (this.freeIndexPool.Count > 0)
                {
                    //This if-statement is only true if you have called the FreeBuffer
                    //method previously, which would put an offset for a buffer space 
                    //back into this stack.
                    args.SetBuffer(this.bufferBlock, this.freeIndexPool.Pop(), this.bufferBytesAllocatedForEachSaea);
                }
                else
                {
                    if ((totalBytesInBufferBlock - this.bufferBytesAllocatedForEachSaea) < this.currentIndex)
                        throw new NetEngineException("WTF: Out of memory");

                    args.SetBuffer(this.bufferBlock, this.currentIndex, this.bufferBytesAllocatedForEachSaea);
                    this.currentIndex += this.bufferBytesAllocatedForEachSaea;
                }
            }
        }

        internal int MaxBufferSize 
        { 
            get { return this.bufferBytesAllocatedForEachSaea; } 
        }

        // Removes the buffer from a SocketAsyncEventArg object.   This frees the
        // buffer back to the buffer pool. Try NOT to use the FreeBuffer method,
        // unless you need to destroy the SAEA object, or maybe in the case
        // of some exception handling. Instead, on the server
        // keep the same buffer space assigned to one SAEA object for the duration of
        // this app's running.
        internal void FreeBuffer(SocketAsyncEventArgs args)
        {
            lock (mSyncLock)
            {
                if (this.freeIndexPool.Contains(args.Offset))
                    throw new NetEngineException("OMG");

                this.freeIndexPool.Push(args.Offset);
                args.SetBuffer(null, 0, 0);
            }
        }

        internal int AllocatedCount
        {
            get
            {
                lock (mSyncLock)
                {
                    return (this.currentIndex / this.bufferBytesAllocatedForEachSaea) - this.freeIndexPool.Count;
                }
            }
        }

        internal void LogMemoryStats()
        {
            Log.log(NetEngineMain.NETENGINE_DEBUG, "Free index pool: " + this.freeIndexPool.Count);
            Log.log(NetEngineMain.NETENGINE_DEBUG, "Free remaining SAEAs: " + ((totalBytesInBufferBlock - currentIndex) / bufferBytesAllocatedForEachSaea).ToString());
        }

        readonly Int32 totalBytesInBufferBlock;
        readonly byte[] bufferBlock;
        readonly Int32 bufferBytesAllocatedForEachSaea;
        
        readonly object mSyncLock = new object();

        Stack<int> freeIndexPool;
        Int32 currentIndex;        
    }
}
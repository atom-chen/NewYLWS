//#define LOG_SEND_BYTES
//#define LOG_RECEIVE_BYTES
using System;
using System.Net.Sockets;
using CustomDataStruct;
using System.Threading;
using System.Collections.Generic;
using XLua;

namespace Networks
{
    public enum SOCKSTAT
    {
        CLOSED = 0,
        CONNECTING,
        CONNECTED,
    }

    [Hotfix]
    public class HjTcpNetwork
    {
        public Action<object, int, string> OnConnect = null;
        public Action<object, int, string> OnClosed = null;
        public Action<byte[]> ReceivePkgHandle = null;

        private List<HjNetworkEvt> mNetworkEvtList = null;
        private object mNetworkEvtLock = null;

        protected int mMaxBytesOnceSent = 0;
        protected int mMaxReceiveBuffer = 0;

        protected Socket mClientSocket = null;
        protected string mIp;
        protected int mPort;
        protected volatile SOCKSTAT mStatus = SOCKSTAT.CLOSED;


        private Thread mReceiveThread = null;
        private volatile bool mReceiveWork = false;
        private List<byte[]> mTempMsgList = null;
        protected IMessageQueue mReceiveMsgQueue = null;

        private Thread mSendThread = null;
        private volatile bool mSendWork = false;
        private HjSemaphore mSendSemaphore = null;

        protected IMessageQueue mSendMsgQueue = null;

        public HjTcpNetwork(int maxBytesOnceSent = 1024 * 1024 * 2, int maxReceiveBuffer = 1024 * 1024 * 2)
        {
            mStatus = SOCKSTAT.CLOSED;

            mMaxBytesOnceSent = maxBytesOnceSent;
            mMaxReceiveBuffer = maxReceiveBuffer;

            mNetworkEvtList = new List<HjNetworkEvt>();
            mNetworkEvtLock = new object();
            mTempMsgList = new List<byte[]>();
            mReceiveMsgQueue = new MessageQueue();

            mSendSemaphore = new HjSemaphore();
            mSendMsgQueue = new MessageQueue();
        }

        public void Dispose()
        {
            mSendMsgQueue.Dispose();
            Close();
        }

        public Socket ClientSocket
        {
            get
            {
                return mClientSocket;
            }
        }

        public void SetHostPort(string ip, int port)
        {
            mIp = ip;
            mPort = port;
        }
        public void Connect()
        {
            Close();

            int result = ESocketError.NORMAL;
            string msg = null;
            try
            {
                DoConnect();
            }
            catch (ObjectDisposedException ex)
            {
                result = ESocketError.ERROR_3;
                msg = ex.Message;
                mStatus = SOCKSTAT.CLOSED;
            }
            catch (Exception ex)
            {
                result = ESocketError.ERROR_4;
                msg = ex.Message;
                mStatus = SOCKSTAT.CLOSED;
            }
            finally
            {
                if (result != ESocketError.NORMAL && OnConnect != null)
                {
                    ReportSocketConnected(result, msg);
                }
            }
        }

        protected void DoConnect()
        {
            String newServerIp = "";
            AddressFamily newAddressFamily = AddressFamily.InterNetwork;
            IPv6SupportMidleware.getIPType(mIp, mPort.ToString(), out newServerIp, out newAddressFamily);
            if (!string.IsNullOrEmpty(newServerIp))
            {
                mIp = newServerIp;
            }

            mClientSocket = new Socket(newAddressFamily, SocketType.Stream, ProtocolType.Tcp);
            mClientSocket.BeginConnect(mIp, mPort, (IAsyncResult ia) =>
            {
                mClientSocket.EndConnect(ia);
                OnConnected();
            }, null);
            mStatus = SOCKSTAT.CONNECTING;
        }

        protected void OnConnected()
        {
            StartAllThread();
            mStatus = SOCKSTAT.CONNECTED;
            ReportSocketConnected(ESocketError.NORMAL, "Connect successfully");
        }
        public void Close()
        {
            if (mClientSocket == null) return;

            mStatus = SOCKSTAT.CLOSED;
            try
            {
                DoClose();
                ReportSocketClosed(ESocketError.ERROR_5, "Disconnected!");
            }
            catch (Exception e)
            {
                ReportSocketClosed(ESocketError.ERROR_4, e.Message);
            }
        }
        protected void DoClose()
        {
            mClientSocket.Close();
            if (mClientSocket.Connected)
            {
                throw new InvalidOperationException("Should close socket first!");
            }
            mClientSocket = null;
            StopAllThread();
        }

        public void Disconnect()
        {
            mStatus = SOCKSTAT.CLOSED;

            if (mClientSocket != null)
            {
                try
                {
                    mClientSocket.Close();
                }
                catch (Exception ex)
                {
                    Logger.LogError("socket close exception " + ex.Message + "\n" + ex.StackTrace);
                }

                ReportSocketClosed(ESocketError.ERROR_5, "Disconnected!");
            }
        }

        protected void ReportSocketConnected(int result, string msg)
        {
            if (OnConnect != null)
            {
                AddNetworkEvt(new HjNetworkEvt(this, result, msg, OnConnect));
            }
        }

        protected void ReportSocketClosed(int result, string msg)
        {
            if (OnClosed != null)
            {
                AddNetworkEvt(new HjNetworkEvt(this, result, msg, OnClosed));
            }
        }

        public void StartAllThread()
        {
            if (mReceiveThread == null)
            {
                mReceiveThread = new Thread(ReceiveThread);
                mReceiveWork = true;
                mReceiveThread.Start(null);
            }

            if (mSendThread == null)
            {
                mSendThread = new Thread(SendThread);
                mSendWork = true;
                mSendThread.Start(null);
            }
        }

        public void StopAllThread()
        {
            mReceiveMsgQueue.Dispose();

            if (mReceiveThread != null)
            {
                mReceiveWork = false;
                mReceiveThread.Join();
                mReceiveThread = null;
            }
            //先把队列清掉
            mSendMsgQueue.Dispose();

            if (mSendThread != null)
            {
                mSendWork = false;
                mSendSemaphore.ProduceResrouce();// 唤醒线程
                mSendThread.Join();// 等待子线程退出
                mSendThread = null;
            }
        }
        private void ReceiveThread(object o)
        {
            StreamBuffer receiveStreamBuffer = StreamBufferPool.GetStream(mMaxReceiveBuffer, false, true);
            int bufferCurLen = 0;
            while (mReceiveWork)
            {
                try
                {
                    if (!mReceiveWork) break;
                    if (mClientSocket != null)
                    {
                        int bufferLeftLen = receiveStreamBuffer.size - bufferCurLen;
                        int readLen = mClientSocket.Receive(receiveStreamBuffer.GetBuffer(), bufferCurLen, bufferLeftLen, SocketFlags.None);
                        if (readLen == 0) throw new ObjectDisposedException("DisposeEX", "receive from server 0 bytes,closed it");
                        if (readLen < 0) throw new Exception("Unknow exception, readLen < 0" + readLen);
                        
                        bufferCurLen += readLen;
                        DoReceive(receiveStreamBuffer, ref bufferCurLen);
                        if (bufferCurLen == receiveStreamBuffer.size)
                            throw new Exception("Receive from sever no enough buff size:" + bufferCurLen);
                    }
                }
                catch (ObjectDisposedException e)
                {
                    ReportSocketClosed(ESocketError.ERROR_3, e.Message);
                    break;
                }
                catch (Exception e)
                {
                    ReportSocketClosed(ESocketError.ERROR_4, e.Message);
                    break;
                }
            }

            StreamBufferPool.RecycleStream(receiveStreamBuffer);
            if (mStatus == SOCKSTAT.CONNECTED)
            {
                mStatus = SOCKSTAT.CLOSED;
            }
        }

        protected void AddNetworkEvt(HjNetworkEvt evt)
        {
            lock (mNetworkEvtLock)
            {
                mNetworkEvtList.Add(evt);
            }
        }

        public void UpdateNetwork()
        {
            UpdatePacket();
            UpdateEvt();
        }

        private void UpdateEvt()
        {
            lock (mNetworkEvtLock)
            {
                try
                {
                    for (int i = 0; i < mNetworkEvtList.Count; ++i)
                    {
                        HjNetworkEvt evt = mNetworkEvtList[i];
                        evt.evtHandle(evt.sender, evt.result, evt.msg);
                    }
                }
                catch (Exception e)
                {
                    Logger.LogError("Got the fucking exception :" + e.Message);
                }
                finally
                {
                    mNetworkEvtList.Clear();
                }
            }
        }
        private void SendThread(object o)
        {
            List<byte[]> workList = new List<byte[]>(10);

            while (mSendWork)
            {
                if (!mSendWork)
                {
                    break;
                }

                if (mClientSocket == null || !mClientSocket.Connected)
                {
                    continue;
                }

                mSendSemaphore.WaitResource();
                if (mSendMsgQueue.Empty())
                {
                    continue;
                }

                mSendMsgQueue.MoveTo(workList);
                try
                {
                    for (int k = 0; k < workList.Count; ++k)
                    {
                        var msgObj = workList[k];
                        if (mSendWork)
                        {
                            mClientSocket.Send(msgObj, msgObj.Length, SocketFlags.None);
                        }
                    }
                }
                catch (ObjectDisposedException e)
                {
                    ReportSocketClosed(ESocketError.ERROR_1, e.Message);
                    break;
                }
                catch (Exception e)
                {
                    ReportSocketClosed(ESocketError.ERROR_2, e.Message);
                    break;
                }
                finally
                {
                    for (int k = 0; k < workList.Count; ++k)
                    {
                        var msgObj = workList[k];
                        StreamBufferPool.RecycleBuffer(msgObj);
                    }
                    workList.Clear();
                }
            }
            
            if (mStatus == SOCKSTAT.CONNECTED)
            {
                mStatus = SOCKSTAT.CLOSED;
            }
        }

        protected void DoReceive(StreamBuffer streamBuffer, ref int bufferCurLen)
        {
            try
            {
                // 组包、拆包
                byte[] data = streamBuffer.GetBuffer();
                int start = 0;
                int leftLen = bufferCurLen - start;

                streamBuffer.ResetStream();
                while (true)
                {
                    if (leftLen < sizeof(int))
                    {
                        break;
                    }

                    int msgLen = BitConverter.ToInt32(data, start);
                    
                    if (leftLen < msgLen + sizeof(int))
                    {
                        break;
                    }

                    // 提取字节流，去掉开头表示长度的4字节
                    start += sizeof(int);
                    var bytes = streamBuffer.ToArray(start, msgLen);
#if LOG_RECEIVE_BYTES
                    var sb = new System.Text.StringBuilder();
                    for (int i = 0; i < bytes.Length; i++)
                    {
                        sb.AppendFormat("{0}\t", bytes[i]);
                    }
                    Logger.Log("HjTcpNetwork receive bytes : " + sb.ToString());
#endif
                    mReceiveMsgQueue.Add(bytes);

                    // 下一次组包
                    start += msgLen;

                    leftLen -= (msgLen + sizeof(int));
                }

                if (leftLen > 0)
                {
                    streamBuffer.CopyFrom(data, start, 0, leftLen);
                    bufferCurLen = leftLen;
                }
                else
                {
                    bufferCurLen = 0;
                }
            }
            catch (Exception ex)
            {
                Logger.LogError(string.Format("Tcp receive package err : {0}\n {1}", ex.Message, ex.StackTrace));
            }
        }
        private void UpdatePacket()
        {
            if (!mReceiveMsgQueue.Empty())
            {
                mReceiveMsgQueue.MoveTo(mTempMsgList);

                try
                {
                    for (int i = 0; i < mTempMsgList.Count; ++i)
                    {
                        var objMsg = mTempMsgList[i];
                        if (ReceivePkgHandle != null)
                        {
                            ReceivePkgHandle(objMsg);
                        }
                    }
                }
                catch (Exception e)
                {
                    Logger.LogError("Got the fucking exception :" + e.Message);
                }
                finally
                {
                    for (int i = 0; i < mTempMsgList.Count; ++i)
                    {
                        StreamBufferPool.RecycleBuffer(mTempMsgList[i]);
                    }
                    mTempMsgList.Clear();
                }
            }
        }
        public void SendMessage(byte[] msgObj)
        {
#if LOG_SEND_BYTES
            var sb = new System.Text.StringBuilder();
            for (int i = 0; i < msgObj.Length; i++)
            {
                sb.AppendFormat("{0}\t", msgObj[i]);
            }
            Logger.Log("HjTcpNetwork send bytes : " + sb.ToString());
#endif
            mSendMsgQueue.Add(msgObj);
            mSendSemaphore.ProduceResrouce();
        }

        public bool IsConnected()
        {
            return mStatus == SOCKSTAT.CONNECTED;
        }

        public bool IsConnecting()
        {
            return mStatus == SOCKSTAT.CONNECTING;
        }
    }

#if UNITY_EDITOR
    public static class HjTcpNetworkExporter
    {
        [LuaCallCSharp]
        public static List<Type> LuaCallCSharp = new List<Type>()
        {
            typeof(HjTcpNetwork),
        };

        [CSharpCallLua]
        public static List<Type> CSharpCallLua = new List<Type>()
        {
            typeof(Action<object, int, string>),
            typeof(Action<byte[]>),
        };
    }
#endif
}
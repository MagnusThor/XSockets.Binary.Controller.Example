using System;
using System.Diagnostics;
using XSockets.Core.Common.Socket;
using XSockets.Core.Common.Socket.Event.Arguments;
using XSockets.Plugin.Framework.Core.Attributes;
using XSockets.Plugin.Framework.Helpers;

namespace XSockets.DevServer
{
    public class DebugInstance
    {
        [ImportOne(typeof(IXBaseServerContainer))]
        public IXBaseServerContainer wss { get; set; }

        public DebugInstance()
        {
            try
            {
                Debug.AutoFlush = true;
                this.ComposeMe();
                
                //Note: ************************************************************************
                //Note: For high speed, run this in release mode. Events only for debug purpose
                //Note: ************************************************************************
                
                wss.OnServersStarted += wss_OnServersStarted;
                wss.OnServerClientConnection += wss_OnServerClientConnection;
                wss.OnServerClientDisconnection += wss_OnServerClientDisconnection;
                wss.OnError += wss_OnError;
                wss.OnIncommingTextData += wss_OnIncommingTextData;
                wss.OnOutgoingText += wss_OnOutgoingText;
                wss.OnServersStopped += wss_OnServersStopped;
                wss.StartServers();
            }
            catch (Exception ex)
            {
                Debug.WriteLine("Exception while starting server");
                Debug.WriteLine(ex.Message);
                Debug.WriteLine(ex.StackTrace);
                Debug.WriteLine("Press enter to quit");
            }
        }

        void wss_OnOutgoingText(object sender, TextArgs e)
        {
            Debug.WriteLine("");
            Debug.WriteLine("Outgoing TextMessage");
            Debug.WriteLine("Handler: " + ((IXBaseSocket)sender).Alias);
            Debug.WriteLine("Sender: " + ((IXBaseSocket)sender).XNode.ClientGuid);
            Debug.WriteLine("Event: " + e.@event);
            Debug.WriteLine("Data: " + e.data);
            Debug.WriteLine("");
        }

        void wss_OnIncommingTextData(object sender, TextArgs e)
        {
            Debug.WriteLine("");
            Debug.WriteLine("Incomming TextMessage");
            Debug.WriteLine("Handler: " + ((IXBaseSocket)sender).Alias);
            Debug.WriteLine("Sender: " + ((IXBaseSocket)sender).XNode.ClientGuid);
            Debug.WriteLine("Event: " + e.@event);
            Debug.WriteLine("Data: " + e.data);
            Debug.WriteLine("");            
        }

        void wss_OnError(object sender, OnErrorArgs e)
        {
            Debug.WriteLine("");
            Debug.WriteLine("Error");
            Debug.WriteLine("ExceptionMessage: " + e.Exception.Message);
            Debug.WriteLine("CustomMessage: " + e.Message);
            Debug.WriteLine("");
        }

        void wss_OnServerClientDisconnection(object sender, OnClientDisConnectArgs e)
        {
            Debug.WriteLine("");
            Debug.WriteLine("Disconnected");
            Debug.WriteLine("Handler: " + ((IXBaseSocket)sender).Alias);
            Debug.WriteLine("ClientGuid: " + e.XNode.ClientGuid);
            Debug.WriteLine("");
        }

        void wss_OnServerClientConnection(object sender, OnClientConnectArgs e)
        {
            Debug.WriteLine("");
            Debug.WriteLine("Connected");
            Debug.WriteLine("Handler: "+ ((IXBaseSocket)sender).Alias);
            Debug.WriteLine("ClientGuid: "+ e.XNode.ClientGuid);
            Debug.WriteLine("");
        }

        void wss_OnServersStarted(object sender, EventArgs e)
        {
            Debug.WriteLine("[XSockets Development Server]");
            Debug.WriteLine("[Servers Started]");

            Debug.WriteLine("_______________________XSOCKET HANDLERS_________________________________");
            foreach (var plugin in wss.XSocketFactory.Plugins)
            {
                Debug.WriteLine("Alias:\t\t" + plugin.Alias);
                Debug.WriteLine("BufferSize:\t" + plugin.BufferSize);
                Debug.WriteLine("PluginRange:\t" + plugin.PluginRange);
                Debug.WriteLine("Custom Events:");
                if (plugin.CustomEvents == null)
                    Debug.WriteLine("\tNone...");
                else
                    foreach (var customEventList in plugin.CustomEvents)
                        foreach (var customEvent in customEventList.Value)
                        {
                            Debug.WriteLine("\tMethodName:\t" + customEvent.MethodInfo.Name);
                            Debug.WriteLine("\tHandlerEvent:\t" + customEventList.Key);
                        }
                Debug.WriteLine("");
            }
            Debug.WriteLine("________________________________________________________________________");
            Debug.WriteLine("");
            Debug.WriteLine("_______________________XSOCKET PROTOCOLS________________________________");
            foreach (var plugin in wss.XSocketProtocolFactory.Protocols)
            {
                Debug.WriteLine("Identifier: " + plugin.ProtocolIdentifier);
            }
            Debug.WriteLine("________________________________________________________________________");
            Debug.WriteLine("");
            Debug.WriteLine("_______________________XSOCKET INTERCEPTORS_____________________________");
            foreach (var plugin in wss.MessageInterceptors)
            {
                Debug.WriteLine("Type: " + plugin.GetType().Name);
            }
            foreach (var plugin in wss.ConnectionInterceptors)
            {
                Debug.WriteLine("Type: " + plugin.GetType().Name);
            }
            foreach (var plugin in wss.HandshakeInterceptors)
            {
                Debug.WriteLine("Type: " + plugin.GetType().Name);
            }
            foreach (var plugin in wss.ErrorInterceptors)
            {
                Debug.WriteLine("Type: " + plugin.GetType().Name);
            }
            Debug.WriteLine("________________________________________________________________________");
        }

        void wss_OnServersStopped(object sender, EventArgs e)
        {
            Debug.WriteLine("");
            Debug.WriteLine("[XSockets Development Server]");
            Debug.WriteLine("[Servers Stopped]");
            Debug.WriteLine("");
        }
    }
}
using System;
using XSockets.Core.Common.Socket.Event.Arguments;
using XSockets.Core.XSocket;
using XSockets.Core.XSocket.Helpers;

namespace XSocketHandler
{
    public class MyCustomBinaryController : XSocketController
    {
        public MyCustomBinaryController()
        {
            this.OnIncommingBinary += MyCustomBinaryController_OnIncommingBinary;
            this.OnOutgoingBinary += MyCustomBinaryController_OnOutgoingBinary;
        }

        public override void IncommingBinary(XSockets.Core.Common.Socket.IXBaseSocket sender,
                                             XSockets.Core.Common.Socket.Event.Interface.IBinaryArgs e)
        {
            //  Just pass back the "blob" to the sender
            //  This is where you do stuff with the blob :-)

            this.Send(e);

            //this.SendToAll(e);  // Send the blob to all clients that subscribes to blobs on this Controller
        }

        private void MyCustomBinaryController_OnOutgoingBinary(object sender, BinaryArgs e)
        {
            //  If you want to send additional info, it can be done here aswell
        }

        private void MyCustomBinaryController_OnIncommingBinary(object sender,
                                                                XSockets.Core.Common.Socket.Event.Arguments.BinaryArgs e)
        {
            //  throw new System.NotImplementedException();
        }
    }
}

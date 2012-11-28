/*
* XSockets.NET jXSockets.fallback.2.0.0.js 
* http://xsockets.net/
* Distributed in whole under the terms of the MIT
 
*
* Copyright 2012, Magnus Thor & Ulf Björklund 
*
* Permission is hereby granted, free of charge, to any person obtaining
* a copy of this software and associated documentation files (the
* "Software"), to deal in the Software without restriction, including
 
* without limitation the rights to use, copy, modify, merge, publish,
* distribute, sublicense, and/or sell copies of the Software, and to
* permit persons to whom the Software is furnished to do so, subject to
* the following conditions:
 
*
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
* LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 
* OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
* WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
*/


if ("WebSocket" in window === false) {
    window.WebSocket = function (url, subprotocol) {
        $(window).bind('beforeunload', function () {
            self.close();
        });

        var self = this;
        this.client = {
            guid: null
        };
        this.handler = subprotocol;
        function getQueryStringParameter(qry, name) {
            if (typeof qry !== undefined && qry !== "") {
                var arr = qry.split("&");
                for (var i = 0; i < arr.length; i++) {
                    if (arr[i].indexOf(name) > -1) {
                        return arr[i].split("=")[1];
                    }
                }
            }
            return "";
        }
        this.MessageEvent = function (data) {
            return {
                type: "message",
                data: JSON.stringify(data)
            };
        };
        this.payload = function (data) {
            return {
                handler: self.handler,
                client: self.client.guid,
                Json: data
            };
        };
        this.listener = function () {
            return {
                handler: self.handler,
                client: self.client.guid
            };
        };
        this.readystate = 0;
        self.client.guid = getQueryStringParameter(url, "XSocketsClientStorageGuid");
        this.ajax("/Fallback/Init", "GET", {
            handler: self.handler,
            client: self.client.guid
        }, true, function (r) {
            self.client.guid = JSON.parse(r.data).ClientGuid;
            self.readyState = 1;
            self.onmessage(new self.MessageEvent(r));
            self.listen();
        });
        return this;
    };
    window.WebSocket.prototype.close = function () {
   this.ajax("/Fallback/Close", "GET", {
            client: self.client.guid
        }, true, function () {
        });
    };
    window.WebSocket.prototype.readyState = 0;
    window.WebSocket.prototype.send = function (data) {
        var msg = JSON.parse(data);
        if (msg.event == "xsockets.xnode.open") return;
        if (msg.event == "xsockets.unsubscribe") {
            this.ajax("/Fallback/Unind", "GET", {
                client: this.client.guid,
                event: JSON.parse(msg.data).Event
            }, true, function () { });
        } else if (msg.event == "xsockets.subscribe") {
            this.ajax("/Fallback/Bind", "GET", {
                client: this.client.guid,
                event: JSON.parse(msg.data).Event
            }, false,function () { });

        } else {
            this.ajax("/Fallback/Trigger", "POST", this.payload(data), false, function () { });
        }
    };
    window.WebSocket.prototype.close = function () {
        $.getJSON("/Fallback/Close", {
            client: this.client.guid
        }).done(function () {
            sessionStorage.clear();
        });
    };
    window.WebSocket.prototype.ajax = function (url, method, payload, async, callback) {
        var settings = {
            processData: true,
            dataType: "json",
            type: method,
            url: url,
            async: async,
            cache:false,
            success: callback,
            data: payload
        };
        $.ajax(settings);
    };
    window.WebSocket.prototype.onmessage = function (data) { };
    window.WebSocket.prototype.onerror = function (data) { };
    window.WebSocket.prototype.listen = function () {
        var self = this;
        this.ajax("/Fallback/Listen", "POST", this.listener(), true, function (messages) {
            $.each(messages, function (index, message) {
                self.onmessage(self.MessageEvent(message));
            });
            self.listen();
        });
    };

}
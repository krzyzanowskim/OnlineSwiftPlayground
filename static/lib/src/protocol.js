import { w3cwebsocket as W3CWebSocket } from "websocket";

class Protocol {
  constructor(ws) {
    ws.onopen = this.onOpen.bind(this);
    ws.onmessage = this.onMessage.bind(this);
    ws.onclose = this.onClose.bind(this);
    ws.onError = this.onClose.bind(this);
    this.ws = ws;
    this.processMessage = function(value, annotations) {};
  }

  onOpen() {
    let ws = this.ws;
    console.log("WebSocket Client Connected");
    if (ws.readyState === ws.OPEN) {
      //
    }
  }

  onMessage(e) {
    let ws = this.ws;
    if (typeof e.data === "string") {
      let command = JSON.parse(e.data);
      if (command.output.value !== undefined) {
        this.processMessage(command.output.value, command.output.annotations);
      }
    }
  }

  onClose(e) {
    console.log(
      "Socket is closed. Reconnect will be attempted in 20 second.",
      e.reason
    );
    setTimeout(function() {
      connect();
    }, 20000);
  }

  onError(err) {
    let ws = this.ws;
    console.error("Socket encountered error: Closing socket");
    ws.close();
  }

  static start() {
    let ws = new W3CWebSocket(
      "ws://" + location.host + "/terminal",
      "terminal"
    );
    return new Protocol(ws);
  }
}

export default Protocol;

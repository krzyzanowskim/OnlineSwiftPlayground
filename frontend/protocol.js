import { w3cwebsocket as W3CWebSocket } from "websocket";

class Protocol {
  constructor(ws) {
    ws.onopen = this.onOpen.bind(this);
    ws.onmessage = this.onMessage.bind(this);
    ws.onclose = this.onClose.bind(this);
    ws.onerror = this.onError.bind(this);
    this.ws = ws;
    this.processMessage = function(value, annotations) {};
  }

  onOpen() {
    let ws = this.ws;
    if (ws.readyState === ws.OPEN) {
      //
    }
  }

  onMessage(e) {
    let ws = this.ws;
    if (typeof e.data === "string") {
      try {
        let command = JSON.parse(e.data);
        if (command.output && command.output.value !== undefined) {
          this.processMessage(command.output.value, command.output.annotations);
        }
      } catch (err) {
        console.error("Failed to parse message:", err);
      }
    }
  }

  onClose(e) {
    console.log(
      "Socket is closed. Reconnect will be attempted in 20 second.",
      e.reason
    );
    setTimeout(() => {
      window.location.reload();
    }, 20000);
  }

  onError(err) {
    let ws = this.ws;
    ws.close();
  }

  static start() {
    let ws = new W3CWebSocket("wss://" + location.host + "/terminal");
    return new Protocol(ws);
  }
}

export default Protocol;

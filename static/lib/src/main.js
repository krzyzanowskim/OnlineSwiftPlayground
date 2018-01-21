// Copyright Marcin Krzyzanowski marcin@krzyzanowskim.com
import Playground from "./playground.js";
import { w3cwebsocket as W3CWebSocket } from "websocket";

function connect() {
  var ws = new W3CWebSocket("ws://" + location.host + "/terminal", "terminal");
  global.playground = new Playground(ws);

  ws.onopen = function() {
    console.log("WebSocket Client Connected");
    if (ws.readyState === ws.OPEN) {
      //
    }
  };

  ws.onmessage = function(e) {
    if (typeof e.data === "string") {
      let command = JSON.parse(e.data);
      if (command.output.value !== undefined) {
        playground.processOutput(
          command.output.value,
          command.output.annotations
        );
      }
    }
  };

  ws.onclose = function(e) {
    console.log(
      "Socket is closed. Reconnect will be attempted in 20 second.",
      e.reason
    );
    setTimeout(function() {
      connect();
    }, 20000);
  };

  ws.onerror = function(err) {
    console.error("Socket encountered error: Closing socket");
    ws.close();
  };
}

connect();

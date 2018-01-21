// Copyright Marcin Krzyzanowski marcin@krzyzanowskim.com
import React from "react";
import ReactDOM from "react-dom";
import MonacoEditor from "react-monaco-editor";
import { w3cwebsocket as W3CWebSocket } from "websocket";
import Playground from "./playground.js";

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

class Editor extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      code: "// type your code..."
    };
  }
  editorDidMount(editor, monaco) {
    console.log("editorDidMount", editor);
    editor.focus();
  }
  onChange(newValue, e) {
    console.log("onChange", newValue, e);
  }
  render() {
    const code = this.state.code;
    const options = {
      selectOnLineNumbers: true
    };
    const requireConfig = {
      paths: { vs: "/static/lib/bundle/vs" },
      url: "/static/lib/bundle/vs/loader.js"
    };
    return (
      <MonacoEditor
        language="javascript"
        theme="vs-dark"
        value={code}
        options={options}
        requireConfig={requireConfig}
      />
    );
  }
}

ReactDOM.render(<Editor />, document.getElementById("editor"));

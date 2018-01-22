// Copyright Marcin Krzyzanowski marcin@krzyzanowskim.com
import React from "react";
import ReactDOM from "react-dom";

import Protocol from "./protocol.js";
import Editor from "./editor.js";
import Playground from "./playground.js";

let startValue =
  Playground.restoreCode() !== null
    ? Playground.restoreCode()
    : document.getElementById("editor").textContent;

var editorComponent = ReactDOM.render(
  <Editor code={startValue} />,
  document.getElementById("editor")
);

var terminalComponent = ReactDOM.render(
  <Editor
    readOnly="true"
    code={document.getElementById("terminal").textContent}
  />,
  document.getElementById("terminal")
);

let protocol = Protocol.start();
let playground = new Playground(protocol, editorComponent.editor);

$("#run-button").click(function(e) {
  e.preventDefault();
  let sender = $(this);
  sender.prop("disabled", true);

  playground.run(editorComponent.getValue(), function(value, annotations) {
    console.log(value);
    terminalComponent.setValue(value);
    sender.prop("disabled", false);
    editorComponent.editor.focus();
  });
});

$("#logout-button").click(function(e) {
  e.preventDefault();
  window.location.href = "/logout";
});

$("#download-button").click(function(e) {
  let text = editor.getValue();
  this.href =
    "data:application/octet-stream;charset=UTF-8," + encodeURIComponent(text);
});

// editor.session.setAnnotations(
//   annotations.map(function(a) {
//     return {
//       row: a.location.row,
//       column: a.location.column,
//       text: a.description,
//       type: "error"
//     };
//   })
// );

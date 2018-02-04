// Copyright Marcin Krzyzanowski marcin@krzyzanowskim.com
import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import Clipboard from "clipboard";

import Protocol from "./protocol.js";
import Editor from "./editor.js";
import Output from "./output.js";
import Playground from "./playground.js";

// Render components

let startValue =
  Playground.restoreCode() !== null
    ? Playground.restoreCode()
    : document.getElementById("editor").innerText;

var editorComponent = ReactDOM.render(
  <Editor code={startValue} />,
  document.getElementById("editor")
);

var terminalComponent = ReactDOM.render(
  <Output
    readOnly={true}
    code={document.getElementById("terminal").textContent}
  />,
  document.getElementById("terminal")
);

// Main

new Clipboard(".btn");

let protocol = Protocol.start();
let playground = new Playground(protocol, editorComponent.editor);

// Install events
$("#run-button").click(function(e) {
  e.preventDefault();
  let sender = $(this);
  sender.prop("disabled", true);

  playground.run(editorComponent.getValue(), function(value, annotations) {
    terminalComponent.setValue(value);
    sender.prop("disabled", false);
    editorComponent.editor.focus();
  });
});

$("#download-file-button").click(function(e) {
  let text = editorComponent.getValue();
  $(this).attr(
    "href",
    "data:application/octet-stream;charset=UTF-8," + encodeURIComponent(text)
  );
});

$("#download-playground-button").click(function(e) {
  e.preventDefault();

  let text = editorComponent.getValue();

  // Build a form
  var form = $("<form></form>")
    .attr("action", "/download")
    .attr("method", "post");
  // Add the one key/value
  form.append(
    $("<input></input>")
      .attr("type", "hidden")
      .attr("name", "code")
      .attr("value", text)
  );
  //send request
  form
    .appendTo("body")
    .submit()
    .remove();
});

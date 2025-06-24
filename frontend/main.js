// Copyright Marcin Krzyzanowski marcin@krzyzanowskim.com
import React from "react";
import ReactDOM from "react-dom";
import $ from "jquery";

import Clipboard from "clipboard";

import Protocol from "./protocol.js";
import Editor from "./editor.js";
import SwiftVersion from "./swift-versions.js";
import Output from "./output.js";
import Playground from "./playground.js";


// let swiftVersionElement = (
//   <SwiftVersion />
// );

// Render components

let swiftVersionComponent = ReactDOM.render(
  <SwiftVersion />,
  document.getElementById("swift-versions")
);

let editorComponent = ReactDOM.render(
  <Editor commandHandler = {dispatchEvaluationRequest}/>,
  document.getElementById("editor")
);

let terminalComponent = ReactDOM.render(
  <Output readOnly={true} code={document.getElementById("terminal").textContent}/>,
  document.getElementById("terminal")
);

// Main

new Clipboard(".btn");

let protocol = Protocol.start();
let playground = new Playground(protocol, editorComponent.editor || null);

// Install events
$("#run-button").click(function (e) {
  e.preventDefault();
  dispatchEvaluationRequest();
});

function dispatchEvaluationRequest() {
  let sender = $("#run-button");
  sender.prop("disabled", true);

  playground.run(editorComponent.getValue(), swiftVersionComponent.currentVersion, function (value, annotations) {
    terminalComponent.setValue(value);
    sender.prop("disabled", false);
    if (editorComponent.editor) {
      editorComponent.editor.focus();
    }
  });
}

$("#download-file-button").click(function (e) {
  let text = editorComponent.getValue();
  $(this).attr(
    "href",
    "data:application/octet-stream;charset=UTF-8," + encodeURIComponent(text)
  );
});

$("#download-playground-button").click(function (e) {
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

let searchParams = new URLSearchParams(window.location.search);
let sourceURL = searchParams.get("sourceURL");
if (sourceURL !== null) {
  fetch(sourceURL)
    .then(response => response.text())
    .then(body => {
      editorComponent.setValue(body);
    })
    .catch(err => {
      console.error("Failed to load source from URL:", err);
      editorComponent.setValue(`import Foundation\n\nprint("Hello World")`);
    });
} else {
  let restoredCode = Playground.restoreCode();
  let exampleCode = `import Foundation

print("Hello World")`

  editorComponent.setValue(restoredCode !== null ? restoredCode : exampleCode);
}

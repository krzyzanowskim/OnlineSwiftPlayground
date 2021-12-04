// Copyright Marcin Krzyzanowski marcin@krzyzanowskim.com
import $ from "jquery";

export default class Playground {
  constructor(protocol, editor) {
    this.protocol = protocol;
    this.editor = editor;
  }

  static restoreCode() {
    let storage = window.sessionStorage;
    let loadedCode = storage.getItem("editor-text");
    if (loadedCode !== null) {
      return loadedCode;
    }
    return null;
  }

  static storeCode(code) {
    let storage = window.sessionStorage;
    storage.setItem("editor-text", code);
  }

  run(code, toolchainVersion, onFinish) {
    var msg = {
      run: {
        toolchain: toolchainVersion,
        value: code
      }
    };

    Playground.storeCode(code);

    this.protocol.ws.send(JSON.stringify(msg));
    this.protocol.processMessage = function (value, annotations) {
      onFinish(value, annotations);
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
    };
  }
}
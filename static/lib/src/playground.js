// Copyright Marcin Krzyzanowski marcin@krzyzanowskim.com

function Playground(ws) {
  this.ws = ws;
  this.outputCallback = function(text, annotations) {};

  this.runSwiftCode = function(codeString, callback) {
    var msg = {
      run: {
        value: codeString
      }
    };
    this.ws.send(JSON.stringify(msg));
    this.outputCallback = callback;
  };

  this.processOutput = function(outputText, annotations) {
    let resultsEditor = $("#results-editor");
    this.outputCallback(outputText, annotations) || function() {};
    this.outputCallback = null;
    return outputText;
  };
}

module.exports = Playground;

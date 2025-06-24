import React from "react";
import ReactDOM from "react-dom";
import MonacoEditor from "react-monaco-editor";
import $ from "jquery";

class Editor extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      code: props.code,
      readOnly: props.readOnly,
      showLines: !props.readOnly,
      language: props.readOnly == true ? "plaintext" : "swift",
	  commandHandler: props.commandHandler,
    };
    
    this.updateDimensions = this.updateDimensions.bind(this);
  }

  updateDimensions() {
    this.editor.layout();
  }

  editorDidMount(editor, monaco) {
    this.editor = editor;
	editor.addCommand(monaco.KeyMod.CtrlCmd | monaco.KeyCode.Enter, this.state.commandHandler);

    $.getJSON("/static/assets/json/snippets.json", function(snippets) {
      if (!monaco || !monaco.languages) return;
      monaco.languages.registerCompletionItemProvider("swift", {
        provideCompletionItems: function(model, position) {
          var textUntilPosition = model.getValueInRange({
            startLineNumber: 1,
            startColumn: 1,
            endLineNumber: position.lineNumber,
            endColumn: position.column
          });
          return snippets;
        }
      });
    });

    window.addEventListener("resize", this.updateDimensions);
  }

  componentWillUnmount() {
    window.removeEventListener("resize", this.updateDimensions);
  }

  getValue() {
    if (this.editor && this.editor.getModel()) {
      return this.editor.getModel().getValue();
    }
    return "";
  }

  setValue(value) {
    if (this.editor && this.editor.getModel()) {
      this.editor.getModel().setValue(value);
    }
  }

  onChange(newValue, e) {
    // console.log("onChange", newValue, e);
  }

  render() {
    let code = this.state.code;
    // https://microsoft.github.io/monaco-editor/api/interfaces/monaco.editor.ieditoroptions.html
    let options = {
      minimap: { enabled: false },
      cursorStyle: "block",
      cursorBlinking: "blink",
      folding: true,
      showFoldingControls: "mouseover",
      fontSize: 14,
      formatOnPaste: true,
      formatOnType: false,
      readOnly: this.state.readOnly,
      renderIndentGuides: true,
      scrollbar: {
        verticalHasArrows: true,
        useShadows: false
      },
      renderLineHighlight: "none",
      renderControlCharacters: true,
      scrollBeyondLastLine: false,
      selectOnLineNumbers: true,
      selectionClipboard: false,
      selectionHighlight: false,
      // snippetSuggestions: "bottom",
      // acceptSuggestionOnEnter: true,
      suggestOnTriggerCharacters: false,
      wordBasedSuggestions: false,
      // quickSuggestions: false,
      //parameterHints: false,
      // quickSuggestions: {
      //   other: false,
      //   comments: false,
      //   strings: false
      // },
      lightbulb: { enabled: true },
      matchBrackets: true,
      autoClosingBrackets: false,
      automaticLayout: false,
      autoIndent: true,
      lineNumbers: this.state.showLines,
      contextmenu: false,
      dragAndDrop: this.state.showLines
    };
    return (
      <MonacoEditor
        language={this.state.language}
        theme="vs-dark"
        value={code}
        options={options}
        onChange={this.onChange.bind(this)}
        editorDidMount={this.editorDidMount.bind(this)}
      />
    );
  }
}

export default Editor;

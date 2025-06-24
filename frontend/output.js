import React from "react";
import ReactDOM from "react-dom";
import MonacoEditor from "react-monaco-editor";

class Output extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      code: props.code,
      language: "plaintext"
    };
    
    this.updateDimensions = this.updateDimensions.bind(this);
  }

  updateDimensions() {
    if (this.editor) {
      this.editor.layout();
    }
  }

  editorDidMount(editor, monaco) {
    this.editor = editor;
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
      folding: false,
      showFoldingControls: "mouseover",
      fontSize: 14,
      formatOnPaste: true,
      formatOnType: false,
      readOnly: true,
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
      suggestOnTriggerCharacters: false,
      wordBasedSuggestions: false,
      quickSuggestions: false,
      matchBrackets: true,
      autoClosingBrackets: false,
      automaticLayout: false,
      autoIndent: true,
      lineNumbers: false,
      contextmenu: false,
      dragAndDrop: false
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

export default Output;

import React from "react";
import ReactDOM from "react-dom";
import MonacoEditor from "react-monaco-editor";

class Editor extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      code: props.code,
      readOnly: props.readOnly,
      showLines: !props.readOnly,
      language: props.readOnly == true ? "plaintext" : "swift"
    };
  }

  updateDimensions() {
    this.editor.layout();
  }

  editorDidMount(editor, monaco) {
    this.editor = editor;
    window.addEventListener("resize", this.updateDimensions.bind(this));
  }

  componentWillUnmount() {
    window.removeEventListener("resize", this.updateDimensions.bind(this));
  }

  getValue() {
    return this.editor.getModel().getValue();
  }

  setValue(value) {
    this.editor.getModel().setValue(value);
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
      formatOnPaste: false,
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
      snippetSuggestions: false,
      wordBasedSuggestions: false,
      matchBrackets: false,
      autoClosingBrackets: false,
      automaticLayout: false,
      lineNumbers: this.state.showLines,
      contextmenu: false,
      dragAndDrop: this.state.showLines
    };
    let requireConfig = {
      paths: { vs: "/static/vs" },
      url: "/static/vs/loader.js"
    };
    return (
      <MonacoEditor
        language={this.state.language}
        theme="vs-dark"
        value={code}
        options={options}
        requireConfig={requireConfig}
        onChange={this.onChange.bind(this)}
        editorDidMount={this.editorDidMount.bind(this)}
      />
    );
  }
}

export default Editor;

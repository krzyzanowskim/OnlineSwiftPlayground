import React from "react";
import ReactDOM from "react-dom";
import MonacoEditor from "react-monaco-editor";

class Editor extends React.Component {
  constructor(props) {
    super(props);
    this.state = { code: props.code, readOnly: props.readOnly };
  }

  editorDidMount(editor, monaco) {
    this.editor = editor;
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
    let options = {
      minimap: { enabled: false },
      cursorStyle: "block",
      cursorBlinking: "blink",
      folding: true,
      showFoldingControls: "mouseover",
      fontSize: 15,
      formatOnPaste: false,
      formatOnType: false,
      readOnly: this.props.readOnly,
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
      wordBasedSuggestions: false
      //   glyphMargin: false
    };
    let requireConfig = {
      paths: { vs: "/static/lib/bundle/vs" },
      url: "/static/lib/bundle/vs/loader.js"
    };
    return (
      <MonacoEditor
        // ref="monaco"
        language="swift"
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

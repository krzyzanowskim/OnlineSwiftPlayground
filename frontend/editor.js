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
    monaco.languages.registerCompletionItemProvider("swift", {
      // triggerCharacters: ["."],
      // resolveCompletionItem: function(item, token) {
      //   return { label: "guard" };
      // },
      provideCompletionItems: function(model, position) {
        var textUntilPosition = model.getValueInRange({
          startLineNumber: 1,
          startColumn: 1,
          endLineNumber: position.lineNumber,
          endColumn: position.column
        });
        return [
          {
            label: "for-in",
            kind: monaco.languages.CompletionItemKind.Snippet,
            documentation: "Swift For Statement",
            insertText: {
              value: ["for ${1:item} in ${2:items} {", "\t$0", "}"].join("\n")
            }
          },
          {
            label: "switch",
            kind: monaco.languages.CompletionItemKind.Snippet,
            documentation: "Swift Switch Statement",
            insertText: {
              value: [
                "switch ${1:value} {",
                "case ${2:pattern}:",
                "\t${3:// code}",
                "default:",
                '\tfatalError("Unsupported")',
                "}"
              ].join("\n")
            }
          },
          {
            label: "if",
            kind: monaco.languages.CompletionItemKind.Snippet,
            documentation: "Swift If Statement",
            insertText: {
              value: ["if ${1:condition} {", "\t${2:// code}", "}"].join("\n")
            }
          },
          {
            label: "guard",
            kind: monaco.languages.CompletionItemKind.Snippet,
            documentation: "Swift Guard Statement",
            insertText: {
              value: [
                "guard ${1:condition} else {",
                "\treturn ${2:value}",
                "}"
              ].join("\n")
            }
          },
          {
            label: "guard-let",
            kind: monaco.languages.CompletionItemKind.Snippet,
            documentation: "Swift Guard Statement",
            insertText: {
              value: [
                "guard let ${1:constant} = ${2:expression} else {",
                "\treturn ${3:value}",
                "}"
              ].join("\n")
            }
          },
          {
            label: "closure",
            kind: monaco.languages.CompletionItemKind.Snippet,
            documentation: "Swift Closure Expression",
            insertText: {
              value: [
                "{ (${1:parameters}) -> ${2:return_type} in",
                "\t${3:statements}",
                "}"
              ].join("\n")
            }
          },
          {
            label: "init",
            kind: monaco.languages.CompletionItemKind.Snippet,
            documentation: "Swift Initializer Declaration",
            insertText: {
              value: [
                "init(${1:parameters}) {",
                "\t${2:// statements}",
                "}"
              ].join("\n")
            }
          },
          {
            label: "deinit",
            kind: monaco.languages.CompletionItemKind.Snippet,
            documentation: "Swift Deinitializer Declaration",
            insertText: {
              value: [
                "deinit(${1:parameters}) {",
                "\t${2:// statements}",
                "}"
              ].join("\n")
            }
          },
          {
            label: "convenience",
            kind: monaco.languages.CompletionItemKind.Snippet,
            documentation: "Swift Convenience Initializer Declaration",
            insertText: {
              value: [
                "convenience init(${1:parameters}) {",
                "\t// ${2:statements}",
                "}"
              ].join("\n")
            }
          },
          {
            label: "required",
            kind: monaco.languages.CompletionItemKind.Snippet,
            documentation: "Swift Required Initializer Declaration",
            insertText: {
              value: [
                "required init(${1:parameters}) {",
                "\t// ${2:statements}",
                "}"
              ].join("\n")
            }
          },
          {
            label: "defer",
            kind: monaco.languages.CompletionItemKind.Snippet,
            documentation: "Swift Defer Statement",
            insertText: {
              value: ["defer {", "\t${3:deferred statements}", "}"].join("\n")
            }
          },
          {
            label: "do",
            kind: monaco.languages.CompletionItemKind.Snippet,
            documentation: "Swift Do-Catch Statement",
            insertText: {
              value: [
                "do {",
                "\ttry ${1:throwing_expression}",
                "} catch ${2:pattern} {",
                "\t${3:// statements}",
                "}"
              ].join("\n")
            }
          },
          {
            label: "while",
            kind: monaco.languages.CompletionItemKind.Snippet,
            documentation: "Swift While Statement",
            insertText: {
              value: [
                "while ${1:condition} {",
                "\t${3:// statements}",
                "}"
              ].join("\n")
            }
          },
          {
            label: "func",
            kind: monaco.languages.CompletionItemKind.Snippet,
            documentation: "Swift Function Statement",
            insertText: {
              value: [
                "func ${1:name}(${2:parameters}) -> ${3:T} {",
                "\t${4:// body}",
                "}"
              ].join("\n")
            }
          },
          {
            label: "lazy",
            kind: monaco.languages.CompletionItemKind.Snippet,
            documentation: "Swift Lazy Computed Property Declaration",
            insertText: {
              value: [
                "lazy var ${1:name}: ${2:T} = {",
                "\t// ${3:statements}",
                "\treturn ${4:value}",
                "}()"
              ].join("\n")
            }
          },
          {
            label: "let",
            kind: monaco.languages.CompletionItemKind.Snippet,
            documentation: "Swift Let Declaration",
            insertText: {
              value: ["let ${1:name} = ${2:value}"].join("\n")
            }
          },
          {
            label: "var",
            kind: monaco.languages.CompletionItemKind.Snippet,
            documentation: "Swift Var Declaration",
            insertText: {
              value: ["var ${1:name} = ${2:value}"].join("\n")
            }
          },
          {
            label: "var-computed",
            kind: monaco.languages.CompletionItemKind.Snippet,
            documentation: "Swift Computed Variable Get and Set Declaration",
            insertText: {
              value: [
                "var ${1:name}: ${2:T} {",
                "\tget {",
                "\t\t${3:// statement}",
                "\t}",
                "\tset {",
                "\t\t${4:// statement}",
                "\t}",
                "}"
              ].join("\n")
            }
          },
          {
            label: "typealias",
            kind: monaco.languages.CompletionItemKind.Snippet,
            documentation: "Swift Let Declaration",
            insertText: {
              value: ["typealias ${1:type name} = ${2:expression}"].join("\n")
            }
          }
        ];
      }
    });

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

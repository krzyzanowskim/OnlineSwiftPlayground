var path = require("path");

module.exports = {
  target: "web",
  entry: "./static/lib/src/main.js",
  output: {
    path: path.resolve(__dirname, "static/lib/bundle"),
    filename: "bundle.js"
  }
};

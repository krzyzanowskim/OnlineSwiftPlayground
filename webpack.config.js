let path = require("path");
let webpack = require("webpack");
let CopyWebpackPlugin = require("copy-webpack-plugin");

var config = {
  target: "web",
  entry: "./frontend/main.js",
  mode: 'production',
  output: {
    path: path.resolve(__dirname,"./static"),
    filename: "app.js"
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /(node_modules|bower_components)/,
        use: {
          loader: "babel-loader"
        }
      }
    ]
  },
  plugins: [
    new webpack.ProvidePlugin({
      $: "jquery",
      jQuery: "jquery"
    }),
    new CopyWebpackPlugin([
      {
        from: "node_modules/monaco-editor/min/vs",
        to: "vs"
      }
    ])
  ]
}

module.exports = (env, argv) => {

  if (argv.mode === 'development') {
    config.devtool = 'source-map';
  }

  return config;
};

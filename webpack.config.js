let path = require("path");
let webpack = require("webpack");
let CopyWebpackPlugin = require("copy-webpack-plugin");
let UglifyJsPlugin = require("uglifyjs-webpack-plugin");

module.exports = {
  target: "web",
  entry: "./static/lib/src/main.js",
  devtool: "source-map",
  output: {
    path: path.resolve(__dirname, "static/lib/bundle"),
    filename: "bundle.js"
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
    // new UglifyJsPlugin({
    //   sourceMap: true
    // }),
    // new webpack.DefinePlugin({
    //   "process.env.NODE_ENV": JSON.stringify("production")
    // }),
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
};

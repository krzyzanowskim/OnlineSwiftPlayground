let path = require("path");
let webpack = require("webpack");
let MonacoWebpackPlugin = require('monaco-editor-webpack-plugin');

var config = {
  target: "web",
  entry: "./frontend/main.js",
  mode: 'production',
  output: {
    path: path.resolve(__dirname,"./Public/static/app"),
    filename: "app.js",
    publicPath: "/static/app/"
  },
  node: {
    fs: "empty"
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /(node_modules|bower_components)/,
        use: {
          loader: "babel-loader"
        }
      },
      { test: /\.css$/, loader: "style-loader!css-loader" }
    ]
  },
  plugins: [
    new MonacoWebpackPlugin(),
    new webpack.ProvidePlugin({
      $: "jquery",
      jQuery: "jquery"
    })
  ]
}

module.exports = (env, argv) => {

  if (argv.mode === 'development') {
    config.devtool = 'source-map';
  }

  return config;
};

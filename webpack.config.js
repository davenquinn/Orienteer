const HtmlWebpackPlugin = require("html-webpack-plugin");
const DotenvPlugin = require("dotenv-webpack");
const path = require("path");

const cssModuleLoader = {
  loader: "css-loader",
  options: {
    modules: {
      mode: "local",
      localIdentName: "[path][name]__[local]--[hash:base64:5]",
    },
  },
};

const styleLoaders = [
  {
    test: /\.(styl|css)$/,
    use: "style-loader",
  },
  // CSS compilation supporting local CSS modules
  {
    test: /\.(styl|css)$/,
    oneOf: [
      // Match css modules (.module.(css|styl) files)
      {
        test: /\.?module\.(css|styl)$/,
        use: cssModuleLoader,
        exclude: /node_modules/,
      },
      {
        test: /\.(styl|css)$/,
        use: "css-loader",
      },
    ],
  },
  { test: /\.styl$/, use: "stylus-loader" },
];

module.exports = {
  mode: "development",
  // Enable sourcemaps for debugging webpack's output.
  devtool: "source-map",
  resolve: {
    extensions: [".ts", ".tsx", ".js"],
    alias: {
      app: path.resolve(__dirname, "frontend/src"),
      react: path.resolve(__dirname, "node_modules", "react"),
      "react-dom": path.resolve(__dirname, "node_modules", "react-dom"),
      "@macrostrat/map-components": "@macrostrat/map-components/src",
    },
    fallback: { path: false },
  },
  module: {
    rules: [
      {
        test: /\.(js|jsx|ts|tsx)$/,
        use: ["babel-loader"],
        exclude: /node_modules/,
      },
      {
        test: /\.(png|svg)$/,
        use: ["file-loader"],
      },
      ...styleLoaders,
      {
        enforce: "pre",
        test: /\.js$/,
        loader: "source-map-loader",
      },
      // https://github.com/CesiumGS/cesium/issues/9790#issuecomment-943773870
    ],
  },
  optimization: {
    splitChunks: { chunks: "all" },
    usedExports: true,
  },
  entry: {
    index: "./frontend/src/index.ts",
  },
  plugins: [new HtmlWebpackPlugin({ title: "Orienteer" }), new DotenvPlugin()],
};

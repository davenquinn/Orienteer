/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const hook = require("css-modules-require-hook");
const stylus = require("stylus");
const { readFileSync } = require("fs");

const appendStyleToPage = function (css) {
  const style = document.createElement("style");
  style.type = "text/css";
  style.innerHTML = css;
  return document.head.appendChild(style);
};

// Create hook for css files
require.extensions[".css"] = function (module, filename) {
  const f = readFileSync(filename);
  return appendStyleToPage(f.toString());
};

// Create hook for stylus files
hook({
  mode: "global", // global by default
  extensions: [".styl"],
  preprocessCss(css, filename) {
    return stylus(css).set("filename", filename).render();
  },
  processCss: appendStyleToPage,
});

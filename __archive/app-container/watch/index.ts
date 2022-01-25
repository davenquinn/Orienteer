/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const { app } = require("electron");
const path = require("path");

const init = (list, cb) => cb();

module.exports = function (cb) {
  const styleDir = path.join(app.config.buildDir, "styles");
  const outputStyles = path.join(styleDir, "*.css");
  const list = app.config.watch.scripts;
  list.push(outputStyles);

  return init(list, cb);
};

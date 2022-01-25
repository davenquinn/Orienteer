/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const { join, resolve } = require("path");
const { remote } = require("electron");

/* Add global precompiled styles */

const stylePath = remote.getGlobal("STYLE_PATH");

const styles = [
  require.resolve("leaflet/dist/leaflet.css"),
  require.resolve("font-awesome/css/font-awesome.css"),
  require.resolve("@blueprintjs/core/dist/blueprint.css"),
];

for (let style of Array.from(styles)) {
  const li = document.createElement("link");
  li.type = "text/css";
  li.rel = "stylesheet";
  li.href = "file://" + style;
  document.head.appendChild(li);
}

/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");
const ReactDOM = require("react-dom");
const { Link, browserHistory } = require("react-router");
const L = require("leaflet");
const { MapControl } = require("react-leaflet");

const Control = L.Control.extend({
  options: {
    position: "topleft",
  },
  onAdd(map) {
    const controlDiv = L.DomUtil.create("div", "leaflet-home-btn leaflet-bar");
    L.DomEvent.addListener(controlDiv, "click", L.DomEvent.stopPropagation)
      .addListener(controlDiv, "click", L.DomEvent.preventDefault)
      .addListener(controlDiv, "click", () => (location.hash = ""));
    const controlUI = L.DomUtil.create(
      "a",
      "leaflet-draw-edit-remove",
      controlDiv
    );
    controlUI.title = "Go home";
    controlUI.href = "#";
    L.DomUtil.create("i", "fa fa-home", controlUI);
    return controlDiv;
  },
});

class HomeButton extends MapControl {
  createLeafletElement() {
    return new Control();
  }
}

module.exports = HomeButton;

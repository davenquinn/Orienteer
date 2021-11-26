import L from "leaflet";
import { MapControl } from "react-leaflet";

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

export default HomeButton;

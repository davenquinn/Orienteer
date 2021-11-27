/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import {
  Map,
  MapLayer,
  LayersControl,
  ScaleControl,
  TileLayer,
} from "react-leaflet";
import h from "@macrostrat/hyper";
import { Component } from "react";
import SelectBox from "./select-box";
import BackButton from "./back-button";
//const BaseTileLiveLayer = require("./tilelive-layer");
const { BaseLayer, Overlay } = LayersControl;

const defaultOptions = {
  tileSize: 256,
  zoom: 0,
  attributionControl: false,
  continuousWorld: true,
  debounceMoveend: true,
};

class BoxSelectMap extends Map {
  createLeafletElement(props) {
    const map = super.createLeafletElement(props);
    map.addHandler("boxSelect", SelectBox);
    map.boxSelect.enable();
    map.on("boxSelected", (e) => {
      console.log("Box selected");
      return app.data.selectByBox(e.bounds);
    });
    return map;
  }
}

class MapControl extends Component {
  constructor(props) {
    let k, v;
    super(props);

    const cfg = {};

    this.state = {
      center: [0, 0],
    };

    const options = {};
    for (k in cfg) {
      v = cfg[k];
      if (k === "layers") {
        continue;
      }
      if (options[k] == null) {
        options[k] = v;
      }
    }

    for (k in defaultOptions) {
      v = defaultOptions[k];
      if (options[k] == null) {
        options[k] = v;
      }
    }

    this.state.options = options;
  }

  render() {
    // Add base layers
    const { center, zoom, layers } = this.state.options;
    const c = [0, 0]; // [center[1], center[0]];

    let ix = 0;
    let overlays = this.props.children;
    if (!Array.isArray(overlays)) {
      overlays = [overlays];
    }

    /*
    for (let k in app.config.layers) {
      var lyr;
      const uri = app.config.layers[k];
      if (uri === "google") {
        const url = "http://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}";
        const subdomains = ["mt0", "mt1", "mt2", "mt3"];
        lyr = h(TileLayer, { maxZoom: 20, url, subdomains });
      } else {
        lyr = h(TileLiveLayer, { id: k, uri, detectRetina: true });
      }

      overlays.push(
        h(
          BaseLayer,
          {
            name: k,
            key: k,
            checked: ix === 0,
          },
          [lyr]
        )
      );
      ix += 1;
    }
    */

    return h(
      BoxSelectMap,
      { center: c, zoom, boxZoom: false, width: 500, height: 500 },
      [
        h(LayersControl, { position: "topleft" }, []),
        //h LayersControl, position: 'topleft', overlays
        h(ScaleControl, { imperial: false }),
        //h BackButton # We cause major problems with back-navigation for now
      ]
    );
  }
}

module.exports = MapControl;

/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const {
  Map,
  MapLayer,
  LayersControl,
  ScaleControl,
  TileLayer,
} = require("react-leaflet");
const h = require("react-hyperscript");
const { Component } = require("react");
const style = require("./style");
const path = require("path");
const BaseMapnikLayer = require("gis-core/frontend/mapnik-layer");
const setupProjection = require("gis-core/frontend/projection");
const parseConfig = require("gis-core/frontend/config");
const SelectBox = require("./select-box");
const BackButton = require("./back-button");
const BaseTileLiveLayer = require("./tilelive-layer");
const { BaseLayer, Overlay } = LayersControl;

class TileLiveLayer extends MapLayer {
  createLeafletElement(props) {
    const { id, uri } = props;
    const opts = this.getOptions(props);
    const lyr = new BaseTileLiveLayer(id, uri, opts);
    return lyr;
  }
}

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

    const cfg = app.config;

    this.state = {
      center: app.config.center,
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
    const c = [center[1], center[0]];

    let ix = 0;
    let overlays = this.props.children;
    if (!Array.isArray(overlays)) {
      overlays = [overlays];
    }

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

    return h(BoxSelectMap, { center: c, zoom, boxZoom: false }, [
      h(LayersControl, { position: "topleft" }, overlays),
      //h LayersControl, position: 'topleft', overlays
      //h ScaleControl, {imperial: false}
      //h BackButton # We cause major problems with back-navigation for now
    ]);
  }
}

module.exports = MapControl;

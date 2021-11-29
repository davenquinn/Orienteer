import {
  MapContainer,
  MapLayer,
  LayersControl,
  ScaleControl,
  TileLayer,
} from "react-leaflet";
import h from "@macrostrat/hyper";
import { Component } from "react";
import SelectBox from "./select-box";
import "./style.styl";
import { useAPIResult } from "@macrostrat/ui-components";
import { createProjection } from "../../shared/map/projection";
import { MARS949901 } from "./mars-crs";
import BackButton from "./back-button";
//const BaseTileLiveLayer = require("./tilelive-layer");
const { BaseLayer, Overlay } = LayersControl;
import L from "leaflet";

const defaultOptions = {
  tileSize: 256,
  zoom: 0,
  attributionControl: false,
  continuousWorld: true,
  debounceMoveend: true,
};

/*
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
*/

class _MapControl extends Component {
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
}

function useMapBounds() {
  const res = useAPIResult(
    process.env.ORIENTEER_API_BASE + "/models/rpc/project_bounds"
  );
  console.log(res);
  const data = res;
  if (res == null) return null;
  return L.geoJson(res).getBounds();
}

function MapControl(props) {
  // Add base layers
  const { center, zoom, layers, children } = props;
  const c = [0, 0]; // [center[1], center[0]];

  let ix = 0;
  let overlays = []; //this.props.children;
  if (!Array.isArray(overlays)) {
    overlays = [overlays];
  }
  //const url = "http://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}";
  const url =
    "https://s3-eu-west-1.amazonaws.com/whereonmars.cartodb.net/mola-gray/{z}/{x}/{-y}.png";
  // Can't do geographic CRS right now: https://github.com/TerriaJS/terriajs/issues/1020
  //"https://astro.arcgis.com/arcgis/rest/services/OnMars/CTX/MapServer/tile/{z}/{y}/{x}.png";
  //const url = "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png";
  //const subdomains = ["mt0", "mt1", "mt2", "mt3"];
  const lyr = h(TileLayer, { maxZoom: 8, url });
  let k = "google";

  //overlays.push(lyr);
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
    */

  const bounds = useMapBounds();
  console.log(bounds);
  if (bounds == null) return null;

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
  //ix += 1;

  return h(
    MapContainer,
    {
      boxZoom: false,
      bounds,
      crs: MARS949901,
    },
    [
      //h(LayersControl, { position: "topleft" }, []),
      //lyr,

      children,
      h(TileLayer, {
        url: "https://argyre.geoscience.wisc.edu/tiles/mosaic/ctx_mosaic/tiles/{z}/{x}/{y}.png?rescale=0,255",
      }),
      h(TileLayer, {
        url: "https://argyre.geoscience.wisc.edu/tiles/mosaic/hirise_red/tiles/{z}/{x}/{y}.png",
      }),
      //h(LayersControl, { position: "topleft", overlays }),
      h(ScaleControl, { imperial: false }),
      //h BackButton # We cause major problems with back-navigation for now
    ]
  );
}

export default MapControl;

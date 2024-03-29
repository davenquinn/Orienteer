import {
  MapContainer,
  LayersControl,
  ScaleControl,
  TileLayer,
  useMap,
} from "react-leaflet";
import h from "@macrostrat/hyper";
import "./style.styl";
import { useAPIResult } from "@macrostrat/ui-components";
import { MARS949901 } from "./mars-crs";
import Control from "./custom-control";
const { BaseLayer } = LayersControl;
import L from "leaflet";
import { Icon } from "@blueprintjs/core";
import { useAppDispatch } from "app/hooks";

const defaultOptions = {
  tileSize: 256,
  zoom: 0,
  attributionControl: false,
  continuousWorld: true,
  debounceMoveend: true,
};

class BoxSelect extends L.Map.BoxZoom {
  dispatch: React.Dispatch<any> | null;
  _onMouseUp(e) {
    this._finish();
    if (!this._moved) {
      return;
    }
    const s = this._map.containerPointToLatLng(this._startPoint);
    e = this._map.containerPointToLatLng(this._point);

    const bounds = new L.LatLngBounds(s, e);
    return this.dispatch?.({ type: "select-box", data: bounds });
  }
}

function BoxSelectControl() {
  const dispatch = useAppDispatch();
  const map = useMap();
  map.addHandler("boxSelect", BoxSelect);
  map.boxSelect.dispatch = dispatch;
  map.boxSelect.enable();
  return null;
}

function useMapBounds() {
  const res = useAPIResult(
    process.env.ORIENTEER_API_BASE + "/models/rpc/project_bounds"
  );
  const data = res;
  if (res == null) return null;
  return L.geoJson(res).getBounds();
}

function SidebarToggleButton() {
  const dispatch = useAppDispatch();
  return h(
    "a",
    {
      onClick() {
        dispatch({ type: "toggle-sidebar" });
      },
    },
    h(Icon, { icon: "menu" })
  );
}

function MapControl(props) {
  // Add base layers
  const { center, zoom, layers, children, toggleSidebar } = props;
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
        url: "https://argyre.geoscience.wisc.edu/tiles/mosaic/ctx_mosaic/tiles/{z}/{x}/{y}.png",
      }),
      h(TileLayer, {
        url: "https://argyre.geoscience.wisc.edu/tiles/mosaic/tiles/{z}/{x}/{y}.png?mosaic=orthoimage,hirise_red",
      }),
      h(BoxSelectControl),
      h(Control, { position: "topright" }, h(SidebarToggleButton)),
      //h(LayersControl, { position: "topleft", overlays }),
      h(ScaleControl, { imperial: false }),
      //h BackButton # We cause major problems with back-navigation for now
    ]
  );
}

export default MapControl;

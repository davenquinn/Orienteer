import L from "leaflet";

class BoxSelect extends L.Map.BoxZoom {
  _onMouseUp(e) {
    this._finish();
    if (!this._moved) {
      return;
    }
    const s = this._map.containerPointToLatLng(this._startPoint);
    e = this._map.containerPointToLatLng(this._point);

    const bounds = new L.LatLngBounds(s, e);
    return this._map.fire("boxSelected", { bounds });
  }
}

export default BoxSelect;

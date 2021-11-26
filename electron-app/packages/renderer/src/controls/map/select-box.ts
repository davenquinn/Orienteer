/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const L = require("leaflet");

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

module.exports = BoxSelect;

/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const d3 = require("d3");
const L = require("leaflet");
const Spine = require("spine");

class DataLayer extends L.SVG {
  static initClass() {
    this.include(Spine.Events);
  }
  constructor() {
    this.projectPoint = this.projectPoint.bind(this);
    super();
    this.initialize({ padding: 0.1 });
  }

  setupProjection() {
    const f = this.projectPoint;
    this.projection = d3.geo.transform({
      point(x, y) {
        const point = f(x, y);
        return this.stream.point(point.x, point.y);
      },
    });

    return (this.path = d3.geo.path().projection(this.projection));
  }

  projectPoint(x, y) {
    return this._map.latLngToLayerPoint(new L.LatLng(y, x));
  }

  onAdd() {
    super.onAdd();
    this.setupProjection();
    this.svg = d3
      .select(this._container)
      .classed("data-layer", true)
      .classed("leaflet-zoom-hide", true);
    return this._map.on("viewreset", this.resetView);
  }

  resetView() {}
}
DataLayer.initClass();

module.exports = DataLayer;

/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const { MapLayer, TileLayer } = require("react-leaflet");
const { GridLayer } = require("leaflet");
const tilelive = require("@mapbox/tilelive");
const mbtiles = require("mbtiles");
require("tilelive-modules/loader")(tilelive, { require: ["mbtiles"] });
const Promise = require("bluebird");

class TileLiveLayer extends GridLayer {
  constructor(id, uri, options) {
    this.id = id;
    this.uri = uri;
    super();
    this.options.updateWhenIdle = true;
    if (this.options.verbose == null) {
      this.options.verbose = false;
    }
    console.log(this.uri);
    const loadTiles = Promise.promisify(tilelive.load);
    this.__tileSourcePending = loadTiles(this.uri);
    this.initialize(options);
  }

  createTile(coords, done) {
    const { z, x, y } = coords;
    const tile = document.createElement("img");
    this.tileSource.getTile(z, x, y, function (err, buffer, opts) {
      if (err) {
        throw err;
      }
      //i_ = im.encodeSync 'png'
      const blob = new Blob([buffer], { type: "image/png" });
      console.log(blob);
      const url = URL.createObjectURL(blob);
      tile.src = url;
      return (tile.onload = () => {
        console.log(tile);
        done(null, tile);
        return URL.revokeObjectURL(url);
      });
    });
    return tile;
  }

  onAdd = async (map) => {
    this.tileSource = await this.__tileSourcePending;
    // We want to be able to check if we are currently
    // zooming
    this._zooming = false;
    map.on("zoomstart", () => {
      return (this._zooming = true);
    });
    map.on("zoomend", () => {
      return (this._zooming = false);
    });

    return super.onAdd(map);
  };
}

module.exports = TileLiveLayer;

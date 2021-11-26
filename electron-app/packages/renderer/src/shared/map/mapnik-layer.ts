/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const fs = require("fs");
const mapnik = require("mapnik");
const mapnikPool = require("mapnik-pool");
const L = require("leaflet");

mapnik.register_default_fonts();
mapnik.register_default_input_plugins();
const mPool = mapnikPool(mapnik);

class MapnikLayer extends L.GridLayer {
  constructor(mapfile, options) {
    this.options.updateWhenIdle = true;
    this.initialize(options);

    const _ = fs.readFileSync(mapfile, "utf8");
    this.pool = mPool.fromString(_, { size: this.options.tileSize });
  }

  createTile(coords) {
    const r = window.devicePixelRatio || 1;
    const scaledSize = this.options.tileSize * r;

    const tile = new Image();
    tile.width = tile.height = scaledSize;

    const { crs } = this._map.options;
    const { bounds } = crs.projection;
    const sz = this.options.tileSize / crs.scale(coords.z);

    const ll = {
      x: bounds.min.x + coords.x * sz,
      y: bounds.max.y - (coords.y + 1) * sz,
    };
    const ur = {
      x: bounds.min.x + (coords.x + 1) * sz,
      y: bounds.max.y - coords.y * sz,
    };
    const box = [ll.x, ll.y, ur.x, ur.y];

    const { pool } = this;
    pool.acquire(function (e, map) {
      if (e) {
        throw e;
      }
      map.width = map.height = scaledSize;
      const im = new mapnik.Image(map.width, map.height);

      map.extent = box;
      return map.render(im, { scale: r }, (err, im) => {
        if (err) {
          throw err;
        }
        const i_ = im.encodeSync("png");
        const blob = new Blob([i_], { type: "image/png" });
        const url = URL.createObjectURL(blob);

        tile.src = url;
        tile.onload = function () {
          URL.revokeObjectURL(url);
          const _ = `x: ${coords.x}, y: ${coords.y}, zoom: ${coords.z}`;
          return console.log(_);
        };
        return pool.release(map);
      });
    });

    return tile;
  }
}

module.exports = MapnikLayer;

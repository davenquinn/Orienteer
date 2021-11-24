/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const Spine = require("spine");
const $ = require("jquery");
const L = require("leaflet");
const path = require("path");
global.L = L;
require("leaflet-draw");
const CacheDatastore = require("../data/cache");
const mapnik = require("mapnik");

const MapnikLayer = require("./mapnik-layer");
const setupProjection = require("./projection");

class Map extends Spine.Controller {
  static initClass() {
    this.prototype.class = "viewer";
    this.prototype.defaults = { tileSize: 256 };
  }
  constructor() {
    this.invalidateSize = this.invalidateSize.bind(this);
    this.extentChanged = this.extentChanged.bind(this);
    this.setupMap = this.setupMap.bind(this);
    this.addMapnikLayers = this.addMapnikLayers.bind(this);
    this.createControls = this.createControls.bind(this);
    this.setBounds = this.setBounds.bind(this);
    this.getBounds = this.getBounds.bind(this);
    super();
    this.config = app.config.map;
    for (let k in this.defaults) {
      const v = this.defaults[k];
      if (this.config[k] == null) {
        this.config[k] = v;
      }
    }

    // Use GIS conventions in config
    this.config.center = [this.config.center[1], this.config.center[0]];

    this.config.layers.forEach(
      (
        d // Make paths relative to config file
      ) => (d.filename = app.config.path(d.filename))
    );

    this.settings = new CacheDatastore("map-visible-layers");

    if (this.visibleControls == null) {
      this.visibleControls = ["layers", "scale"];
    }
    this.layers = {
      baseMaps: {},
      overlayMaps: {},
    };
    this.render();
  }

  render() {
    return this.setupMap();
  }

  invalidateSize() {
    // Shim for flexbox
    return this.leaflet.invalidateSize();
  }

  setHeight() {
    return this.el.height(window.innerHeight);
  }

  extentChanged() {
    return this.trigger("extents", this.leaflet.getBounds());
  }

  setupMap() {
    const s = this.config.projection;
    const projection = setupProjection(s, {
      minResolution: this.config.resolution.min, // m/px
      maxResolution: this.config.resolution.max, // m/px
      bounds: this.config.bounds,
    });

    this.leaflet = new L.Map(this.el[0], {
      center: this.config.center,
      zoom: 2,
      crs: projection,
      boxZoom: false,
      continuousWorld: true,
      debounceMoveend: true,
      boxSelect: true,
    });

    this.addMapnikLayers();
    this.createControls();

    if (this.wmts != null) {
      getData().then(this.addWMTSLayers);
    }

    return this.leaflet.on("viewreset dragend", this.extentChanged);
  }

  addMapnikLayers() {
    let id;
    const { layers } = this.config;

    this.visibleLayers = this.settings.get() || [];

    for (let cfg of Array.from(layers)) {
      const fn = cfg.filename;
      const ext = path.extname(fn);
      id = path.basename(fn, ext);
      const sz = cfg.tileSize || this.config.tileSize;
      const l = new MapnikLayer(fn, { tileSize: sz });
      l.id = id;

      // Add to visible layers if there are
      // no visible layers currently set
      if (!this.visibleLayers.length) {
        this.visibleLayers.push(id);
      }

      this.layers.overlayMaps[cfg.name] = l;
      if (this.visibleLayers.indexOf(id) !== -1) {
        l.addTo(this.leaflet);
      }
    }

    const _ = () => {
      // Update cached layer information when
      // map is changed
      this.visibleLayers = (() => {
        const result = [];
        for (let k in this.leaflet._layers) {
          const v = this.leaflet._layers[k];
          result.push(v.id);
        }
        return result;
      })();
      return this.settings.set(this.visibleLayers);
    };

    return this.leaflet.on("layeradd layerremove", _);
  }

  createControls() {
    console.log(this.layers);

    const layers = new L.Control.Layers(
      this.layers.baseMaps,
      this.layers.overlayMaps,
      { position: "topleft" }
    );

    this.controls = {
      layers,
      scale: L.control.scale({
        maxWidth: 250,
        imperial: false,
      }),
    };

    return Array.from(this.visibleControls).map((k) =>
      this.controls[k].addTo(this.leaflet)
    );
  }

  setBounds(b) {
    return this.leaflet.fitBounds(b);
  }

  getBounds() {
    let out;
    const b = this.leaflet.getBounds();
    return (out = [
      [b._southWest.lat, b._southWest.lng],
      [b._northEast.lat, b._northEast.lng],
    ]);
  }
}
Map.initClass();

module.exports = Map;

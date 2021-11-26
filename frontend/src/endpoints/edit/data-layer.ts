/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const chroma = require("chroma-js");
const d3 = require("d3");
const React = require("react");
const Spine = require("spine");

const DataLayerBase = require("gis-core/frontend/helpers/data-layer");
const Editor = require("./feature-editor");

const q =
  "SELECT id,ST_AsGeoJSON(geometry) geom FROM dataset_feature WHERE type=$1";

const baseColor = chroma("red");
const mainColor = baseColor.desaturate(3);

const selected = null;

const fillFunc = (color) =>
  function (d) {
    let c;
    if (d.geometry.type === "Polygon") {
      c = color.alpha(0.5).css();
    } else {
      c = "none";
    }
    return c;
  };

const normalAttrs = {
  stroke: mainColor,
  fill: fillFunc(mainColor),
};

const selectedAttrs = {
  stroke: baseColor,
  fill: fillFunc(baseColor),
};

class DataLayer extends DataLayerBase {
  constructor() {
    this.onAdd = this.onAdd.bind(this);
    this.addFeatures = this.addFeatures.bind(this);
    this.setSelected = this.setSelected.bind(this);
    this.setupEditor = this.setupEditor.bind(this);
    this.resetView = this.resetView.bind(this);
    super({ d3 });
    this.events = d3.dispatch(["selected"]);
  }

  onAdd() {
    super.onAdd();
    this.container = this.svg.append("g");
    this.editContainer = this.svg.append("g");

    return app.query(q, ["Attitude"], (err, data) => {
      if (err) {
        throw err;
      }
      const features = data.rows.map((r) => {
        return {
          id: r.id,
          type: "Feature",
          geometry: JSON.parse(r.geom),
        };
      });
      return this.addFeatures(features);
    });
  }

  addFeatures(features) {
    const { trigger } = this;

    this.features = this.container.selectAll("path").data(features);

    const sel = this.events.selected;
    this.features
      .enter()
      .append("path")
      .on("click", this.events.selected)
      .attr(normalAttrs)
      .attr({
        "stroke-width": 2,
        class(d) {
          return d.geometry.type;
        },
        d: this.path,
      });

    return this._map.on("zoomend", this.resetView);
  }

  setSelected(sel) {
    if (sel == null) {
      this.features.attr(normalAttrs);
      return;
    }
    return this.features.each(function (d) {
      const el = d3.select(this);
      const v = d.id === sel.id ? selectedAttrs : normalAttrs;
      return el.attr(v);
    });
  }

  setupEditor(sel) {
    this.editor = new Editor(sel, this);
    console.log("Starting editor");
    if (sel == null) {
      return;
    }

    const s = this.state.editing;
    s.complete = true;
    this.editor.setState({ complete: true });
    this.sidebar.setState(s);
    return this.features
      .filter((d) => d.id === sel.id)
      .attr({ display: "none" });
  }

  resetView() {
    console.log("Resetting view");
    return this.features.attr({ d: this.path });
  }
}

module.exports = DataLayer;

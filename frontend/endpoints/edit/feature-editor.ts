/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const chroma = require("chroma-js");
const d3 = require("d3");

let selected = null;
let dragged = null;
const draggingIndex = null;

class Editor {
  static initClass() {
    this.prototype.color = "red";
    this.prototype.defaultState = {
      coordinates: [],
      type: null,
      closed: false,
      valid: false,
      complete: false,
      targetType: "Polygon",
    };
  }
  constructor(d, layer) {
    this.setupSelection = this.setupSelection.bind(this);
    this.setState = this.setState.bind(this);
    this.finalize = this.finalize.bind(this);
    this.setupEditing = this.setupEditing.bind(this);
    this.resetView = this.resetView.bind(this);
    this.setupGhosts = this.setupGhosts.bind(this);
    this.layer = layer;
    this.events = d3.dispatch(["updated", "complete"]);
    if (d == null) {
      d = this.defaultState;
    } else {
      d.complete = true;
    }
    if (d.geometry != null) {
      d = d.geometry;
    }
    d.valid = d.valid || true;
    d.closed = d.closed || false;
    this.state = d;

    this.el = this.layer.editContainer.append("g");
    this._map = this.layer._map;
    this.path = this.layer.path;

    this.feature = this.el.append("path").attr({
      stroke: this.color,
      fill: chroma(this.color).alpha(0.2).css(),
    });

    this.coords = this.state.coordinates;
    if (d.type === "Polygon") {
      // Outer ring only
      this.coords = this.coords[0];
    }

    const i = this.coords.length - 1;
    this.state.closed = this.coords[0] === this.coords[i];
    if (i < 2) {
      this.state.closed = null;
    }

    this._map.on("click", (e) => {
      if (!this.state.complete) {
        const pt = e.latlng;
        this.coords.push([pt.lng, pt.lat]);
        this.setupSelection();
        return this.resetView();
      }
    });

    this.setupSelection();

    this._map.on("mousemove", (e) => {
      if (!dragged) {
        return;
      }
      const pt = e.latlng;
      dragged[0] = pt.lng;
      dragged[1] = pt.lat;
      this.setupGhosts();
      return this.resetView();
    });

    this.resetView();
    this._map.on("zoomend", this.resetView);
  }

  setState(d) {
    return (this.state = this.defaultState);
  }

  setType(t) {
    if (t != null) {
      this.state.targetType = t;
      this.setupSelection();
      this.resetView();
      return;
    }

    if (this.state.targetType !== "Polygon") {
      this.state.closed = false;
    }

    // Set the actual type
    const l = this.coords.length;
    if (l === 0) {
      t = null;
    } else if (l === 1) {
      t = "Point";
    } else if (this.state.closed) {
      t = "Polygon";
    } else {
      t = "LineString";
    }
    return (this.state.type = t);
  }

  setupSelection() {
    this.setType();
    let c = this.coords;
    if (this.state.closed) {
      c.push(c[0]);
      c = [c];
    } else if (this.state.type === "Point") {
      c = c[0];
    }

    this.feature.datum({ type: this.state.type, coordinates: c });

    this.nodes = this.el.selectAll("circle.node").data(this.coords);

    this.nodes.enter().append("circle").attr({
      class: "node",
      r: 5,
      fill: this.color,
    });

    if (this.state.complete) {
      return this.setupEditing();
    } else {
      this.nodes.on("click", null);
      this.nodes
        .filter((d, i) => i === 0)
        .on("click", (d, i) => {
          this.state.closed = true;
          return this.doneAddingPoints();
        });

      const l = this.coords.length - 1;
      return this.nodes
        .filter((d, i) => i === l)
        .on("click", this.doneAddingPoints);
    }
  }

  setState(d) {
    const c = d.complete;
    if (c != null && c !== this.state.complete) {
      this.state.complete = c;
      this.setupSelection();
      return this.resetView();
    }
  }

  finalize() {
    if (!this.state.complete) {
      console.log("complete");
      this.state.complete = true;
      if ((this.state.targetType = "Polygon")) {
        this.state.closed = true;
      }
      this.setupSelection();
      return this.resetView();
    } else {
      this.nodes.delete();
      return this.ghosts.delete();
    }
  }

  setupEditing() {
    this.setupGhosts();
    this.nodes
      .on("mousedown", (d) => {
        selected = dragged = d;
        this._map.dragging.disable();
        return this.resetView();
      })
      .on("mouseup", (d) => {
        dragged = null;
        return this._map.dragging.enable();
      });

    return this.ghosts
      .enter()
      .append("circle")
      .attr({
        class: "ghost",
        r: 3,
        "stroke-width": 2,
        fill: "white",
        cursor: "pointer",
        stroke: this.color,
      })
      .on("click", (d, i) => {
        console.log(d);
        this.coords.splice(i + 1, 0, d);
        this.setupSelection();
        return this.resetView();
      });
  }

  resetView() {
    this.feature.attr({ d: this.path });

    const pt = this.layer.projectPoint;
    this.el.selectAll("circle").each(function (d) {
      const loc = pt(d[0], d[1]);
      return d3.select(this).attr({ cx: loc.x, cy: loc.y });
    });

    if (this.ghosts == null) {
      return;
    }
    // Don't show intermediate nodes that are close together.
    const nodes = this.nodes[0];
    return this.ghosts.each(function (d, i) {
      const el = d3.select(this);
      const adjacentNode = d3.select(nodes[i]);
      const dX = el.attr("cx") - adjacentNode.attr("cx");
      const dY = el.attr("cy") - adjacentNode.attr("cy");
      const dist = Math.sqrt(Math.pow(dX, 2) + Math.pow(dY, 2));
      return el.attr({ display: dist < 10 ? "none" : "inherit" });
    });
  }

  setupGhosts() {
    const { coords } = this;
    if (this.state.closed) {
      coords.push(coords[0]);
    }
    const maxIx = coords.length - 1;
    this.intermediatePoints = coords
      .filter((d, i) => i !== maxIx)
      .map((d, i) => {
        const e = this.coords[i + 1];
        return [(d[0] + e[0]) / 2, (d[1] + e[1]) / 2];
      });
    return (this.ghosts = this.el
      .selectAll("circle.ghost")
      .data(this.intermediatePoints));
  }
}
Editor.initClass();

module.exports = Editor;

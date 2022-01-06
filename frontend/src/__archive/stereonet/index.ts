/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const React = require("react");
const ReactDOM = require("react-dom");
const Dimensions = require("react-dimensions");
const d3 = require("d3");
require("d3-selection-multi");
const { functions, math } = require("attitude");
const { planes, ellipses } = require("./types");
const style = require("./main.styl");
const h = require("react-hyperscript");

const proj = d3.geoOrthographic().clipAngle(90).precision(0.1).rotate([0, -90]);

const path = d3.geoPath().projection(proj);

class StereonetView extends React.Component {
  static initClass() {
    this.defaultProps = { width: 500 };
  }
  render() {
    return h("svg", { className: style.container });
  }
  componentDidMount() {
    const el = ReactDOM.findDOMNode(this);
    this.svg = d3.select(el);

    this.updateSize();
    // Setup basic element
    this.container = this.svg
      .append("g")
      .attr("class", "orientation")
      .attr("fill", "white");

    this.container
      .append("defs")
      .append("path")
      .datum({ type: "Sphere" })
      .attrs({
        d: path,
        id: "sphere",
      });

    this.container.append("use").attrs({
      class: style.background,
      "xlink:href": "#sphere",
    });

    const grat = d3.geoGraticule();
    this.container.append("path").datum(grat).attrs({ class: style.graticule });

    this.main = this.container.append("g");
    this.hoverOverlay = this.container
      .append("g")
      .attrs({ class: "hover-overlay" });

    this.container.append("use").attrs({
      class: style.neatline,
      "xlink:href": "#sphere",
    });

    this.updatePaths();

    // Add dragging for debug purposes
    const drag = d3.drag().on("drag", () => {
      proj.rotate([-d3.event.x, -d3.event.y]);
      return this.updatePaths();
    });
    return this.container.call(drag);
  }

  componentDidUpdate(prevProps, prevState) {
    console.log(prevProps, this.props);
    if (prevProps.data !== this.props.data) {
      // This is currently broken
      this.dataChanged();
    }
    if (prevProps.width !== this.props.width) {
      console.log("Scale was changed");
      this.updateSize();
    } else if (prevProps.hovered !== this.props.hovered) {
      this.updateHovered();
    }

    return this.updatePaths();
  }

  updateHovered() {
    const v = this.props.hovered;
    const hovered = v != null ? [v] : [];

    this.hoverOverlay.call(planes, hovered);
    return this.hoverOverlay.call(ellipses, hovered);
  }

  dataChanged() {
    this.main.call(planes, this.props.data);
    return this.main.call(ellipses, this.props.data);
  }

  updateSize() {
    this.svg.attrs({ height: this.props.width, width: this.props.width });
    return proj
      .scale(this.props.width / 2 - 20)
      .translate([this.props.width / 2, this.props.width / 2]);
  }

  updatePaths() {
    return this.container.selectAll("path").attrs({ d: path });
  }
}
StereonetView.initClass();

module.exports = StereonetView;

/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import * as d3 from "d3";
import L from "leaflet";
import {
  LayerGroup,
  Polygon,
  Polyline,
  GeoJSON,
  Pane,
  SVGOverlay,
  useMapEvent,
} from "react-leaflet";
import { Component, useState, useCallback } from "react";
import { findDOMNode } from "react-dom";
import h from "@macrostrat/hyper";
import classNames from "classnames";
import { NavLink } from "react-router-dom";

const fmt = d3.format(".0f");

const eventHandlers = function (record) {
  const onMouseDown = () => app.data.updateSelection(record);
  const onMouseOver = () => app.data.hovered(record);
  const onMouseOut = () => app.data.hovered(null);
  return { onMouseOver, onMouseOut, onMouseDown };
};

class _StrikeDip extends Component {
  constructor(props) {
    super(props);
    this.state = this.buildState();
  }

  shouldComponentUpdate(nextProps) {
    const { record, zoom } = this.props;
    if (zoom !== nextProps.zoom) {
      return true;
    }
    if (record !== nextProps.record) {
      return true;
    }
    return false;
  }

  buildState(props) {
    if (props == null) {
      ({ props } = this);
    }
    const { record, projection } = props;
    const c = record.center.coordinates;

    const location = projection(c[0], c[1]);
    return { location };
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.zoom !== this.props.zoom) {
      return this.setState(this.buildState(nextProps));
    }
  }

  render() {
    const { record, projection, zoom } = this.props;
    const { location } = this.state;
    const { strike, dip, selected, hovered, center } = record;
    const scalar = 5 + 0.2 * zoom;

    const className = classNames("strike_dip", "marker", {
      hovered,
      selected,
    });

    const transform = `translate(${location.x} ${location.y}) \
rotate(${strike} 0 0) \
scale(${0.5 + 0.1 * zoom})`;

    const handlers = eventHandlers(record);
    return h("g", { transform, className, ...handlers }, [
      h("line", { x2: 5, stroke: "black" }),
      h("line", { y1: -10, y2: 10, stroke: "black" }),
      h(
        "text.dip-magnitude",
        {
          x: 10,
          textAnchor: "middle",
          dy: scalar / 2,
          fontSize: scalar,
          transform: `rotate(${-strike} 10 0)`,
        },
        fmt(dip)
      ),
    ]);
  }
}

function StrikeDip(props) {
  const { record, zoom, projection } = props;
  const { strike, dip, selected, hovered, center } = record;
  const scalar = 5 + 0.2 * zoom;

  if (projection == null) return null;

  const c = record.center.coordinates;
  const location = projection(c[0], c[1]);
  console.log(c, zoom, location);

  const className = classNames("strike_dip", "marker", {
    hovered,
    selected,
  });

  const transform = `translate(${location.x} ${location.y}) \
rotate(${strike} 0 0) \
scale(${0.5 + 0.1 * zoom})`;

  const handlers = eventHandlers(record);
  return h("g", { transform, className, ...handlers }, [
    h("line", { x2: 5, stroke: "black" }),
    h("line", { y1: -10, y2: 10, stroke: "black" }),
    h(
      "text.dip-magnitude",
      {
        x: 10,
        textAnchor: "middle",
        dy: scalar / 2,
        fontSize: scalar,
        transform: `rotate(${-strike} 10 0)`,
      },
      fmt(dip)
    ),
  ]);
}

function DataLayer(props) {
  const { records } = props;

  const [zoom, setZoom] = useState(null);
  console.log(map);
  const map = useMapEvent("zoom", () => {
    setZoom(map.getZoom());
  });

  //const origin = map.getPixelOrigin();
  const origin = map.getPixelOrigin();
  const projection = useCallback(
    (x, y) => {
      const pt = map.latLngToLayerPoint(new L.LatLng(y, x));
      return { x: pt.x + origin.x, y: pt.y + origin.y };
    },
    [map, zoom]
  );
  const worldBounds = map.getPixelWorldBounds();

  const transform = d3.geoTransform({
    point(x, y) {
      const point = projection(x, y);
      return this.stream.point(point.x, point.y);
    },
  });
  const pathGenerator = d3.geoPath().projection(transform);

  console.log(origin, map.getPixelWorldBounds());
  // const projection = d3.geoTransform({
  //   point(x, y) {
  //     const point = proj(x, y);
  //     return this.stream.point(point.x, point.y);
  //   },
  // });

  if (projection == null) return null;

  return h(Pane, [
    h(
      "svg.data-layer.leaflet-zoom-hide",
      {
        width: worldBounds.max.x,
        height: worldBounds.max.y,
        transform: `translate(${-origin.x},${-origin.y})`,
      },
      [
        h(
          "g.markers",
          records.map((d) =>
            h(StrikeDip, {
              key: d.id,
              record: d,
              projection,
              zoom: zoom ?? map.getZoom(),
            })
          )
        ),
        h(
          "g.features",
          records.map((d) => h(Feature, { record: d, pathGenerator }))
        ),
      ]
    ),
  ]);
}

// class _Feature extends Component {
//   constructor(props) {
//     super(props);
//     this.state = this.buildState();
//   }

//   shouldComponentUpdate(nextProps) {
//     const { record, pathGenerator } = this.props;
//     if (pathGenerator !== nextProps.pathGenerator) {
//       return true;
//     }
//     if (record !== nextProps.record) {
//       return true;
//     }
//     return false;
//   }

//   buildState(props) {
//     if (props == null) {
//       ({ props } = this);
//     }
//     const { record, pathGenerator } = props;
//     const d = pathGenerator(record);
//     return { d };
//   }

//   componentWillReceiveProps(nextProps) {
//     if (nextProps.pathGenerator !== this.props.pathGenerator) {
//       return this.setState(this.buildState(nextProps));
//     }
//   }

//   render() {
//     const { record, pathGenerator } = this.props;
//     const handlers = eventHandlers(record);
//     const { selected, hovered } = record;

//     const className = classNames(record.geometry.type, { hovered, selected });

//     const { d } = this.state;
//     return h("path", { className, d, ...handlers });
//   }
// }

function Feature(props) {
  const { record, pathGenerator } = props;
  const handlers = eventHandlers(record);
  const { selected, hovered } = record;

  const className = classNames(record.geometry.type, { hovered, selected });

  const d = pathGenerator(record);

  return h("path", { className, d, ...handlers });
}

/*
class _DataLayer extends MapLayer {
  constructor(props) {
    super(props);
    this.buildProjection = this.buildProjection.bind(this);
    console.log("Created data layer");
    this.state = { zoom: null };
  }

  buildProjection() {
    console.log("Building projection");
    const { map } = this.context;
    const zoom = map.getZoom();
    const proj = (x, y) => map.latLngToLayerPoint(new L.LatLng(y, x));
    const projection = d3.geoTransform({
      point(x, y) {
        const point = proj(x, y);
        return this.stream.point(point.x, point.y);
      },
    });
    const pathGenerator = d3.geoPath().projection(projection);
    return this.setState({ projection: proj, pathGenerator, zoom });
  }

  createLeafletElement() {
    return new L.SVG({ padding: 0.1 });
  }

  render() {
    console.log("Rendering data layer");
    const { records } = this.props;
    const { projection, pathGenerator, zoom } = this.state;

    if (projection == null) {
      return null;
    }

    const data = records.filter((d) => !d.in_group);

    const children = data.map((record) => {
      return h(StrikeDip, { key: record.id, record, projection, zoom });
    });

    const childFeatures = data.map((record) => {
      return h(Feature, {
        key: record.id,
        record,
        pathGenerator,
      });
    });

    return h("div.data-layer-container", [
      h("svg.data-layer.leaflet-zoom-hide", {}, [
        h("g.features", childFeatures),
        h("g.markers", children),
      ]),
    ]);
  }

  componentDidMount() {
    console.log("Mounted data layer");
    // Bind renderer to SVG
    this.leafletElement._container = findDOMNode(this);
    this.buildProjection();
    this.context.map.on("zoomend", this.buildProjection);
    return super.componentDidMount(...arguments);
  }

  componentWillUnmount() {
    console.log("Unmounted data layer");
    return super.componentWillUnmount(...arguments);
  }
}
*/

// function Feature(props) {
//   const { record } = props;
//   const { geometry } = record;
//   const p1 = {
//     positions: geometry.coordinates,
//     pathOptions: { color: "lime" },
//   };
//   switch (geometry.type) {
//     case "Polygon":
//     case "MultiPolygon":
//       return h(Polygon, p1);
//     case "LineString":
//     case "MultiLineString":
//       return h(Polyline, p1);
//     default:
//       return null;
//   }
// }

// function DataLayer(props) {
//   const { records } = props;
//   // return h(
//   //   LayerGroup,
//   //   records.map((d) => h(Feature, { key: d.id, record: d }))
//   // );
//   return h(LayerGroup, [
//     h(GeoJSON, { data: { type: "FeatureCollection", features: records } }),
//     h(Orientations, { records }),
//   ]);
// }

export default DataLayer;

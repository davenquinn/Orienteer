/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import * as d3 from "d3";
import L from "leaflet";
import { Pane, useMapEvent } from "react-leaflet";
import { Component, useState, useCallback, useEffect } from "react";
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

function DataLayer(props) {
  const { records } = props;

  const nullBounds = { x: 0, y: 0 };
  const [zoom, setZoom] = useState(null);
  const [bounds, setBounds] = useState({ min: nullBounds, max: nullBounds });
  //console.log(map);
  const map = useMapEvent("zoom moveend", () => {
    setZoom(map.getZoom());
    setBounds(map.getPixelBounds());
  });

  useEffect(() => {
    setZoom(map.getZoom());
    setBounds(map.getPixelBounds());
  }, [map]);

  const padding = 5000;
  const origin = { x: bounds?.min.x - padding, y: bounds.min.y - padding };

  const pixelOffset = map.getPixelOrigin();

  //const padding = 10000;
  //const offset = { x: bounds.min.x - padding, y: bounds.min.y - padding };
  //console.log(origin, worldBounds?.min, bounds.min, offset);

  //const pixelOffset = {x: .x, y: origin.y};

  const projection = useCallback(
    (x, y) => {
      const pt = map.latLngToLayerPoint(new L.LatLng(y, x));
      return {
        x: pt.x - origin.x + pixelOffset.x,
        y: pt.y - origin.y + pixelOffset.y,
      };
    },
    [map, origin]
  );

  const transform = d3.geoTransform({
    point(x, y) {
      const point = projection(x, y);
      return this.stream.point(point.x, point.y);
    },
  });
  const pathGenerator = d3.geoPath().projection(transform);

  if (projection == null || origin == null) return null;

  return h(Pane, [
    h(
      "svg.data-layer.leaflet-zoom-hide",
      {
        width: bounds.max.x - bounds.min.x + padding * 2,
        height: bounds.max.y - bounds.min.y + padding * 2,
        transform: `translate(${origin.x - pixelOffset.x},${
          origin.y - pixelOffset.y
        })`,
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

function Feature(props) {
  const { record, pathGenerator } = props;
  const handlers = eventHandlers(record);
  const { selected, hovered } = record;

  const className = classNames(record.geometry.type, { hovered, selected });

  const d = pathGenerator(record);

  return h("path", { className, d, ...handlers });
}

function StrikeDip(props) {
  const { record, zoom, projection } = props;
  const { strike, dip, selected, hovered, center } = record;
  const scalar = 5 + 0.2 * zoom;

  if (projection == null) return null;

  const c = center.coordinates;
  const location = projection(c[0], c[1]);

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

export default DataLayer;

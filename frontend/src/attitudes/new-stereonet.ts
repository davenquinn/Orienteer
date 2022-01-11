import h from "@macrostrat/hyper";
import {
  Globe,
  FeatureLayer,
  GraticuleLabels,
  useMap,
  CoordinateAxis,
  formatAzimuthLabel,
} from "@macrostrat/map-components";
import { Orientation } from "@attitude/core";
import { Attitude } from "app/data-manager/types";
import { errorEllipse } from "@attitude/core/src/functions";
import { useAppState } from "app/hooks";
import { useState } from "react";
import useAsyncEffect from "use-async-effect";
import { get } from "axios";
import { feature } from "topojson-client";
import { geoAzimuthalEqualArea } from "d3-geo";
import chroma from "chroma-js";

export function transformRecord(record: Attitude): Orientation {
  return {
    ...record,
    minError: record.min_angular_error,
    maxError: record.max_angular_error,
  };
}

function SelectedPlanes(props) {
  const data = useAppState((d) => Array.from(d.selected));
  const color = chroma("#888888");
  const fn = errorEllipse({
    level: 1,
    color: "#ddd",
    degrees: true,
    traditionalLayout: false,
    adaptive: true,
  });
  const features = data.map((d) => {
    let f = fn(transformRecord(d));
    f.id = d.id;
    return f;
  });
  return h(FeatureLayer, {
    features,
    style: { fill: color.alpha(0.2).css(), stroke: color.alpha(0.4).css() },
    useCanvas: true,
  });
}

function DipLabels({ spacing = 5 }) {
  const { projection, height, width } = useMap();
  const center = projection([0, 90]);
  const scale = projection.scale();
  return h(GraticuleLabels, {
    spacing,
    start: { x: 5, y: height - 5 },
    end: { x: center[0], y: center[1] },
    axis: CoordinateAxis.Latitude,
    formatValue: (d) => `${90 - d.value}°`,
    labelProps: {
      transform: "translate(-3 3)",
    },
  });
}

function AzimuthLabels() {
  const { width, height } = useMap();
  return h(GraticuleLabels, {
    start: { x: 0, y: 0 },
    end: { x: width, y: 0 },
    axis: CoordinateAxis.Longitude,
    transform: "translate(0 -2)",
    formatValue: formatAzimuthLabel,
    spacing: 20,
  });
}

function AzimuthLabels2() {
  const { width, height } = useMap();
  return h(GraticuleLabels, {
    start: { x: width, y: 0 },
    end: { x: width, y: height },
    axis: CoordinateAxis.Longitude,
    transform: "translate(3 0)",
    rotate: 90,
    formatValue: formatAzimuthLabel,
    spacing: 20,
  });
}

export function NewStereonet({
  width = 100,
  height = 100,
  scale,
  dipLabelSpacing = 5,
}) {
  return h(
    Globe,
    {
      width,
      height,
      margin: 20,
      center: [0, 90],
      scale: scale ?? width,
      graticuleSpacing: [20, dipLabelSpacing],
      keepNorthUp: true,
      projection: geoAzimuthalEqualArea(),
      onClick() {},
    },
    [
      h(SelectedPlanes, { key: "selected-planes" }),
      h(DipLabels, { spacing: dipLabelSpacing }),
      h(AzimuthLabels),
      h(AzimuthLabels2),
    ]
  );
}

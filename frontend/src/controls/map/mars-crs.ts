import { Earth } from "leaflet/src/geo/crs/CRS.Earth";
import { SphericalMercator } from "leaflet/src/geo/projection";
import { extend } from "leaflet/src/core/Util";
import { Bounds, transformation } from "leaflet/src/geometry";

const marsRadius = 3396190;

export const MarsSphericalMercator = extend({}, SphericalMercator, {
  R: marsRadius,
  MAX_LATITUDE: 85.0511287798,
  bounds: (function () {
    var d = marsRadius * Math.PI;
    return new Bounds([-d, -d], [d, d]);
  })(),
});

export const Mars = extend({}, Earth, {
  wrapLng: [-180, 180],

  // Mean Earth Radius, as recommended for use by
  // the International Union of Geodesy and Geophysics,
  // see http://rosettacode.org/wiki/Haversine_formula
  R: marsRadius,
});

export const MARS949901 = extend({}, Mars, {
  code: "USER:949901",
  projection: MarsSphericalMercator,

  transformation: (function () {
    var scale = 0.5 / (Math.PI * MarsSphericalMercator.R);
    return transformation(scale, 0.5, -scale, 0.5);
  })(),
});

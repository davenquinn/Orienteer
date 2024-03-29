/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import L from "leaflet";
import proj4 from "proj4";

const createProjection = function (def, options) {
  options = options || {};
  if (!("resolutions" in options)) {
    if (!"minResolution" in options) {
      throw "minResolution required if resolutions are not specified";
    }
    const res = [];
    let r = options.minResolution;
    const limit = options.maxResolution || 0.1;
    while (r > limit) {
      res.push(r);
      r /= 2;
    }
    options.resolutions = res;
  }

  const p = proj4.Proj(def);
  if (p.datum.a != null) {
    // Allows resizing of scalebar (a bit hackish)
    L.CRS.Earth.R = p.datum.a;
  }

  // Setup geographic coordinate system
  const geog = {
    projName: "longlat",
    a: p.datum.a,
    b: p.datum.b,
    no_defs: true,
  };
  const gp = proj4.Proj(geog);

  const projection = proj4(gp, p);

  // if (!("bounds" in options)) {
  //   throw "bounds required";
  // }
  // const _bounds = options.bounds
  //   .map(projection.forward)
  //   .map((d) => L.point(d[0], d[1]));
  // const bounds = L.bounds(_bounds);

  const Projection = {
    //bounds,
    project(ll) {
      const out = projection.forward([ll.lng, ll.lat]);
      return new L.Point(out[0], out[1]);
    },
    unproject(pt) {
      const out = projection.inverse([pt.x, pt.y]);
      return new L.LatLng(out[1], out[0]);
    },
  };

  return L.extend({}, L.CRS.Earth, {
    code: "IAU:950000",
    projection: Projection,
    // transformation: new L.Transformation(1, -bounds.min.x, -1, bounds.max.y),
    // scale(zoom) {
    //   return 1 / options.resolutions[zoom];
    // },
    // wrapLng: null,
    // resolution(zoom) {
    //   return options.resolutions[zoom];
    // },
  });
};

export { createProjection };

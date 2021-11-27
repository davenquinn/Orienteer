// Can't use native pg extension right now
import Promise from "bluebird";
const pgp = require("pg-promise")({ promiseLib: Promise });
import { Buffer } from "buffer";
import { Geometry } from "wkx";
import path from "path";

const cfg = require(process.env.ORIENTEER_CONFIG);

const debug = true;
Promise.longStackTraces();

const getOIDs = `SELECT oid, typname AS name \
FROM pg_type \
WHERE typname = ANY($1::text[])`;

const conString = cfg.database_uri;
const db = pgp(conString);

const defaults = { geoJSON: false };

// Setup parsers
// This includes a race condition at app startup that
// could prove pernicious
const parsers = {
  geometry(val) {
    const buf = new Buffer(val, "hex");
    return Geometry.parse(buf);
  },
};

db.query(getOIDs, [Object.keys(parsers)]).then((res) =>
  (() => {
    const result = [];
    for (let o of Array.from(res)) {
      const { types } = pgp.pg;
      result.push(types.setTypeParser(o.oid, parseVal(parsers[o.name])));
    }
    return result;
  })()
);

var parseVal = (func) =>
  function (v) {
    if (v == null) {
      return;
    }
    v = func(v);
    return v.toGeoJSON();
  };

module.exports = {
  db,
  storedProcedure(procID) {
    // Returns a stored procedure
    const fn = path.join(__dirname, "sql", `${procID}.sql`);
    return new pgp.QueryFile(fn, { minify: true });
  },
};

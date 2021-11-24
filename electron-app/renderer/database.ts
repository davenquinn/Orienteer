/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// Can't use native pg extension right now
const Promise = require("bluebird");
const pgp = require("pg-promise")({ promiseLib: Promise });
const { Buffer } = require("buffer");
const { Geometry } = require("wkx");
const path = require("path");

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

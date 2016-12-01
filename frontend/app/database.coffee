# Can't use native pg extension right now
Promise = require 'bluebird'
pgp = require('pg-promise')(promiseLib: Promise)
{Buffer} = require 'buffer'
{Geometry} = require 'wkx'

getOIDs = "SELECT oid, typname AS name
           FROM pg_type
           WHERE typname = ANY($1::text[])"

conString = "postgres://localhost/syrtis"
db = pgp conString

defaults =
  geoJSON: false

# Setup parsers
# This includes a bit of a race condition that
# could prove pernicious
parsers =
  geometry: (val)->
    buf = new Buffer val,'hex'
    Geometry.parse buf

db.query getOIDs, [Object.keys parsers]
  .then (res)->
    for o in res
      types = pgp.pg.types
      types.setTypeParser o.oid, parseVal(parsers[o.name])

parseVal = (func)->
  (v)->
    return unless v?
    v = func v
    v.toGeoJSON()

module.exports =
  db: db
  storedProcedure: (procID)->
    # Returns a stored procedure
    fn = path.join __dirname, 'sql', "#{procID}.sql"
    new pgp.QueryFile fn, minify: true


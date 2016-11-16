# Can't use native pg extension right now
pg = require 'pg'
fs = require 'fs'
path = require 'path'

conString = "postgres://localhost/syrtis"

query = (args...)->
  ###
  arguments:
    sql string
    ((data))
    (callback)
  ###
  sql = args[0]
  console.log sql
  data = null
  callback = (e,r)->
  if args.length == 2
    callback = args[1]
  if args.length == 3
    data = args[1]
    callback = args[2]

  config =
    host: 'localhost'
    user: 'Daven'
    database: 'syrtis'

  client = new pg.Client(config)

  client.connect (e)->
    callback(e) if e
    client.query sql, data, (err, res)->
      callback(err, res)
      client.end()

module.exports =
  query: query
  storedProcedure: (procID)->
    # Returns a function that uses a stored
    # query from a file
    fn = path.join __dirname, 'sql', "#{procID}.sql"
    sql = fs.readFileSync(fn).toString()
    (args...)->
      args.unshift sql
      console.log args
      query(args...)

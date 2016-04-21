pg = require('pg').native
conString = "postgres://localhost/Gale"

module.exports = ->
  sql = arguments[0]
  data = null
  callback = (e,r)->
  if arguments.length == 2
    callback = arguments[1]
  if arguments.length == 3
    data = arguments[1]
    callback = arguments[2]

  pg.connect conString, (e,client,done)->
    return e if e
    client.query sql, data, (err, res)->
      done()
      callback(err, res)

fs = require 'fs'
app = require "app"
browserSync = require "browser-sync"
connectUtils = require 'browser-sync/lib/connect-utils'
path = require 'path'

port = 35729
server = "http://localhost:#{port}"

getClientUrl = (opts) ->
  pathname = connectUtils.clientScript(opts)
  "#{server}#{pathname}"

module.exports = (cb)->
  styleDir = path.join app.config.buildDir, 'styles'
  outputStyles = path.join(styleDir,'*.css')
  list = app.config.watch.scripts
  list.push outputStyles

  cfg =
    ui: false
    files: list
    open: false
    port: port
    socket:
      domain: server

  return browserSync.init cfg, (err,bs)=>
    console.log "Starting synchronization"
    bs.url =  getClientUrl(bs.options)
    cb(err,bs)

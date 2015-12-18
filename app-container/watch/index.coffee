app = require "app"
browserSync = require "browser-sync"
connectUtils = require 'browser-sync/lib/connect-utils'
gulp = require 'gulp'
path = require 'path'

styleCompiler = require './styles'

port = 35729
server = "http://localhost:#{port}"

getClientUrl = (opts) ->
  pathname = connectUtils.clientScript(opts)
  "#{server}#{pathname}"

module.exports = (cb)->
  styles = app.config.watch.styles
  styleDir = path.join app.config.buildDir, 'styles'

  compileStyles = styleCompiler app.config.styleEndpoint, styleDir

  list = app.config.watch.scripts
  list.push path.join(styleDir,'*.css')

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

    console.log "Setting up CSS compilation"
    gulp.watch styles, compileStyles
    cb(err,bs)

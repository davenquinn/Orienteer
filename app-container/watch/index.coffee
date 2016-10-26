{app} = require 'electron'
{init} = require "electron-browser-sync"
path = require 'path'

module.exports = (cb)->
  styleDir = path.join app.config.buildDir, 'styles'
  outputStyles = path.join(styleDir,'*.css')
  list = app.config.watch.scripts
  list.push outputStyles

  return init list, cb

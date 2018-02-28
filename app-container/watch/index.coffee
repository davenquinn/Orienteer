{app} = require 'electron'
path = require 'path'

init = (list, cb)->
  cb()

module.exports = (cb)->
  styleDir = path.join app.config.buildDir, 'styles'
  outputStyles = path.join(styleDir,'*.css')
  list = app.config.watch.scripts
  list.push outputStyles

  return init list, cb

#!/usr/bin/env coffee
gulp = require 'gulp'
glob = require 'glob'
path = require 'path'
styleCompiler = require './app-container/watch/styles'

styles = './**/*.scss'
styleDir = path.join './build', 'styles'

compileStyles = styleCompiler 'frontend/style.scss', styleDir

outputStyles = path.join(styleDir,'*.css')

console.log "Setting up CSS compilation"
glob outputStyles, (err, files)->
  # if output files don't exist at all
  console.log "Compiling initial css"
  if files.length == 0
    compileStyles()

gulp
  .src './node_modules/leaflet-draw/dist/**'
  .pipe gulp.dest('./build/styles/')

gulp.watch styles, compileStyles


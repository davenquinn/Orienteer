gulp = require("gulp")
plumber = require("gulp-plumber")
sass = require 'gulp-sass'
sourcemaps = require 'gulp-sourcemaps'
handleErrors = require("./util").handleErrors
cssmin = require("gulp-cssmin")
path = require 'path'

module.exports = (src,dstDir) ->
  return ->
    console.log "Compiling styles", src, dstDir
    # Function to compile styles
    debug = (if global.dist then false else true)
    pipeline = gulp.src(src)
      .pipe sourcemaps.init()
      .pipe sass includePaths: "node_modules"
      .on "error", handleErrors
    if not debug
      pipeline = pipeline.pipe(cssmin())
    pipeline
      .pipe sourcemaps.write '.'
      .pipe gulp.dest(dstDir)

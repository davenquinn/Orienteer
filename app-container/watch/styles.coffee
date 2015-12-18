gulp = require("gulp")
plumber = require("gulp-plumber")
sass = require 'gulp-sass'
sourcemaps = require 'gulp-sourcemaps'
handleErrors = require("./util").handleErrors
cssmin = require("gulp-cssmin")
app = require 'app'
path = require 'path'

module.exports = (src,dstDir) ->
  return ->
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

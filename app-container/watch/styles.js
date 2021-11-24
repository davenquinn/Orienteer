/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const gulp = require("gulp");
const plumber = require("gulp-plumber");
const sass = require("gulp-sass");
const sourcemaps = require("gulp-sourcemaps");
const { handleErrors } = require("./util");
const cssmin = require("gulp-cssmin");
const path = require("path");

module.exports = (src, dstDir) =>
  function () {
    console.log("Compiling styles", src, dstDir);
    // Function to compile styles
    const debug = global.dist ? false : true;
    let pipeline = gulp
      .src(src)
      .pipe(sourcemaps.init())
      .pipe(sass({ includePaths: "node_modules" }))
      .on("error", handleErrors);
    if (!debug) {
      pipeline = pipeline.pipe(cssmin());
    }
    return pipeline.pipe(sourcemaps.write(".")).pipe(gulp.dest(dstDir));
  };

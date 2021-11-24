#!/usr/bin/env ts-node-transpile-only
/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const gulp = require("gulp");
const glob = require("glob");
const path = require("path");
const styleCompiler = require("./app-container/watch/styles");

const styles = "./**/*.scss";
const styleDir = path.join("./build", "styles");

const compileStyles = styleCompiler("frontend/style.scss", styleDir);

const outputStyles = path.join(styleDir, "*.css");

console.log("Setting up CSS compilation");
glob(outputStyles, function (err, files) {
  // if output files don't exist at all
  console.log("Compiling initial css");
  if (files.length === 0) {
    return compileStyles();
  }
});

gulp
  .src("./node_modules/leaflet-draw/dist/**")
  .pipe(gulp.dest("./build/styles/"));

gulp.watch(styles, compileStyles);

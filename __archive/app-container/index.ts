/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const { readFileSync } = require("fs");

const loadConfig = (configPath) =>
  JSON.parse(readFileSync(configPath, "utf-8"));

const { argv } = require("yargs").env("ORIENTEER").config("config", loadConfig);

let config = argv.config || {};
if (typeof config === "string") {
  config = loadConfig(config);
}

global.config = config;

// Assemble a list of files to watch
const list = [];
for (let e of ["coffee", "cjsx", "js", "html", "less", "styl"]) {
  list.push(`frontend/**/*.${e}`);
}

const startApp = require("./app");
startApp(`file://${__dirname}/render/index.html`, {
  serverCommand: [
    "gunicorn",
    "--reload",
    "--error-logfile",
    "-",
    "-b :8000",
    "elevation:app",
  ],
  // Style file that will be compiled as part
  // of building the application
  styleEndpoint: "frontend/style.scss",
  buildDir: "build",
  watch: {
    styles: "./**/*.scss",
    scripts: list,
  },
  ...config
});

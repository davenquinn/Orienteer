{readFileSync} = require 'fs'

loadConfig = (configPath)->
  JSON.parse(readFileSync(configPath, 'utf-8'))

argv = require 'yargs'
  .env('ORIENTEER')
  .config 'config', loadConfig
  .argv

config = argv.config or {}
if typeof config is 'string'
  config = loadConfig config

global.config = config

# Assemble a list of files to watch
list = []
for e in ["coffee","cjsx","js","html","less","styl"]
  list.push "frontend/**/*.#{e}"

startApp = require './app'
startApp "file://#{__dirname}/render/index.html", {
  serverCommand: [
        'gunicorn'
        '--reload'
        '--error-logfile'
        '-'
        '-b :8000'
        'elevation:app'
      ]
  # Style file that will be compiled as part
  # of building the application
  styleEndpoint: 'frontend/style.scss'
  buildDir: "build"
  watch:
    styles: "./**/*.scss"
    scripts: list
  config...
}

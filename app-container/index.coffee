{readFileSync} = require 'fs'

argv = require 'yargs'
  .env('ORIENTEER')
  .config 'config', (configPath)->
    JSON.parse(readFileSync(configPath, 'utf-8'))
  .argv

config = argv.config or {}

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

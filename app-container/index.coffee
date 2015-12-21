# Assemble a list of files to watch
list = []
for i in ['elevation/frontend','shared-components']
  for e in ["coffee","cjsx","js","html"]
    list.push "#{i}/**/*.#{e}"

startApp = require './app'
startApp "file://#{__dirname}/render/index.html",
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

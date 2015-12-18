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
        'elevation.wsgi:application'
      ]
  # Style file that will be compiled as part
  # of building the application
  styleEndpoint: 'elevation/frontend/style.scss'
  buildDir: "_static"
  watch:
    styles: "./**/*.scss"
    scripts: list

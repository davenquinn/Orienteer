_ = require 'underscore'
path = require 'path'
app = require 'app'
BrowserWindow = require 'browser-window'
queue = require 'queue-async'

startServer = require './server'
watchCommand = require './watch'
setupConfig = require './config'

# Keep a global reference of the window object, if you don't, the window will
# be closed automatically when the JavaScript object is garbage collected.
global.mainWindow = null

setupApp = (cb)->

  app.server = startServer app.config.serverCommand
  # Quit when all windows are closed.
  app.on 'window-all-closed', ->
    app.quit()

  cleanup = ->
    app.server.kill("SIGINT")
    console.log "Quitting"

  app.on 'quit', cleanup

  app.on 'ready', (d)->
    cb(null,d)

# This method will be called when Electron has finished
# initialization and is ready to create browser windows.
startApp = (url)->
  # Create the browser window.
  mainWindow = new BrowserWindow
   width: 800
   height: 600
  # and load the index.html of the app.
  mainWindow.loadUrl url
  # Open the DevTools.
  #mainWindow.openDevTools();
  # Emitted when the window is closed.
  mainWindow.on 'closed', ->
    # Dereference the window object, usually you would store windows
    # in an array if your app supports multi windows, this is the time
    # when you should delete the corresponding element.
    mainWindow = null

# Load the application window after the server is
# set up
module.exports = (url, cfg)->

  # Right now, the environment variable "NODE_MAP_CONFIG"
  # should point to the config file
  config = setupConfig process.env.ELEVATION_NODE_CONFIG
  config = _.defaults(cfg or {}, config)
  app.config = config

  # Setup style directories (based on some
  # assumptions about internal structure currently)
  build = app.config.buildDir
  fn =  app.config.styleEndpoint
  ex = path.extname fn
  fn = path.basename fn,ex
  styleName = path.join '../..', build,'styles',fn+'.css'

  q = queue().defer setupApp
  if app.config.watch
    q.defer watchCommand

  q.await (e,ready,bs)->
      if bs?
        global.BROWSER_SYNC_CLIENT_URL = bs.url
        global.STYLESHEET_URL = styleName
      startApp(url)

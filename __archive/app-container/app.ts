/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const _ = require("underscore");
const path = require("path");
const { app, BrowserWindow } = require("electron");
const queue = require("queue-async");

const startServer = require("./server");
const watchCommand = require("./watch");

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
global.mainWindow = null;
global.config = app.config;

const setupApp = function (cb) {
  app.server = startServer(app.config.serverCommand);
  // Quit when all windows are closed.
  app.on("window-all-closed", () => app.quit());

  const cleanup = function () {
    app.server.kill("SIGINT");
    return console.log("Quitting");
  };

  app.on("quit", cleanup);

  return app.on("ready", (d) => cb(null, d));
};

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
const startApp = function (url) {
  // Create the browser window.
  let mainWindow = new BrowserWindow({
    title: app.config.title || "Orienteer",
    width: 800,
    height: 600,
  });
  // and load the index.html of the app.
  mainWindow.loadURL(url);
  // Open the DevTools.
  //mainWindow.openDevTools();
  // Emitted when the window is closed.
  return mainWindow.on(
    "closed",
    () =>
      // Dereference the window object, usually you would store windows
      // in an array if your app supports multi windows, this is the time
      // when you should delete the corresponding element.
      (mainWindow = null)
  );
};

// Load the application window after the server is
// set up
module.exports = function (url, cfg) {
  console.log("Loading application window");

  app.config = cfg;
  app.state = { page: "attitudes" };

  const q = queue().defer(setupApp);
  if (app.config.watch) {
    q.defer(watchCommand);
  }

  return q.await(function (e, ready, bs) {
    if (bs != null) {
      global.STYLE_PATH = path.join(
        process.env.PWD,
        app.config.buildDir,
        "styles"
      );
    }
    return startApp(url);
  });
};

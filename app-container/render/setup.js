require("./register").transform();
require("electron-browser-sync/inject");
require('./style-hooks')
require('./setup-styles')

require("handlebars")
require.extensions['.html'] = require.extensions['.hbs']

console.log("Using node version",process.version);



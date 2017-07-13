require("coffeescript/register")
require("node-cjsx/register")
require("electron-browser-sync/inject");
require('./style')

require("handlebars")
require.extensions['.html'] = require.extensions['.hbs']

path = require("path")

remote = require("electron").remote;
stylePath = remote.getGlobal("STYLE_PATH")
stylesheetPath = path.join(stylePath,styleName+'.css')

console.log("Using node version",process.version);

/* Append stylesheet */
li = document.createElement('link')
li.type = 'text/css'
li.rel = 'stylesheet'
li.href = 'file://'+stylesheetPath;
document.head.appendChild(li);

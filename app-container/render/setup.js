less = require('less');
lessParser = require('postcss-less').parse;

require("coffee-script/register")
require("node-cjsx/register")
require('css-modules-electron/register')
require('css-modules-electron')({
  extensions: ['.less'],
  processorOpts: {parser: lessParser},
  processCss: function(css, filepath) {
      var out;
      less.render(css,
        {filename: filepath, async: false, processImports:false, isSync: true},
        function(e, output){
          if(e){
            console.log(css);
            throw e;
          }
          out = output.css;
        });
      return out;
	}
});

require("handlebars")
require.extensions['.html'] = require.extensions['.hbs']
remote = require("remote")
path = require("path")

client_url = remote.getGlobal("BROWSER_SYNC_CLIENT_URL")
stylePath = remote.getGlobal("STYLE_PATH")

stylesheetPath = path.join(stylePath,styleName+'.css')

if (client_url) {
  current = document.currentScript;
  script = document.createElement('script');
  script.src = client_url;
  script.async = true;
  current.parentNode.insertBefore(script, current);
  console.log("Using node version",process.version);

  /* Append stylesheet */
  li = document.createElement('link')
  li.type = 'text/css'
  li.rel = 'stylesheet'
  li.href = 'file://'+stylesheetPath;
  document.head.appendChild(li);

  stylesheetPath = path.join(stylePath,'elemental.css')
  /* Append stylesheet */
  li = document.createElement('link')
  li.type = 'text/css'
  li.rel = 'stylesheet'
  li.href = 'file://'+stylesheetPath;
  document.head.appendChild(li);
}

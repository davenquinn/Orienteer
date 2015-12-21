require("coffee-script/register")
require("node-cjsx/register")
require("handlebars")
require.extensions['.html'] = require.extensions['.hbs']
remote = require("remote")
client_url = remote.getGlobal("BROWSER_SYNC_CLIENT_URL")
stylesheet_url = remote.getGlobal("STYLESHEET_URL")

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
  li.href = stylesheet_url
  document.head.appendChild(li)
}

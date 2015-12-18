require("coffee-script/register")
require("node-cjsx/register")
require("handlebars")
require.extensions['.html'] = require.extensions['.hbs']
remote = require("remote")
client_url = remote.getGlobal("BROWSER_SYNC_CLIENT_URL")

if (client_url) {
  current = document.currentScript;
  script = document.createElement('script');
  script.src = client_url;
  script.async = true;
  current.parentNode.insertBefore(script, current);
  console.log("Using node version",process.version);
}

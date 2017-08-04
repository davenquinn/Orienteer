{join, resolve} = require 'path'
{remote} = require("electron")

### Add global precompiled styles ###

stylePath = remote.getGlobal("STYLE_PATH")

styles = [
  require.resolve 'leaflet/dist/leaflet.css'
  require.resolve 'font-awesome/css/font-awesome.css'
  require.resolve '@blueprintjs/core/dist/blueprint.css'
]

for style in styles
  li = document.createElement('link')
  li.type = 'text/css'
  li.rel = 'stylesheet'
  li.href = 'file://'+style
  document.head.appendChild li


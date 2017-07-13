{join, resolve} = require 'path'
{remote} = require("electron")

### Add global precompiled styles ###

stylePath = remote.getGlobal("STYLE_PATH")

styles = [
  resolve stylePath,styleName+'.css'
  resolve __dirname, '../../node_modules/@blueprintjs/core/dist/blueprint.css'
]

for style in styles
  li = document.createElement('link')
  li.type = 'text/css'
  li.rel = 'stylesheet'
  li.href = 'file://'+style
  document.head.appendChild li


hook = require 'css-modules-require-hook'
stylus = require 'stylus'
{readFileSync} = require 'fs'


appendStyleToPage = (css)->
  style = document.createElement('style')
  style.type = 'text/css'
  style.innerHTML = css
  document.head.appendChild(style)

# Create hook for css files
require.extensions['.css'] = (module, filename)->
  f = readFileSync filename
  appendStyleToPage f.toString()

# Create hook for stylus files
hook
  extensions: ['.styl'],
  preprocessCss: (css, filename)->
    stylus(css)
      .set('filename', filename)
      .render()
  processCss: appendStyleToPage


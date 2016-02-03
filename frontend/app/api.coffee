d3 = require "d3"
d3.request = require('d3-request').request

## Creates an API function compatible with
#  Mike Bostock's d3 and queue-async modules
#  It can be invoked with the
#  xhr.post, xhr.get, xhr.send('method',data,callback)

module.exports = (url)->
  d3.request window.server_url+"/api"+url
    .header "X-Requested-With", "XMLHttpRequest"
    .mimeType "application/json"
    .response (xhr) -> JSON.parse(xhr.responseText)

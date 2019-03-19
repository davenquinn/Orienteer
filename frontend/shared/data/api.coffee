{request} = require "d3-request"

## Creates an API function compatible with
#  Mike Bostock's d3 and queue-async modules
#  It can be invoked with the
#  xhr.post, xhr.get, xhr.send('method',data,callback)

module.exports = (api_url)->
  if not api_url?
    api_url = window.server_url+"/api"
  (url)->
    request api_url+url
      .mimeType 'application/json'
      .header "X-Requested-With", "XMLHttpRequest"
      .response (xhr)->JSON.parse xhr.responseText

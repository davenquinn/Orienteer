Spine = require 'spine'
Data = require "../../app/data"

class ViewerControl extends Spine.Controller
  className: "data-viewer"
  constructor: ->
    super
    @log @data
    @show(@data)
  show: (d)=>
    if d?
      @el.html "Loading..."
      $.get "#{window.server_url}/elevation/attitude/#{d.id}/data.html",
        (data)=>@el.html data
    else
      @el.html "<p>Hover over data to display fit statistics.</p>"

module.exports = ViewerControl

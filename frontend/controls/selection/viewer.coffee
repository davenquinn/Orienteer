Spine = require 'spine'
Data = require "../../app/data"
template = require './viewer.html'

class ViewerControl extends Spine.Controller
  className: "data-viewer"
  constructor: ->
    super
    @log @data
    @show(@data)
  events:
    "click .close": "close"
  show: (d)=>
    @el.html template()
    el = @$('.data-container')
    if d?
      el.html "Loading..."
      url = "#{window.server_url}/elevation/attitude/#{d.id}/data.html"
      $.get url, (data)=>
        el.html data
    else
      el.html "<p>Hover over data to display fit statistics.</p>"
  close: ->
    @log "Closing grouped data control"
    @trigger "close"

module.exports = ViewerControl

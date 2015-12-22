Spine = require "spine"
MapBase = require "../../shared/map"
SelectBox = require "./select-box"
DataLayer = require "./data-layer"

class Map extends MapBase
  constructor: ->
    super
    window.map = @

  setupMap: =>
    super
    @leaflet.addHandler "boxSelect", SelectBox

  addData: (@data)=>
    @log "Setting up data"

    @dataLayer = new DataLayer
    @layers.overlayMaps["Bedding attitudes"] = @dataLayer
    @dataLayer.addTo @leaflet
    @dataLayer.setupData @data

    @leaflet.on "box-selected", (e)=>
      f = @data.within(e.bounds)
      f.filter (d)->not d.hidden
      @data.selection.addSeveral f

module.exports = Map

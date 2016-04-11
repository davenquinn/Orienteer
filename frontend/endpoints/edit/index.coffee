Spine = require 'spine'
$ = require 'jquery'
GIS = require "gis-core"
L = GIS.Leaflet

DataLayer = require "./data-layer"

class EditorPage extends Spine.Controller
  constructor: ->
    super
    @el.addClass 'editor-page flex-container'

    cfg = app.config.map
    cfg.basedir ?= path.dirname app.config.configFile

    mapContainer = $('<div class="flex" />').appendTo @el

    cfg.boxZoom = false
    @map = new GIS.Map mapContainer[0], cfg
    window.map = @map
    @map.addLayerControl()
    @map.addScalebar()
    @map.invalidateSize()

    lyr = new DataLayer
    lyr.addTo @map

module.exports = EditorPage

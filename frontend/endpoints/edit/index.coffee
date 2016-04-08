Spine = require 'spine'
$ = require 'jquery'
GIS = require "gis-core"

class EditorPage extends Spine.Controller
  constructor: ->
    super
    @el.addClass 'editor-page flex-container'

    cfg = app.config.map
    cfg.basedir ?= path.dirname app.config.configFile

    mapContainer = $('<div class="map flex" />').appendTo @el
    @map = new GIS.Map mapContainer[0], cfg
    window.map = @map
    @map.addLayerControl()
    @map.addScalebar()
    @map.invalidateSize()

module.exports = EditorPage

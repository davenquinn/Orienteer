Spine = require 'spine'
$ = require 'jquery'
GIS = require "gis-core"
leaflet_draw = require('leaflet-draw')

class EditorPage extends Spine.Controller
  constructor: ->
    super
    @el.addClass 'editor-page flex-container'

    cfg = app.config.map
    cfg.basedir ?= path.dirname app.config.configFile

    mapContainer = $('<div class="map flex" />').appendTo @el
    cfg.drawControl = true
    @map = new GIS.Map mapContainer[0], cfg
    window.map = @map
    @map.addLayerControl()
    @map.addScalebar()
    @map.invalidateSize()

    @addData()

  addData: ->
    q = "SELECT id,ST_AsGeoJSON(geometry) FROM dataset_feature WHERE type=$1"
    app.query q, ['Attitude'],(err,rows)->
      if err
        throw err
      console.log rows


module.exports = EditorPage

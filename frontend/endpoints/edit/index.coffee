Spine = require 'spine'
$ = require 'jquery'
GIS = require "gis-core"
L = GIS.Leaflet
leaflet_draw = require('leaflet-draw')

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

    drawnItems = new L.FeatureGroup()
    @map.addLayer drawnItems

    @addData()

  addData: =>
    q = "SELECT id,ST_AsGeoJSON(geometry) geom FROM dataset_feature WHERE type=$1"
    app.query q, ['Attitude'],(err,data)->
      if err
        throw err
      features = data.rows.map (r)->
        {
          id: r.id
          type: "Feature"
          geometry: JSON.parse(r.geom)
        }

      data =
        type: 'FeatureCollection'
        features: features

      s =
        color: 'blue'
        weight: 2
        className: 'leaflet-zoom-hide'

      layer = new L.GeoJSON data, style: s
      @map.addLayer layer

      workingLayer = new L.GeoJSON
      @map.addLayer workingLayer

      drawControl = new L.Control.Draw
        edit:
          featureGroup: workingLayer
      @map.addControl drawControl


module.exports = EditorPage

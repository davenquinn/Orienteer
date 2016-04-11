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

    mapContainer = $('<div class="flex" />').appendTo @el

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

      s =
        color: 'red'
        weight: 2
        className: 'leaflet-zoom-hide'

      d = features.filter (d,i)->i < 10
      layer = new L.GeoJSON features, style: s
        .bindPopup('Hello world!')
      @map.addLayer layer

      workingLayer = new L.FeatureGroup
      @map.addLayer workingLayer

      drawControl = new L.Control.Draw
        edit:
          featureGroup: layer
        draw:
          polyline:
            shapeOptions:
              color: 'dodgerblue'
              weight: 2
            guidelineDistance: 10
      @map.addControl drawControl

      @map.on 'draw:created', (e)->
        map.addLayer e.layer

      layer.on 'click', (e)->
        e.layer.editable = true


module.exports = EditorPage

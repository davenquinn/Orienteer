Spine = require 'spine'
$ = require 'jquery'
GIS = require "gis-core"
L = GIS.Leaflet
leaflet_draw = require('leaflet-draw')
chroma = require 'chroma-js'

DataLayerBase = require "gis-core/frontend/helpers/data-layer"

q = "SELECT id,ST_AsGeoJSON(geometry) geom FROM dataset_feature WHERE type=$1"

class DataLayer extends DataLayerBase
  constructor: ->
    super

  onAdd: =>
    super
    @container = @svg.append 'g'

    app.query q, ['Attitude'],(err,data)=>
      if err
        throw err
      features = data.rows.map (r)=>
        {
          id: r.id
          type: "Feature"
          geometry: JSON.parse(r.geom)
        }
      @addFeatures features


  addFeatures: (features)=>

    @features = @container.selectAll 'path'
      .data features

    @features.enter()
      .append "path"
        .attr
          class: (d)->d.geometry.type
          d: @path
          stroke: 'red'
          'stroke-width': 2
          fill: (d)->
            if d.geometry.type == 'Polygon'
              c = chroma('red').alpha(0.5).css()
            else
              c = 'transparent'
            console.log c
            return c

    @_map.on "zoomend", @resetView

  resetView: =>
    console.log "Resetting view"
    @features.attr d: @path

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

    lyr = new DataLayer
    lyr.addTo @map

module.exports = EditorPage

chroma = require 'chroma-js'
d3 = require 'd3'

DataLayerBase = require "gis-core/frontend/helpers/data-layer"
Polygon = require '../../controls/polygon-editor/polygon'

q = "SELECT id,ST_AsGeoJSON(geometry) geom FROM dataset_feature WHERE type=$1"

class Editor

class DataLayer extends DataLayerBase
  constructor: ->
    super

  onAdd: =>
    super
    @container = @svg.append 'g'
    @editContainer = @svg.append 'g'

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
        .on 'click', @setupEditor
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


  setupEditor: (d)=>
    @container.attr display: 'none'
    sel = @editContainer.append 'g'
      .datum d
      .call editor

    path = sel.append 'path'
      .attr stroke: 'lightblue'
        d: @path

    coords = d.geometry.coordinates

    polygon = new Polygon @
    d3.select(@svg.node())
      .on "click", ->
        if d3.event.shiftKey
          polygon.addPoint()

    polygon.on "closed", =>
      console.log "The polygon is closed"
      @trigger "editing:closed", @areas

  resetView: =>
    console.log "Resetting view"
    @features.attr d: @path

module.exports = DataLayer


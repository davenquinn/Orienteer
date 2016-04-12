chroma = require 'chroma-js'
d3 = require 'd3'
d3tip = require('d3-tip')(d3)

DataLayerBase = require "gis-core/frontend/helpers/data-layer"
Editor = require './feature-editor'

q = "SELECT id,ST_AsGeoJSON(geometry) geom FROM dataset_feature WHERE type=$1"

baseColor = chroma 'red'
mainColor = baseColor.desaturate(3)

selected = null

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

    fillFunc = (color)->
      (d)->
        if d.geometry.type == 'Polygon'
          c = color.alpha(0.5).css()
        else
          c = 'none'
        return c

    normalAttrs =
      stroke: mainColor
      fill: fillFunc(mainColor)

    @features.enter()
      .append "path"
        .on 'click', (d)->
          if selected?
            selected.attr normalAttrs
          selected = d3.select @
            .attr
              stroke: baseColor
              fill: fillFunc baseColor
        .attr normalAttrs
        .attr
          'stroke-width': 2
          class: (d)->d.geometry.type
          d: @path

    @_map.on "zoomend", @resetView


  setupEditor: (d)=>
    @container.attr display: 'none'
    @editor = new Editor d,@

  resetView: =>
    console.log "Resetting view"
    @features.attr d: @path

module.exports = DataLayer


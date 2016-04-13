chroma = require 'chroma-js'
d3 = require 'd3'

Spine = require 'spine'

DataLayerBase = require "gis-core/frontend/helpers/data-layer"
Editor = require './feature-editor'

q = "SELECT id,ST_AsGeoJSON(geometry) geom FROM dataset_feature WHERE type=$1"

baseColor = chroma 'red'
mainColor = baseColor.desaturate(3)

selected = null

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

selectedAttrs =
  stroke: baseColor
  fill: fillFunc baseColor


class DataLayer extends DataLayerBase
  constructor: ->
    super d3: d3
    @events = d3.dispatch ['selected']

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
    trigger = @trigger

    @features = @container.selectAll 'path'
      .data features

    sel = @events.selected
    @features.enter()
      .append "path"
        .on 'click', @events.selected
        .attr normalAttrs
        .attr
          'stroke-width': 2
          class: (d)->d.geometry.type
          d: @path

    @_map.on "zoomend", @resetView

  setSelected: (sel)=>
    if not sel?
      @features.attr normalAttrs
      return
    @features.each (d)->
      el = d3.select @
      v = if d.id == sel.id then selectedAttrs else normalAttrs
      el.attr v

  setupEditor: (sel)=>
    return unless sel?
    console.log "Starting editor"
    @features.filter (d)->d.id == sel.id
      .attr display: 'none'
    @editor = new Editor sel,@

  resetView: =>
    console.log "Resetting view"
    @features.attr d: @path

module.exports = DataLayer


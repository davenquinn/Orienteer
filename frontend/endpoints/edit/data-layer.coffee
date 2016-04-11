chroma = require 'chroma-js'
d3 = require 'd3'

DataLayerBase = require "gis-core/frontend/helpers/data-layer"
Polygon = require '../../controls/polygon-editor/polygon'

q = "SELECT id,ST_AsGeoJSON(geometry) geom FROM dataset_feature WHERE type=$1"

selected = null
dragged = null

class Editor
  color: 'red'
  constructor: (d, @layer)->
    if d.geometry?
      d = d.geometry
    @el = @layer.editContainer.append 'g'
    @_map = @layer._map
    @path = @layer.path
    @feature = @el.append 'path'
      .datum d
      .attr
        stroke: @color
        fill: chroma(@color).alpha(0.2).css()

    console.log d
    coords = d.coordinates
    if d.type == 'Polygon'
      # Outer ring only
      coords = coords[0]

    @nodes = @el.selectAll 'circle.node'
      .data coords

    @nodes.enter()
      .append 'circle'
      .attr
        class: 'node'
        r: 5
        fill: @color
      .on 'mousedown', (d)=>
        selected = dragged = d
        @_map.dragging.disable()
        @resetView()
      .on 'mouseup', (d)=>
        dragged = null
        @_map.dragging.enable()

    @_map.on 'mousemove', (e)=>
      return unless dragged
      console.log e
      pt = e.latlng
      console.log pt
      dragged[0] = pt.lng
      dragged[1] = pt.lat
      @resetView()

    maxIx = coords.length-1
    d = coords
      .filter (d,i)->i != maxIx
      .map (d,i)->
        e = coords[i+1]
        [(d[0]+e[0])/2,(d[1]+e[1])/2]

    @ghosts = @el.selectAll 'circle.ghost'
      .data d

    @ghosts.enter()
      .append 'circle'
      .attr
        class: 'ghost'
        r: 3
        'stroke-width': 2
        fill: 'white'
        cursor: 'pointer'
        stroke: @color

    @resetView()
    @_map.on "zoomend", @resetView

  resetView: =>
    console.log "Resetting view"
    @feature.attr d: @path

    pt = @layer.projectPoint
    @el.selectAll 'circle'
      .each (d)->
        loc = pt d[0],d[1]
        d3.select @
          .attr cx: loc.x, cy: loc.y

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
    @editor = new Editor d,@

  resetView: =>
    console.log "Resetting view"
    @features.attr d: @path

module.exports = DataLayer


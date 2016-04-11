chroma = require 'chroma-js'
d3 = require 'd3'

DataLayerBase = require "gis-core/frontend/helpers/data-layer"
Polygon = require '../../controls/polygon-editor/polygon'

q = "SELECT id,ST_AsGeoJSON(geometry) geom FROM dataset_feature WHERE type=$1"

selected = null
dragged = null
draggingIndex = null

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

    @coords = d.coordinates
    if d.type == 'Polygon'
      # Outer ring only
      @coords = @coords[0]

    @setupSelection()

    @_map.on 'mousemove', (e)=>
      return unless dragged
      pt = e.latlng
      dragged[0] = pt.lng
      dragged[1] = pt.lat
      @setupGhosts()
      @resetView()

    @resetView()
    @_map.on "zoomend", @resetView

  setupSelection: =>

    @nodes = @el.selectAll 'circle.node'
      .data @coords

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
    @setupGhosts()

    @ghosts.enter()
      .append 'circle'
      .attr
        class: 'ghost'
        r: 3
        'stroke-width': 2
        fill: 'white'
        cursor: 'pointer'
        stroke: @color
      .on 'click', (d,i)=>
        console.log d
        @coords.splice i+1,0,d
        @setupSelection()
        @resetView()

  resetView: =>
    console.log "Resetting view"
    @feature.attr d: @path

    pt = @layer.projectPoint
    @el.selectAll 'circle'
      .each (d)->
        loc = pt d[0],d[1]
        d3.select @
          .attr cx: loc.x, cy: loc.y

    nodes = @nodes[0]
    @ghosts.each (d,i)->
      el = d3.select @
      adjacentNode = d3.select nodes[i]
      dX = el.attr('cx') - adjacentNode.attr('cx')
      dY = el.attr('cy') - adjacentNode.attr('cy')
      dist = Math.sqrt Math.pow(dX,2)+Math.pow(dY,2)
      el.attr display: if dist < 10 then 'none' else 'inherit'

  setupGhosts: =>
    maxIx = @coords.length-1
    @intermediatePoints = @coords
      .filter (d,i)->i != maxIx
      .map (d,i)=>
        e = @coords[i+1]
        [(d[0]+e[0])/2,(d[1]+e[1])/2]
    @ghosts = @el.selectAll 'circle.ghost'
      .data @intermediatePoints

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


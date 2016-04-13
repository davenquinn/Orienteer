chroma = require 'chroma-js'
d3 = require 'd3'

selected = null
dragged = null
draggingIndex = null

class Editor
  color: 'red'
  defaultState:
    coordinates: []
    type: null
    closed: false
    valid: false
    finished: false
    targetType: 'Polygon'
  constructor: (d, @layer)->
    @events = d3.dispatch [
      'updated'
      'finished'
    ]
    if not d?
      d = @defaultState
    else
      d.finished = true
    if d.geometry?
      d = d.geometry
    d.valid = d.valid or true
    d.closed = d.closed or false
    @state = d

    @el = @layer.editContainer.append 'g'
    @_map = @layer._map
    @path = @layer.path

    @feature = @el
      .append 'path'
      .attr
        stroke: @color
        fill: chroma(@color).alpha(0.2).css()

    @coords = @state.coordinates
    if d.type == 'Polygon'
      # Outer ring only
      @coords = @coords[0]

    i = @coords.length-1
    @state.closed = @coords[0] == @coords[i]
    @state.closed = null if i < 2

    @_map.on 'click', (e)=>
      if not @state.closed
        pt = e.latlng
        @coords.push [pt.lng,pt.lat]
        @setupSelection()
        @resetView()

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

  setType: ->
    l = @coords.length
    if l == 0
      t = null
    else if l == 1
      t = 'Point'
    else if @state.closed
      t = 'Polygon'
    else
      t = 'LineString'
    @state.type = t

  setupSelection: =>
    @setType()
    if @state.type == 'Polygon'
      c = [@coords]
    else if @state.type == 'Point'
      c = @coords[0]
    else
      c = @coords

    @feature
      .datum type: @state.type, coordinates: c

    @nodes = @el.selectAll 'circle.node'
      .data @coords

    @nodes.enter()
      .append 'circle'
      .attr
        class: 'node'
        r: 5
        fill: @color

    if @state.finished
      @setupEditing()
    else
      @nodes.on 'click', null
      @nodes.filter (d,i)->i == 0
        .on 'click', (d,i)=>
          @coords.push @coords[0]
          @state.closed = true
          @doneAddingPoints()

      l = @coords.length-1
      @nodes.filter (d,i)->i == l
        .on 'click', @doneAddingPoints

  doneAddingPoints: =>
    console.log "Finished"
    @state.finished = true
    @setupSelection()
    @resetView()

  setupEditing: =>
    @setupGhosts()
    @nodes
      .on 'mousedown', (d)=>
        selected = dragged = d
        @_map.dragging.disable()
        @resetView()
      .on 'mouseup', (d)=>
        dragged = null
        @_map.dragging.enable()

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
    @feature.attr d: @path

    pt = @layer.projectPoint
    @el.selectAll 'circle'
      .each (d)->
        loc = pt d[0],d[1]
        d3.select @
          .attr cx: loc.x, cy: loc.y

    return unless @ghosts?
    # Don't show intermediate nodes that are close together.
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

module.exports = Editor

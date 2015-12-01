Spine = require "spine"
d3 = require "d3"
$ = require "jquery"
template = require "./template.html"
rewind = require 'geojson-rewind'

Data = require "../../app/data"

sf = d3.format " >8.1f"

createErrorSurface = (d)->
  # Function that turns orientation
  # objects into error surface
  e = d.properties.error_coords
  coords = [e.upper, e.lower]
  data =
    type: 'Feature'
    id: d.id
    geometry:
      type: 'Polygon'
      coordinates: coords
  return rewind(data)

createNominalPlane = (d)->
  e = d.properties.error_coords
  data =
    type: 'Feature'
    id: d.id
    geometry:
      type: 'LineString'
      coordinates: e.nominal
  return data

dfunc = (color)->
  (d)->
    el = d3.select @
    el.append "path"
      .datum createErrorSurface(d)
      .attr
        class: 'error'
        fill: color
        'fill-opacity':0.5

    el.append "path"
      .datum createNominalPlane(d)
      .attr
        class: 'nominal'
        fill: 'none'
        stroke: color

projections =
  wulff: d3.geo.azimuthalEqualArea
  schmidt: d3.geo.azimuthalEquidistant

class StereonetView extends Spine.Controller
  constructor: ->
    # Can specify both data and selection if you don't want
    # them to go to the default values.
    super
    @setupView()
    @data = window.app.data
    throw "No data" unless @data?
    @addData(@data) if @data?

  addData: (@data)=>
    @selection = @data.selection unless @selection?
    @listenTo @selection, "selection:updated", @update
    @listenTo Data, "filtered updated", @update
    @listenTo Data, "hovered", @onHover
    @update()

  setupView: =>
    @width = 300
    @height = @width
    @center = [@width/2, @height/2]

    @setupProjection()

    @drag = d3.behavior.drag()
      .origin =>
        r = @projection.rotate()
        {x: r[0], y: -r[1]}
      .on 'drag', =>
        @projection.rotate [d3.event.x, -d3.event.y]
        @svg.selectAll('path').attr d: @path
      .on 'dragstart', (d) ->
        d3.event.sourceEvent.stopPropagation()
        d3.select @
          .classed 'dragging', true
      .on 'dragend', (d) ->
        d3.select @
          .classed 'dragging', false

    graticule = d3.geo.graticule()

    @svg = d3.select @el[0]
      .append "svg"
        .attr
          viewBox: "0,0,#{@width},#{@height}"
          width: @width
          height: @height
        .call @drag

    @svg.append "path"
      .datum graticule
      .attr class:"graticule", d:@path

    defs = @svg.append "defs"
    defs.append "path"
      .datum {type: "Sphere"}
      .attr
        id:"sphere",
        d:@path

    defs.append "svg:clipPath"
      .attr id: "clip"
      .append 'use'
        .attr 'xlink:href': '#sphere'

    @frame = @svg.append 'g'
      .attr
        class: 'dataFrame'
        'clip-path': 'url(#clip)'

    @dframe = @frame.append 'g'
    @hovered = @frame.append 'g'
      .attr class: 'hovered'

    @svg.append 'use'
      .attr
        'xlink:href': '#sphere'
        fill: 'none'
        stroke: 'black'
        'stroke-width': 2

    # Create horizontal
    data =
      type: 'Feature'
      geometry:
        type: 'LineString'
        coordinates: [[90,0],[0,90],[-90,0],[0,-90],[90,0]]

    @frame.append 'path'
      .datum data
      .attr
        class: 'horizontal'
        stroke: 'black'
        'stroke-width': 2
        'stroke-dasharray': '2 4'
        fill: 'none'

    @draw()

  setupProjection: (type='wulff')=>
    @projectionType = type
    @projection = projections[type]()
      .clipAngle 90-1e-3
      .scale 150/500*@width
      .translate @center
      .precision .1

    @path = d3.geo.path()
      .projection @projection

  update: =>
    ds = @selection.visible()
    console.log ds

    @items = @dframe.selectAll 'g'
      .data ds, (d)->d.id

    @items.enter()
      .append "g"
        .on "mouseover mouseout", @data.hovered
        .each dfunc('red')
    @items.exit().remove()

    @draw()

  onHover: (d)=>
    console.log d
    if not d? then return
    data = if d.hovered then [d] else []
    sel = @hovered.selectAll "g"
      .data data, (d)->d.id
    sel.enter()
      .append "g"
        .each dfunc('purple')
        .classed "hovered", true
    @hovered.selectAll 'path'
      .attr d: @path

    sel.exit().remove()

  draw: =>
    @frame.selectAll 'path'
      .attr d: @path

module.exports = StereonetView

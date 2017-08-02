d3 = require "d3"
require 'd3-selection-multi'
L = require "leaflet"
Spine = require "spine"
setupMarkers = require "./markers"
marker = require './strike-dip'

class DataLayerBase extends L.SVG
  constructor: ->
    super
    # Specify a particular d3
    # object to enable event propagation
    # if submodules are defined.
    @initialize padding: 0.1

  setupProjection: =>
    f = @projectPoint
    @projection = d3.geo.transform
      point: (x,y)->
        point = f(x,y)
        return @stream.point point.x, point.y

    @path = d3.geo.path().projection(@projection)

  projectPoint: (x,y)=>
    @_map.latLngToLayerPoint(new L.LatLng(y,x))

  onAdd: =>
    super
    @setupProjection()
    @svg = d3.select @_container
      .classed "data-layer", true
      .classed "leaflet-zoom-hide", true
    @_map.on "viewreset", @resetView

  resetView: ->

{getIndexById} = require '../../../data/util'

mainCollection = ->
  Data.records.filter (d)->not d.group?

# mockup for future option
showGroups = true

class EventedShim extends DataLayerBase
  @include Spine.Events

class DataLayer extends EventedShim
  constructor: ->
    super()
  onAdd: ->
    super()

    @setupProjection()
    @svg = d3.select @_container
      .classed "data-layer", true
      .classed "leaflet-zoom-hide", true
    @_map.on "viewreset", @resetView

    @container = @svg.append("g")

    setupMarkers(@container)

    console.log "Setting up data layer"
    mdip = 5
    @cscale = d3.scaleLinear()
        .domain [0, mdip]
        .range ["white","red"]

    @container.append "g"
      .attrs class: "features"
    @container.append "g"
      .attr 'class', "markers"

    @_map.on "zoomend",@onZoom

  onHoverIn: (hovered)=>
    # We dont' care about hover-leave, where
    # data isn't defined.
    return unless hovered?
    fn = (d)-> d.id == hovered

    @container.select ".features"
      .selectAll "path"
      .classed "hovered", fn

    @container.select ".markers"
      .selectAll "g"
      .classed "hovered", fn

  updateData: (records)=>
    # Features will stay constant unless
    # added to by creation of a new measurement
    data = records
      .filter (d)->not d.in_group

    @features = @container.select ".features"
      .selectAll "path"
      .data data, (d)->d.id

    # The number of markers will fluctuate
    # depending on which measurements are
    # grouped, and (notably) whether groups
    # are shown in the GUI or not
    @markers = @container.select ".markers"
      .selectAll "g"
      .data data, (d)->d.id

    clicked = (d)=>
      #if showGroups
        #d = d.group if d.group?
      app.data.selection.update d
    hovered = (d)=>
      #if showGroups
        #d = d.group if d.group?
      app.data.hovered d

    applyEvents = (sel)->
      sel
        .on "mousedown", clicked
        .on "mouseover", hovered
        .on "mouseout", hovered

    @features.enter()
      .append "path"
        .attrs
          class: (d)->d.geometry.type
          d: @path
        .call applyEvents

    @markers.enter()
      .append "g"
        .attr "class", "marker"
        .each marker
        .call applyEvents
        .call @setTransform

    @features.exit().remove()
    @markers.exit().remove()

  onZoom: =>
    # There is a weird bug with zooming in which zoom doesn't work
    # before cached data is replaced from database
    z = @_map.getZoom()
    console.log "Resizing markers for zoom",z

    @container.select ".markers"
      .selectAll "g"
      .call @setTransform

    @container.select ".features"
      .selectAll "path"
      .attrs d: @path

  setupProjection: =>
    f = @projectPoint
    @projection = d3.geoTransform
      point: (x,y)->
        point = f(x,y)
        return @stream.point point.x, point.y

    @path = d3.geoPath().projection(@projection)

  projectPoint: (x,y)=>
    @_map.latLngToLayerPoint(new L.LatLng(y,x))

  setTransform: (sel)=>
    z = @_map.getZoom()
    proj = @projectPoint
    sel.attrs transform: (d)->
      s = d.strike
      c = d.center.coordinates
      c = proj(c[0],c[1])
      "translate(#{c.x} #{c.y}) rotate(#{s} 0 0) scale(#{1+0.2*z})"
    z =
    sel.select "text"
      .attrs
        dy: z/2
        "font-size": z
  resetView: =>
    @markers.call @setTransform
    @features.attr 'd', @path

  updateSelection: (sel)=>
    isInSelection = (d)->
      ix = getIndexById sel, d
      ix != -1

    console.log "Updating selection on map"
    @container.select ".features"
      .selectAll "path"
      .classed "selected", (d)=>
        if showGroups and d.in_group
          # Transfer selection to group
          d = app.data.get d.member_of
        isInSelection(d)

    @container.select ".markers"
      .selectAll "g"
      .classed "selected", isInSelection

module.exports = DataLayer

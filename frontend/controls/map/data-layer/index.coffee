d3 = require "d3"
require 'd3-selection-multi'
L = require "leaflet"
Spine = require "spine"
setupMarkers = require "./markers"
marker = require './strike-dip'

Feature = require "../../../app/data/feature"
Data = require "../../../app/data"
GroupedFeature = require "../../../app/data/group"
DataLayerBase = require "gis-core/frontend/helpers/data-layer"

mainCollection = ->
  Data.records.filter (d)->not d.group?

# mockup for future option
showGroups = true

class EventedShim extends DataLayerBase
  @include Spine.Events

class DataLayer extends EventedShim
  constructor: ->
    super
  onAdd: ->
    super
    # Shim for mismatched versions of D3
    @svg = d3.select(@svg.node())
    @container = @svg.append("g")

    setupMarkers(@container)

    if @data?
      @setupData @data

  setupData: (@data)->
    mdip = 5
    @cscale = d3.scaleLinear()
        .domain [0, mdip]
        .range ["white","red"]

    @listenTo @data.constructor, "updated", @updateData
    @listenTo @data.constructor, "filtered", @updateData
    @listenTo @data.constructor, "hovered", (data)=>
      # We dont' care about hover-leave, where
      # data isn't defined.
      return unless data?
      @features.classed "hovered", (d)-> d.hovered
      @markers.classed "hovered", (d)-> d.hovered

    @listenTo @data.selection, "selection:updated", @updateSelection
    @_map.on "zoomend", =>
      # There is a weird bug with zooming in which zoom doesn't work
      # before cached data is replaced from database
      z = @_map.getZoom()
      console.log "Resizing markers for zoom",z
      @markers.call @setTransform
      @features.attrs d: @path

    @container.append "g"
      .attrs class: "features"

    @markers = @container.append "g"
      .attr 'class', "markers"
      .selectAll "g"

    @updateData()

  updateData: (filter)=>
    filter = @data.getFilter() unless filter?

    # Features will stay constant unless
    # added to by creation of a new measurement
    data = @data.constructor.records
      .filter (d)->d.type == 'Feature'
      .filter(filter)
    @features = @container.select ".features"
      .selectAll "path"
      .data data, (d)->d.id

    mdata = @data.constructor.records
      .filter (d)->not d.group?
      .filter(filter)
    # The number of markers will fluctuate
    # depending on which measurements are
    # grouped, and (notably) whether groups
    # are shown in the GUI or not
    @markers = @container.select ".markers"
      .selectAll "g"
      .data mdata, (d)->d.id

    clicked = (d)=>
      if showGroups
        d = d.group if d.group?
      @data.selection.update d
    hovered = (d)=>
      if showGroups
        d = d.group if d.group?
      @data.hovered d

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

  setTransform: (sel)=>
    z = @_map.getZoom()
    proj = @projectPoint
    sel.attrs transform: (d)->
      s = d.properties.strike
      c = d.properties.center.coordinates
      c = proj(c[0],c[1])
      "translate(#{c.x} #{c.y}) rotate(#{s} 0 0) scale(#{1+0.2*z})"
    z = 5+0.2*z
    sel.select "text"
      .attrs
        dy: z/2
        "font-size": z
  resetView: =>
    bounds = @path.bounds
      type: "FeatureCollection"
      features: Feature.collection

    @markers.call @setTransform
    @features.attr 'd', @path

  updateSelection: (sel)=>
    sel = @data.selection.records unless sel
    console.log "Updating selection on map"

    @features.classed "selected", (d)=>
      if showGroups
        # Transfer selection to group
        d = d.group if d.group?
      sel.indexOf(d) != -1

    @markers.classed "selected", (d)=>
      sel.indexOf(d) != -1

module.exports = DataLayer

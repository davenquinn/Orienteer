d3 = require "d3"
L = require "leaflet"
Spine = require "spine"
setupMarkers = require "./markers"
marker = require './strike-dip'

Feature = require "../../../app/data/feature"
GroupedFeature = require "../../../app/data/group"
DataLayerBase = require "gis-core/frontend/helpers/data-layer"

mainCollection = ->
  Feature.collection
    .filter (d)->not d.group?
    .concat GroupedFeature.collection

#f = d3.format(".0f")

# mockup for future option
showGroups = true

class EventedShim extends DataLayerBase
  @include Spine.Events

class DataLayer extends EventedShim
  constructor: ->
    super
  onAdd: ->
    super
    @setupMarkers()
    @container = @svg.append("g")

    if @data?
      @setupData @data

  setupData: (@data)->
    mdip = 5
    @cscale = d3.scale.linear()
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
      z = @_map.getZoom()
      console.log "Resizing markers for zoom",z
      @markers.call @setTransform
      @features.attr d: @path

    @container.append "g"
      .attr class: "features"

    @markers = @container.append "g"
      .attr class: "markers"
      .selectAll "g"

    @updateData()

  updateData: (filter)=>
    filter = @data.getFilter() unless filter?

    # Features will stay constant unless
    # added to by creation of a new measurement
    @features = @container.select ".features"
      .selectAll "path"
      .data Feature.collection.filter(filter), (d)->d.id

    # The number of markers will fluctuate
    # depending on which measurements are
    # grouped, and (notably) whether groups
    # are shown in the GUI or not
    @markers = @container.select ".markers"
      .selectAll "g"
      .data mainCollection().filter(filter), (d)->d.id

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
        .attr
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

  setupMarkers: -> setupMarkers(@svg)

  setTransform: (sel)=>
    z = @_map.getZoom()
    proj = @projectPoint
    sel.attr transform: (d)->
      s = d.properties.strike
      c = d.properties.center.coordinates
      c = proj(c[0],c[1])
      "translate(#{c.x} #{c.y}) rotate(#{s} 0 0) scale(#{1+0.2*z})"
    z = 5+0.2*z
    sel.select "text"
      .attr
        dy: z/2
        "font-size": z
  resetView: =>
    bounds = @path.bounds
      type: "FeatureCollection"
      features: Feature.collection

    @markers.call @setTransform
    @features.attr d: @path

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

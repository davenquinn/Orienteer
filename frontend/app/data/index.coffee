Spine = require "spine"
tags = require "../../shared/data/tags"
d3 = require "d3"
queue = require("d3-queue").queue
Feature = require "./feature"
GroupedFeature = require "./group"
Selection = require "./selection"
L = require 'leaflet'
{update} = require 'immutability-helper'

{storedProcedure} = require '../database'
API = require "../api"

class Data extends Spine.Module
  @extend Spine.Events

  hoveredItem: null
  _filter: (d)->d
  fetched: false
  constructor: ->
    super
    # Shim for deletion of collection attributes
    GroupedFeature.collection = @records
    Feature.collection = @records

    # Setup requests for updated data
    @__fetchData()

    @selection = Selection
    @selection.bind "tags-updated", @filter
    Data.listenTo GroupedFeature, "deleted", (d)=>
      @onUpdated()
      i = @selection.records.indexOf(d)
      return if i == -1
      console.log "Removing group from selection"
      @selection.records.splice i,1
      @selection.addSeveral d.records
    Data.listenTo GroupedFeature, "created", (d)=>
      @onUpdated()
      @selection.fromRecords [d]

    Data.listenTo GroupedFeature, "updated", @onUpdated

  __fetchData: =>
    {storedProcedure, db} = app.require 'database'

    # Grab data directly from postgresql dataset
    # We used to use a Python API here but this
    # is a factor of at least 100 quicker
    sql = storedProcedure 'get-dataset'
    db.query sql
      .map (d)->
        # Transform raw data
        new Feature d
      .tap console.log
      .then (records)=>
        @records = records
        @fetched = true
        @constructor.trigger 'updated'
      .catch (e)->
        throw e

  onUpdated: =>
    @constructor.trigger "updated"

  updateCache: (d)->
    console.log "Updating cache"
    _ = JSON.stringify d
    window.localStorage.setItem "attitudes", _

  get: (id)=>
    @records.find (d)->d.id==id

  asGeoJSON: ->
    out =
      type: "FeatureCollection"
      features: @records

  getTags: ->
    tags.getUnique @records

  within: (bounds)=>
    console.log bounds
    @records.filter (d)->
      a = d.properties.center.coordinates
      l = new L.LatLng a[1],a[0]
      bounds.contains l

  reset: ->
    @records = []

  hovered: (d, v)=>
    # set hover state
    if not v?
      v = not d.hovered
    d.hovered = v
    if d.records?
      for i in d.records
        i.hovered = d.hovered
    if d.hovered
      @hoveredItem = d.id
      @constructor.trigger "hovered", d
    else
      @hoveredItem = null
      @constructor.trigger "hovered"

  isHovered: (d)->
    # Checks if item is hovered
    @hoveredItem == d.id

  getFilter: (tags)=>
    tags = [{name: "bad",status: "none"}] unless tags
    tagged = (d, t)->
      d.tags.indexOf(t.name) != -1
    enabled = tags.filter (t)-> t.status == "all"
    disabled = tags.filter (t)-> t.status == "none"

    return (d)->
      # Transfer selection to group
      d = d.group if d.group?
      # filter tags
      if enabled.length > 0
        rfunc = (a,t)-> a + tagged d,t
        f = enabled.reduce rfunc, 0
        return f != 0
      if disabled.length > 0
        for t in disabled
          if tagged d,t
            return false
      return true

  updateFilter: (tags)=>
    func = @getFilter tags
    @filter = func
    @constructor.trigger "filtered", func

  filter: =>
    @constructor.trigger "filtered", @getFilter()

  selectByBox: (bounds)=>
    f = @data.within(bounds)
    f.filter (d)->not d.hidden
    @selection.addSeveral f

module.exports = Data

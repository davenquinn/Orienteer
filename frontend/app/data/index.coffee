Spine = require "spine"
tags = require "../../shared/data/tags"
d3 = require "d3"
queue = require("d3-queue").queue
Feature = require "./feature"
GroupedFeature = require "./group"
Selection = require "./selection"
L = require 'leaflet'
{update} = require 'immutability-helper'

API = require "../api"

class Data extends Spine.Module
  @extend Spine.Events

  # Methods for dealing with collections
  # as a whole

  @records: []
  @index: []

  @reset: ->
    @records = []
    @index = []

  hoveredItem: null
  _filter: (d)->d
  fetched: false
  constructor: ->
    super
    # Shim for deletion of collection attributes
    GroupedFeature.collection = @constructor.records
    Feature.collection = @constructor.records

    # Setup requests for updated data
    @fetch()

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

  fetch: =>
    queue()
      .defer API("/attitude").get
      .await (e,d1)=>
        if e
          throw e
        console.log d1
        console.log "Data received from server"
        @setupData d1.data
        @fetched = true

  onUpdated: =>
    @constructor.trigger "updated"

  setupData: (rawData)->
    # Empties collections
    @constructor.reset()
    for d in rawData
      if d.type == 'GroupedAttitude'
        f = new GroupedFeature d
      else
        f = new Feature d
      @constructor.records.push f
    @constructor.trigger "updated"

  updateCache: (d)->
    console.log "Updating cache"
    _ = JSON.stringify d
    window.localStorage.setItem "attitudes", _

  get: (id)=>
    @constructor.records.find (d)->d.id==id

  asGeoJSON: ->
    out =
      type: "FeatureCollection"
      features: @constructor.records

  getTags: ->
    tags.getUnique @constructor.records

  within: (bounds)=>
    console.log bounds
    @constructor.records.filter (d)->
      a = d.properties.center.coordinates
      l = new L.LatLng a[1],a[0]
      bounds.contains l

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
module.exports = Data

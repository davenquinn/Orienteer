Spine = require "spine"
tags = require "../../shared/data/tags"
d3 = require "d3"
Feature = require "./feature"
GroupedFeature = require "./group"
Selection = require "./selection"
queue = require "queue-async"

API = require "../api"

class Data extends Spine.Module
  @extend Spine.Events

  _filter: (d)->d
  fetched: false
  constructor: ->
    super
    # Add data from cache if available
    cachedData = window.localStorage.getItem "attitudes"
    features = JSON.parse cachedData
    if features?
      @setupData features

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
      .defer API("/group").get
      .await (e,d1,d2)=>
        console.log "Data received from server"
        features = d1.response.data
          .concat d2.response.data
        @setupData features
        @fetched = true
        @updateCache features

  onUpdated: =>
    rec = @records()
    @constructor.trigger "updated"

  setupData: (rawData)->
    # Empties collections
    Feature.reset()
    GroupedFeature.reset()
    for d in rawData
      if d.measurements?
        if d.measurements.length > 1
          new GroupedFeature d
      else
        new Feature d
    @constructor.trigger "updated"

  updateCache: (d)->
    console.log "Updating cache"
    _ = JSON.stringify d
    window.localStorage.setItem "attitudes", _

  get: (id)=>
    if typeof id is "string"
      return GroupedFeature.index[id]
    else
      return Feature.index[id]

  records: ->
    Feature.collection
      .concat GroupedFeature.collection

  asGeoJSON: ->
    out =
      type: "FeatureCollection"
      features: @records()

  getTags: ->
    tags.getUnique @records()

  within: (bounds)->
    @records().filter (d)->
      a = d.properties.center.coordinates
      l = new L.LatLng a[1],a[0]
      bounds.contains l

  hovered: (d)=>
    # set hover state
    d.hovered = not d.hovered
    if d.records?
      for i in d.records
        i.hovered = d.hovered
    if d.hovered
      @constructor.trigger "hovered", d
    else
      @constructor.trigger "hovered"

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

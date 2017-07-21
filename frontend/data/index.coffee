Spine = require "spine"
tags = require "../shared/data/tags"
d3 = require "d3"
queue = require("d3-queue").queue
GroupedFeature = require "./group"
Selection = require "./selection"
Promise = require 'bluebird'
L = require 'leaflet'
_ = require 'underscore'
update = require 'immutability-helper'
{storedProcedure, db} = require '../database'

API = require "../api"

prepareData = (d)->
  # Transform raw data
  d = _.clone d
  d.grouped = d.type == 'group'
  d.type = 'Feature'
  d.tags ?= []
  return d

class Data extends Spine.Module
  @extend Spine.Events

  hoveredItem: null
  _filter: (d)->d
  fetched: false
  constructor: ->
    super()
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

    @featureTypes = []
    sql = storedProcedure 'get-types'
    db.query sql
      .tap console.log
      .then (records)=>
        @featureTypes = records
        @constructor.trigger 'feature-types', records

    # Grab data directly from postgresql dataset
    # We used to use a Python API here but this
    # is a factor of at least 100 quicker
    sql = storedProcedure 'get-dataset'
    db.query sql
      .map prepareData
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

  get: (ids...)=>
    if ids.length == 1
      rec = @records.find (d)->d.id==ids[0]
    else
      rec = @records.filter (d)->
        ids.indexOf(d.id)!=-1
    rec

  asGeoJSON: ->
    out =
      type: "FeatureCollection"
      features: @records

  getTags: ->
    tags.getUnique @records

  reset: ->
    @records = []

  hovered: (d)=>

    # Unset current hovered item
    ix = @records.findIndex (a)->a.hovered
    dix = @records.findIndex (a)->d.id == a.id
    console.log ix, dix

    u = {}
    if dix != ix and ix >= 0
      u["#{ix}"] = {hovered: {'$set':false}}

    v = not d.hovered
    if v
      u["#{dix}"] = {hovered: {'$set':v}}

    @records = update(@records,u)

    d = @records[dix]
    if d.hovered
      @hoveredItem = d.id
    else
      @hoveredItem = null
    @constructor.trigger "hovered", @hoveredItem

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

  within: (bounds)=>
    @records.filter (d)->
      a = d.center.coordinates
      l = new L.LatLng a[1],a[0]
      bounds.contains l

  selectByBox: (bounds)=>
    f = @within(bounds)
    @selection.add f...

  getRecordIndex: (id)=>
    # Get index of a certain primary key
    @records.findIndex (rec)->id == rec.id

  updateUsing: (changeset)=>
    @records = update(@records, changeset)
    @constructor.trigger "updated",@records
    @selection.refresh(@records)

  addTag: (tag, records)=>
    sql = storedProcedure "add-tag"
    ids = records.map (d)->d.id
    records = await db.query sql, [tag, ids]

    changeset = {}
    for rec in records
      console.log rec
      ix = @getRecordIndex rec.attitude_id
      changeset[ix] = {tags: {"$push": [rec.tag_name]}}

    @updateUsing changeset

  removeTag: (tag, records)=>
    sql = storedProcedure "remove-tag"
    ids = records.map (d)->d.id
    records = await db.query sql, [tag, ids]

    changeset = {}
    for rec in records
      console.log rec
      ix = @getRecordIndex rec.attitude_id
      tagindex = @records[ix].tags.indexOf(tag)
      continue if tagindex == -1
      changeset[ix] = {tags: {"$splice": [[tagindex,1]]}}

    @updateUsing changeset

  # Change data class
  changeClass: (type, records)=>
    {storedProcedure, db} = require '../database'
    sql = storedProcedure "update-types"
    ids = records.map (d)->d.id
    console.log "Changing class to #{type} for #{ids}"
    results = await db.query sql, [type,ids]
    console.log results

    for i in ids
      # Groups should have IDs set as well
      if i.records?
        ids.push.apply i.records.map((a)->a.id)

    changeset = {}
    for id in ids
      ix = @records.findIndex (a)->id == a.id
      changeset[ix]={class:{"$set":type}}

    @updateUsing changeset

  updateSelectionFromIDs: (ids)->
    records = @records.filter (d)->
      ids.indexOf(d.id) != -1
    @selection.fromRecords records

  destroyGroup: (id)->
    call = Promise.promisify app.API("/group/#{id}").send
    console.log "Destroying group #{id}"
    response = await call("DELETE")
    if response.status != 200
      console.log "Could not destroy group #{id}"
      return

    ix = @records.findIndex (d)->id == d.id
    changeset = {$splice: [[ix,1]]}
    @updateUsing changeset

  createGroup: (records)=>
    call = Promise.promisify app.API("/group").send
    data =
      measurements: records.map (d)->d.id
      same_plane: false

    console.log "Creating group"
    response = await call "POST", JSON.stringify(data)
    obj = response.data
    ids = obj.measurements.concat [obj.id]
    console.log "Successfully created group #{obj.id}"

    @refreshRecords ids
    @updateSelectionFromIDs [obj.id]

  refreshRecords: (ids)=>
    sql = storedProcedure 'get-records-by-ids'
    console.log "Refreshing records", ids
    records = await db.query(sql, [ids]).map prepareData
    changeset = {}
    for rec in records
      ix = @records.findIndex (a)->rec.id == a.id
      changeset[ix]={"$set": rec}
    @updateUsing changeset

module.exports = Data

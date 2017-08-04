tags = require "./shared/data/tags"
Promise = require 'bluebird'
{LatLng} = require 'leaflet'
_ = require 'underscore'
update = require 'immutability-helper'
{readFileSync} = require 'fs'
{storedProcedure, db} = require './database'

API = require "./api"

prepareData = (d)->
  # Transform raw data
  d = _.clone d
  d.grouped = d.type == 'group'
  d.selected = false
  d.hovered = false
  d.type = 'Feature'
  d.tags ?= []
  return d

class Data

  hoveredItem: null
  _filter: (d)->d
  fetched: false
  records: []
  constructor: (opts={})->
    @log = opts.logger or console
    @onUpdated = opts.onUpdated

    # Setup requests for updated data
    @fetchInitialData()

    #@selection = Selection
    #@selection.bind "tags-updated", @filter
    #
    Object.defineProperty @, 'selection',
      get: -> @records.filter (d)->d.selected

  fetchInitialData: ->
    @featureTypes = []
    sql = storedProcedure 'get-types'
    db.query sql
      .then (records)=>
        @featureTypes = records
        @onUpdated featureTypes: records

  getData: (subquery)->
    # Grab data directly from postgresql dataset
    # We used to use a Python API here but this
    # is a factor of at least 100 quicker
    # Transfer selection
    selectedIDs = @records
      .filter (d)->d.selected
      .map (d)->d.id

    sql = readFileSync "#{__dirname}/sql/get-dataset.sql", 'utf8'
    if subquery?
      v = sql.replace("attitude_data", "subquery")
      sql = "WITH subquery AS (#{subquery}) #{v}"

    console.log sql
    db.query sql
      .map prepareData
      .then (records)=>
        console.log "Getting records"

        # Transfer selection
        for record in records
          if selectedIDs.indexOf(record.id) != -1
            record.selected = true

        changeset = {$set: records}
        @updateUsing changeset
        @log.success "Loaded #{records.length} features"
      .catch (e)->
        throw e

  get: (ids...)->
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

  hovered: (d)->
    hoveredItem = @records.find (rec)->rec.hovered
    return if d == hoveredItem

    changeset = {}
    if hoveredItem?
      ix = @getRecordIndex hoveredItem.id
      changeset[ix] = {hovered: {$set: false}}
    if d?
      ix = @getRecordIndex d.id
      changeset[ix] = {hovered: {$set: true}}
    @updateUsing changeset

  within: (bounds)->
    @records.filter (d)->
      a = d.center.coordinates
      l = new LatLng a[1],a[0]
      bounds.contains l

  selectByBox: (bounds)->
    f = @within(bounds).filter (d)->not d.in_group
    @addToSelection f...

  addToSelection: (records...)->
    changeset = {}
    for record in records
      ix = @getRecordIndex record.id
      changeset[ix] = {selected: {$set: true}}
    @updateUsing changeset

  removeFromSelection: (records...)->
    changeset = {}
    for record in records
      ix = @getRecordIndex record.id
      changeset[ix] = {selected: {$set: false}}
    @updateUsing changeset

  updateSelection: (record)->
    # Add or remove record from selection depending on membership
    ix = @getRecordIndex record.id
    changeset = {}
    changeset[ix] = {selected: {"$set": not record.selected}}
    @updateUsing changeset

  clearSelection: =>
    rec = @records.filter (d)->d.selected
    @removeFromSelection rec...

  createGroupFromSelection: ->

  getRecordIndex: (id)->
    # Get index of a certain primary key
    @records.findIndex (rec)->id == rec.id

  getRecordById: (id)->
    @records.find (rec)-> id == rec.id

  updateUsing: (changeset)->
    console.log "Updating using", changeset
    @records = update(@records, changeset).filter (d)->d?
    @onUpdated records: @records

  addTag: (tag, records)->
    sql = storedProcedure "add-tag"
    ids = records.map (d)->d.id
    records = await db.query sql, [tag, ids]

    changeset = {}
    for rec in records
      console.log rec
      ix = @getRecordIndex rec.attitude_id
      changeset[ix] = {tags: {"$push": [rec.tag_name]}}

    @updateUsing changeset

  removeTag: (tag, records)->
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
  changeClass: (type, records)->
    sql = storedProcedure "update-types"
    ids = records.map (d)->d.id
    console.log "Changing class to #{type} for #{ids}"
    results = await db.query sql, [type,ids]

    for i in ids
      # Groups should have IDs set as well
      if i.records?
        ids.push.apply i.records.map((a)->a.id)

    changeset = {}
    for id in ids
      ix = @records.findIndex (a)->id == a.id
      changeset[ix]={class:{"$set":type}}

    @updateUsing changeset

  destroyGroup: (id)->
    call = Promise.promisify app.API("/group/#{id}").send
    console.log "Destroying group #{id}"
    response = await call("DELETE")

    # Currently, we know that all groups that are deleted were selected
    groupWasSelected = true

    if response.status != 'success'
      @log.error "Could not destroy group #{id}"
      return

    ix = @records.findIndex (d)->id == d.id
    changeset = {$splice: [[ix,1]]}
    @refreshRecords response.measurements, {changeset, selected: true}
    app.log.success "Destroyed group #{id}"

  createGroup: (records)->
    call = Promise.promisify app.API("/group").send
    data =
      measurements: records.map (d)->d.id
      same_plane: false

    console.log "Creating group"
    response = await call "POST", JSON.stringify(data)
    if response.status != 'success'
      @log.error "Could not create group"
      return
    obj = response.data
    ids = obj.measurements.concat [obj.id]
    @log.success "Successfully created group #{obj.id}"
    # Splice empty groups
    changeset = {}
    for record in records
      continue unless record.is_group
      ix = @getRecordIndex record.id
      changeset[ix] = {$set: null}
    @refreshRecords ids, {selected: true, changeset }

  refreshRecords: (ids, opts={})->
    # Options:
    #   selected: boolean (should set data to be selected)
    #   changeset: an input changeset to use
    changeset = opts.changeset or {}

    sql = storedProcedure 'get-records-by-ids'
    console.log "Refreshing records", ids
    records = await db.query(sql, [ids]).map prepareData
    for rec in records
      ix = @records.findIndex (a)->rec.id == a.id
      if opts.selected? and not rec.in_group
        rec.selected = opts.selected
      if ix == -1
        changeset['$push'] ?= []
        changeset['$push'].push rec
      changeset[ix]={"$set": rec}

    @updateUsing changeset

module.exports = Data

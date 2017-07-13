Spine = require "spine"
GroupedFeature = require "./group"
path = require 'path'
tags = require "../../shared/data/tags"
{storedProcedure, db} = require '../database'
update = require 'immutability-helper'
addTag = storedProcedure 'add-tag'
removeTag = storedProcedure 'remove-tag'

{getIndexById, _not} = require './util'

visible = (d)->not d.hidden

respectGroups = true

class BaseSelection extends Spine.Module
  @include Spine.Events
  constructor: ->
    super()
    @records = []

  getTags: =>
    records = @records
    arr = tags.get records
    func = (d, name)->
      d[name] = 0 unless name of d
      d[name] += 1
      return d
    data = arr.reduce func, {}
    arr = []
    for tag, num of data
      arr.push
        name: tag
        all: num >= records.length
    return arr

  empty: =>not @records.length

  __notify: =>
    @trigger "selection:updated", @records

  __index: (d)=>
    getIndexById @records, d

  __isMember: (d)=>
    ix = @__index d
    ix != -1

  refresh: (appRecords)->
    # A temporary method to propagate changes in main data
    # store
    ids = @records.map (d)->d.id
    newRecords = appRecords.filter (d)-> ids.indexOf(d.id) != -1
    @records = newRecords
    @__notify()

  add: (records...)=>
    u = {}
    newRecords = records.filter _not(@__isMember)
    @records = update(@records,'$push': newRecords)
    @__notify()

  remove: (records...)=>
    @records = @records.filter (d)->
      ix = getIndexById(records,d)
      # Get all records not in the
      # original set
      ix == -1
    @__notify()

  # Composite addition methods
  update: (d)=>
    # Either adds or removes depending on presence
    if @__isMember d
      @remove d
    else
      @add d

  fromRecords: (records)=>
    @records = records
    @__notify()

  contains: (d)=>
    @records.indexOf(d) >= 0

  clear: =>
    @records = []
    @__notify()

  _tagRemoved: (name, opts={})=>
    records = opts.records or @records
    records.forEach (d)->
      i = d.tags.indexOf name
      if i >= 0
        d.tags.splice(i,1)
    @trigger "tags-updated", @getTags()

  _tagAdded: (name, opts={})=>
    # Adds tag to each record and
    # signals application that it is done
    records = opts.records or @records
    records.forEach (d)->
      i = d.tags.indexOf name
      if i == -1
        d.tags.push name
    @trigger "tags-updated", @getTags()

class Selection extends BaseSelection
  _add: (d)=>
    if respectGroups and d.group?
      d = d.group
    super(d)

  update: (d)=>
    d = d.group if d.group?
    super(d)
  # `@visible` is a drop-in replacement for `@records`
  # that only returns the part of the selection that isn't
  # hidden at any given time. This may be swapped for something
  # else if it makes sense to do so.
  visible: => @records
  updateVisibility: =>
    @notify()

  _tagData: (name)=> {
      tag: name
      features: @records
        .filter visible
        .map (d)->d.id
    }

  createGroup: =>
    console.log "Creating group"
    return if @records.length < 2
    GroupedFeature.create @records

module.exports = new Selection

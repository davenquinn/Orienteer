Spine = require "spine"
tags = require "./tags"

class Selection extends Spine.Module
  @include Spine.Events
  constructor: ->
    super
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

  notify: =>
    @trigger "selection:updated", @records

  addSeveral: (records)=>
    for d in records
      @_add d
    @notify()

  fromRecords: (records)=>
    @records = records
    @notify()

  _add: (d)=>
    i = @records.indexOf(d)
    return unless i == -1
    @records.push d
    d.selected = true
  add: (d)=>
    @_add d
    @notify()

  _remove: (d)=>
    i = @records.indexOf(d)
    if i >= 0
      @records.splice i,1
    d.selected = false
  remove: (d)=>
    @_remove(d)
    @notify()

  update: (d)=>
    # Either adds or removes depending on presence
    i = @records.indexOf(d)
    if i == -1
      @records.push d
    else
      @records.splice i,1
    @notify()

  contains: (d)=>
    @records.indexOf(d) >= 0

  clear: =>
    @records = []
    @notify()

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

module.exports = Selection

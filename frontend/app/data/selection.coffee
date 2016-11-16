Spine = require "spine"
API = require "../api"
GroupedFeature = require "./group"
BaseSelection = require "../../shared/data/selection"
path = require 'path'

{storedProcedure} = require '../database'

addTag = storedProcedure 'add-tag'
removeTag = storedProcedure 'remove-tag'

visible = (d)->not d.hidden

respectGroups = true

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

  addTag: (name)=>
    data = @_tagData name
    addTag [data.tag, data.features], (e,r)=>
      throw e if e
      # We just assume that the right records are tagged
      @_tagAdded name

  removeTag: (name)=>
    data = @_tagData name
    removeTag [data.tag, data.features], (e,r)=>
      throw e if e
      @_tagRemoved name

  createGroup: =>
    console.log "Creating group"
    return if @records.length < 2
    GroupedFeature.create @records

module.exports = new Selection

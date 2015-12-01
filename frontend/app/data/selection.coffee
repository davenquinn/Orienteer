Spine = require "spine"
API = require "../api"
GroupedFeature = require "./group"
BaseSelection = require "../../shared/data/selection"

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

  _recordsToTag: =>
    @records.filter (d)->not d.hidden

  addTag: (name)=>
    data = @_tagData name
    app.API "/attitude/tag"
      .send "POST", JSON.stringify(data), (e,r) =>
        console.log r.response
        @_tagAdded name, records: @_recordsToTag()

  removeTag: (name)=>
    data = @_tagData name
    app.API "/attitude/tag"
      .send "DELETE", JSON.stringify(data), (e,r)=>
        console.log r.data
        @_tagRemoved name, records: @_recordsToTag()

  createGroup: =>
    console.log "Creating group"
    return if @records.length < 2
    GroupedFeature.create @records

module.exports = new Selection

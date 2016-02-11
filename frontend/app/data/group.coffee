d3 = require "d3"
Feature = require "./feature"
Spine = require "spine"

featureIDs = (records)->
  # Returns a list of features by exploding
  # grouped features into their component records
  features = []
  for d in records
      if d.records?
        ids = d.records.map (d)->d.id
        features = features.concat ids
      else
        features.push d.id
  return features

class GroupedFeature extends Spine.Module
  @extend Spine.Events
  @extend Feature

  @collection: []
  @index: {}
  @get: (id)=>
    if not isNaN(id)
      # We're working with gids
      id = "G#{id}"
    @index[id]

  @reset: ->
    # Empties collection in preparation
    # for updating data.
    @collection = []
    @index = {}

  @create: (records, callback)->
    data =
      measurements: featureIDs(records)
      same_plane: false
    app.API "/group"
      .send "POST", JSON.stringify(data), (e,r)=>
        feature = new GroupedFeature r.response.data
        GroupedFeature.trigger "created", feature
        @cleanupEmpty()

  @cleanupEmpty: ->
     GroupedFeature.collection
       .filter (d)-> d.records.length == 1
       .forEach (d)-> d.destroy()

  bind: GroupedFeature.bind
  trigger: GroupedFeature.trigger

  grouped: true
  hidden: false
  # This class implements an interface similar to the
  # "Selection" object.
  constructor: (obj)->
    super
    @gid = obj.id
    @id = "G#{@gid}"
    @updateRecords obj
    @updateAttributes obj
    @updateGeometry()

    @constructor.collection.push @
    @constructor.index[@id] = @

  updateRecords: (obj)=>
    @records = obj.measurements.map (d)->
      Feature.get d
    for f in @records
      f.setGroup @

  updateAttributes: (obj)=>
    @same_plane = obj.same_plane
    @tags = obj.tags
    p =
      strike: obj.strike
      dip: obj.dip
      r: obj.r
      p: obj.p
      axes: obj.axes
      singularValues: obj.singularValues
    @properties = {} unless @properties?
    for key, val of p
      @properties[key] = val

  updateGeometry: ->
    @properties.center =
        type: "Point"
        coordinates: [
          d3.mean @records, (d)->
            d.properties.center.coordinates[0]
          d3.mean @records, (d)->
            d.properties.center.coordinates[1]
          ]
    @geometry =
      type: "GeometryCollection"
      geometries: @records.map (d)->d.geometry

  removeFeature: (d)=>
    i = @records.indexOf d
    @records.splice i,1
    d.group = null
  visible: => @records # alias to support same methods as view

  requestDestruction: ->
    app.API "/group/#{@gid}"
      .send "DELETE", (e,r)=>
        console.log r
        if r.status == 200
          console.log r
          @destroy()
        else
          console.log r
          return
  destroy: (silent=false)=>
    @records.forEach (d)=>
      if d.group.gid == @gid
        d.group = null
    @constructor.trigger "pre-delete", @

    @constructor.index[@id] = null
    coll = @constructor.collection
    i = coll.indexOf @
    coll.splice i,1

    @constructor.trigger "deleted", @

  setGroup: (group)->
    # sets the group of individual features to other group
    # and destroys itself.
    for feature in @records
      feature.group = group
    @records = []
    @destroy()

  changeFitType: (v)->
    # Sets the value of "same_plane" and persists
    # to database
    console.log "Changing fit type"
    data =
      measurements: featureIDs(@records)
      same_plane: v

    app.API "/group/#{@gid}"
      .post JSON.stringify(data), (e,r)=>
        if r.status == 200
          @updateAttributes r.response.data
          @constructor.trigger "updated", @
        else
          return

module.exports = GroupedFeature

class Feature
  @collection: []
  @index: new Array
  @get: (id)->@index[id]

  @reset: ->
    # Resets collection in anticipation of
    # updating with new data from server
    @index = new Array
    @collection = []

  hovered: false
  hidden: false
  group: null
  grouped: false
  constructor: (options)->
    for key of options
      @[key] = options[key]

    @constructor.collection.push @
    @constructor.index[@id] = @

  setGroup: (group)=>
    if @group is null
      @group = group
    else
      @group.removeFeature @
      @group = group

module.exports = Feature

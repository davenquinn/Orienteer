class Feature
  hovered: false
  hidden: false
  selected: false
  group: null
  grouped: false
  constructor: (options)->
    for key of options
      @[key] = options[key]

  setGroup: (group)=>
    if @group is null
      @group = group
    else
      @group.removeFeature @
      @group = group

module.exports = Feature

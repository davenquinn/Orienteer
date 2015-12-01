Spine = require "spine"

class Note extends Spine.Module
  @extend Spine.Events
  @create: =>
    @trigger "created"
  constructor: ->
    super

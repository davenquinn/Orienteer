Spine = require "spine"

class CollapsiblePanel extends Spine.Controller
  constructor: ->
    super
    @options.animationDuration ?= 300

  toggle: (cb)=> @visible not @visible(), cb
  visible: (shouldShow, cb)=>
    # Getter/setter method for visibility
    # We just want to figure
    # out if it's visible or not...
    return @el.is ":visible" unless shouldShow?

    @_show shouldShow

  _show: (shouldShow, cb)->
    # Skeletal private method to
    # show/hide as appropriate
    # (should be overridden)
    if not shouldShow
      @el.hide @options.animationDuration, cb
    else
      @el.show @options.animationDuration, cb

module.exports = CollapsiblePanel

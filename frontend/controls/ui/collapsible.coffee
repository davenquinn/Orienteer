Spine = require "spine"

class CollapsiblePanel extends Spine.Controller
  constructor: ->
    super
    @options.animationDuration = 300

  toggle: => @visible not @visible()
  visible: (shouldShow)=>
    # Getter/setter method for visibility
    # We just want to figure
    # out if it's visible or not...
    return @el.is ":visible" unless shouldShow?

    @_show shouldShow

  _show: (shouldShow)->
    # Skeletal private method to
    # show/hide as appropriate
    # (should be overridden)
    if not shouldShow
      @el.hide @options.animationDuration
    else
      @el.show @options.animationDuration

module.exports = CollapsiblePanel

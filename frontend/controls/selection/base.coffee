Spine = require "spine"
SelectionList = require "./list"

class SelectionControl extends Spine.Controller
  template: require "./template.html"
  constructor: ->
    super
    @el.attr "class", "selection-control flex flex-container"
    @setupViews()
    @setupEvents()

  setupViews: ->
    @selection = @data.selection unless @selection?
    @el.html @template

    @list = new SelectionList
      el: @$(".selection-list")
      data: @data
      selection: @selection

  setupEvents: ->
    @$(".clear").on "click", @selection.clear
    @$(".group").on "click", @selection.createGroup

module.exports = SelectionControl

$ = require "jquery"
Spine = require "spine"
SelectionControl = require "./base"
GroupedDataControl = require "./grouped-data"

class Sidebar extends Spine.Controller
  className: "selection-sidebar flex-container"
  group: null

  constructor: ->
    super
    @el.hide()

  addData: (@data)=>
    @selection = @data.selection unless @selection?
    @el.html @template

    @sel = new SelectionControl
      el: $("<div />").appendTo @el
      data: @data
      selection: @selection

    @listenTo @data.selection, "selection:updated", @updateView
    @listenTo @sel, "group-selected", @viewGroup
    @updateView()

  updateView: (sel)=>
    visible = @el.is ":visible"
    return unless sel?
    if not sel.length and visible
      # make invisible
      @el
        .velocity {
          marginLeft: "-20rem"
          duration: 500}, display: "none"
      return
    else if not visible
      @el
        .css
          marginLeft: "-20rem"
        .velocity {
          marginLeft: "1rem"
          duration: 500},
          display: "flex"

    if sel.length == 1 and sel[0].records?
        @viewGroup(sel[0]) unless @group?
    else if @group?
      @hideGroup()

  viewGroup: (group)=>
    @sel.el.hide()
    @log "Creating grouped data control"
    @group = new GroupedDataControl
      el: $("<div />").appendTo @el
      data: @data
      selection: group
    @listenToOnce @group, "close", @hideGroup

  hideGroup: =>
    @sel.el.show()
    @group.el.hide()
    @group.release()
    @group = null

module.exports = Sidebar

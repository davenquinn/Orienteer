$ = require "jquery"
Spine = require "spine"
SelectionControl = require "./base"
GroupedDataControl = require "./grouped-data"
ViewerControl = require '../data-panel/viewer'

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
        .velocity "slideUp", {duration: 500}, display: "none"
      return
    else if not visible
      @el
        .css
          height: "0 px"
        .velocity 'slideDown', {duration: 500},
          display: "block"

    if sel.length == 1
      if sel[0].records?
        @viewGroup(sel[0]) unless @group?
      else
        @viewData sel[0]
    else if @group?
      @hideGroup()

  viewData: (record)=>
    @sel.el.hide()
    @log "Creating viewer control"
    @group = new ViewerControl
      el: $("<div />").appendTo @el
      data: record
    @listenToOnce @group, "close", @hideGroup

  viewGroup: (group)=>
    @sel.el.hide()
    @log "Creating grouped data control"
    @group = new GroupedDataControl
      el: $("<div />").appendTo @el
      data: @data
      selection: group
    @listenToOnce @group, "close", @hideGroup

  hideGroup: =>
    @log "Hiding data panel"
    @sel.el.show()
    @group.el.hide()
    @group.release()
    @group = null

module.exports = Sidebar

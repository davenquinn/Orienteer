$ = require "jquery"
Spine = require "spine"
SelectionControl = require "./base"
GroupedDataControl = require "./grouped-data"
ViewerControl = require './viewer'

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
    @listenTo @sel.list, "group-selected", @viewGroup
    @listenTo @sel.list, "focused", (d)=>
      console.log d
      @viewData(d)
    @updateView()

  updateView: (sel)=>
    visible = @el.is ":visible"
    return unless sel?
    if not sel.length and visible
      if @viewer
        @hideGroup()
      # make invisible
      @el
        .velocity "slideUp", {duration: 500}, display: "none"
      return
    else if not visible
      @el
        .css
          height: "0 px"
        .velocity 'slideDown', {duration: 500},
          display: "flex"

    if sel.length == 1
      if sel[0].records?
        @viewGroup(sel[0]) unless @viewer?
      else
        @viewData sel[0]
    else if @viewer?
      @hideGroup()

  viewData: (record)=>
    @sel.el.hide()
    @log "Creating viewer control"
    @viewer = new ViewerControl
      el: $("<div />").appendTo @el
      data: record
    @listenToOnce @viewer, "close", @hideGroup

  viewGroup: (group)=>
    @sel.el.hide()
    @log "Creating grouped data control"
    @viewer = new GroupedDataControl
      el: $("<div />").appendTo @el
      data: @data
      selection: group
    @listenToOnce @viewer, "close", @hideGroup

  hideGroup: =>
    @log "Hiding data panel"
    @sel.el.show()
    @viewer.el.hide()
    @viewer.release()
    @viewer = null

module.exports = Sidebar

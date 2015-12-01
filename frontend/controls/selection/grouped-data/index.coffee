d3 = require 'd3'
SelectionControl = require "../base"
Toggle = require "../../toggle"

class GroupedDataControl extends SelectionControl
  template: require "./template.html"
  class: "selection-control group-control flex flex-container"
  events:
    "click .close": "close"
    "click .split": "split"
  constructor: ->
    super

    d3.select @$("h3")[0]
      .datum @selection
      .text (d)-> "Group #{d.gid}"
      .on "mouseover", @data.hovered
      .on "mouseout", @data.hovered

    @grouped = new Toggle
      el: @$ ".toggle"
      enabled: @selection.same_plane
      labels: ["Parallel planes", "Same plane"]

    @listenTo @grouped, "change-requested", (v)=>
      console.log "Changing to same plane", v
      @selection.changeFitType(v)

    @listenTo @selection.constructor, "updated", =>
      console.log "Selection updated"
      @grouped.change @selection.same_plane

    @list.update()

  close: ->
    @log "Closing grouped data control"
    @trigger "close"

  split: ->
    @log "Splitting up group"
    @selection.requestDestruction()
    @trigger "close"

module.exports = GroupedDataControl

Spine = require "spine"
Map = require "../../controls/map"
SelectionControl = require "../../controls/selection"
DataPanel = require "../../controls/data-panel"
InfoBox = require "../../controls/info-box"
template = require "./template.html"
infoTemplate = require "./info-box.html"
CollapsiblePanel = require "../../controls/ui/collapsible"

d3 = require "d3"
$ = require "jquery"

FilterData = require "../../controls/filter-data"

f = d3.format "> 6.1f"

class OptionsBar extends CollapsiblePanel
  constructor: ->
    super
    throw "@data required" unless @data
    @el.hide()
    @filter = new FilterData
      el: @$ ".filter-data"
      data: @data

class AttitudePage extends Spine.Controller

  constructor: ->
    super
    @el.html template

    @options = new OptionsBar
      el: @$ "div.options"
      data: @data
    @sidebar = new SelectionControl
      el: @$ ".sidebar"

    @map = new Map
      parent: @
      el: @$ ".map"
    @map.addData @data
    @sidebar.addData @data
    @dataPanel = new DataPanel
      el: @$ ".data-panel"
    @map.invalidateSize()

    navItems = [
      {
        control: @options,
        name: "Options"
      }
      {
        control: @dataPanel,
        name: "Data"
      }
    ]

    nB = @$ ".navbar .nav"
    @navControls = d3.select nB[0]
      .selectAll "a"
      .data navItems

    @navControls.enter()
      .append "a"
        .text (d)->d.name
        .attr class: "btn btn-sm"
        .classed "selected", (d)->d.control.visible()
        .on "click", (d)->
          vis = d.control.visible()
          d.control.toggle()
          d3.select @
            .classed "selected", not vis

    @listenToOnce @data.constructor, "updated", =>
      console.log "Finished loading data"
      @$(".app-status").removeClass "loading"

    @listenTo @data.constructor, "hovered", (d)=>
      # If hover-out, data will not be defined
      return unless d?
      @$(".navbar div.info")
        .html infoTemplate
          id: d.id
          strike: f(d.properties.strike)
          dip: f(d.properties.dip)
          tags: d.tags
          showTags: d.tags.length > 0

module.exports = AttitudePage

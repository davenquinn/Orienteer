Spine = require "spine"
Map = require "../../controls/map"
SelectionControl = require "../../controls/selection"
DataPanel = require "../../controls/data-panel"
InfoBox = require "../../controls/info-box"
template = require "./template.html"
infoTemplate = require "./info-box.html"

d3 = require "d3"
$ = require "jquery"

FilterData = require "../../controls/filter-data"

f = d3.format "> 6.1f"

class AttitudePage extends Spine.Controller

  constructor: ->
    super
    @el.html template

    @filter = new FilterData
      el: @$ ".filter-data"
      data: @data
    @filter.el.hide()

    @sidebar = new SelectionControl
      el: @$ ".selection-panel"

    @map = new Map
      parent: @
      el: @$ ".map"
    @map.addData @data

    @sidebar.addData @data
    @dataPanel = new DataPanel
      el: @$ ".data-panel"
    @map.invalidateSize()

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

  toggleData: =>
    @dataPanel.toggle @map.invalidateSize

  toggleFilter: =>
    @filter.toggle @map.invalidateSize

  remove: =>
    @map.leaflet.remove()
    @el.remove()

module.exports = AttitudePage

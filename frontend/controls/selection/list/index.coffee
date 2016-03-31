Spine = require "spine"
$ = require "jquery"
d3 = require "d3"
template = require "./template.html"

sf = d3.format ">8.1f"
df = d3.format ">6.1f"

class SelectionList extends Spine.Controller
  tag: "ul"
  events:
    "click span.group": "viewGroup"
  constructor: ->
    super
    throw "@selection required" unless @selection?

    @ul = d3.select @el[0]

    @listenTo @selection, "selection:updated", @update
    @listenTo @data.constructor, "hovered", (data)=>
      return unless @items?
      @items.classed "hovered", (d)->d.hovered
    @listenTo @data.constructor, "filtered updated", @update

  update: =>
    @items = @ul.selectAll "li"
      .data @selection.visible(), (d)->d.id

    enter = @items.enter()
      .append "li"
        .html (d)->
          template
            strike: sf(d.properties.strike)
            dip: df(d.properties.dip)
            grouped: d.records?
            n: if d.records? then d.records.length else 1
        .on "mouseover", @data.hovered
        .on "mouseout", @data.hovered
        .on "click", @focusItem

    enter.select "span.remove"
      .on "click", @selection.update

    @items.exit().remove()

  focusItem: (d)=>
    @trigger "focused", d

  viewGroup: (e)->
    node = e.currentTarget.parentNode
    target = d3.select node
    group =  target.data()[0]
    @trigger "group-selected", group

module.exports = SelectionList

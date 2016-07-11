Spine = require "spine"
d3 = require "d3"
$ = require "jquery"
template = require "./template.html"
rewind = require 'geojson-rewind'
attitude = require "attitude"

Data = require "../../app/data"

Stereonet = attitude.Stereonet
createPlane = attitude.functions.plane

sf = d3.format " >8.1f"

class StereonetView extends Spine.Controller
  constructor: ->
    # Can specify both data and selection if you don't want
    # them to go to the default values.
    super
    @stereonet = new Stereonet @el[0]

    @data = window.app.data
    throw "No data" unless @data?
    @addData(@data) if @data?

    a = @stereonet.frame
    @hovered = a.append 'g'

  addData: (@data)=>
    @selection = @data.selection unless @selection?
    @listenTo @selection, "selection:updated", @update
    @listenTo Data, "filtered updated", @update
    @listenTo Data, "hovered", @onHover
    @update()

  update: =>
    ds = @selection.visible()
    console.log ds

    @items = @stereonet.dataArea.selectAll 'g'
      .data ds, (d)->d.id

    @items.enter()
      .append "g"
        .on "mouseover mouseout", @data.hovered
        .each createPlane(color: 'red')
    @items.exit().remove()

    @stereonet.draw()

  onHover: (d)=>
    console.log d
    if not d? then return
    data = if d.hovered then [d] else []
    sel = @hovered.selectAll "g"
      .data data, (d)->d.id
    sel.enter()
      .append "g"
        .each createPlane(color: 'purple')
        .classed "hovered", true
    @hovered.selectAll 'path'
      .attr d: @path

    sel.exit().remove()
    @stereonet.draw()

module.exports = StereonetView

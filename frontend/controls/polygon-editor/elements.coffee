d3 = require("d3")

class Element
  constructor: (@shape) ->
    @layer = @shape._.append("g")
      .attr("class",@class)
    @scales = @shape.scales
    @_map = @shape._map
    console.log @_map

    @shape.parent.on "updated:scales", (e,scales)=>
      @scales = scales

  on: (event, callback) ->
    @_.on(event,callback)


class BasePoints extends Element
  r: 6
  test: (d) -> d.id

  bindData: ->
    @_ = @layer.selectAll("circle")
      .data(@data,@test)

  update: (data) =>
    @bindData(data)

    @_.enter()
      .append("circle")
      .attr r: @r

    @_.exit().remove()

    @_.each (d)->
      console.log d
      loc = @_map.project(d)
      d3.select @
        .attr
          cx: loc.x
          cy: loc.y

class GhostPoints extends BasePoints
  class: "ghosts"
  r: 3
  getX: (d) => @scales.x (d.start.x+d.end.x)/2
  getY: (d) => @scales.y (d.start.y+d.end.y)/2
  test: (d) -> d.id
  bindData: (data)=>
    @data = data.faces
    super()

class Points extends BasePoints
  class: "points"
  bindData: (data)=>
    @data = data.vertices
    super()
    @setupDragging()

  setupDragging: =>
    self = @
    @drag = d3.behavior.drag()
    @drag.on "dragstart", (d) ->
      d3.select(@).classed("dragging", true)
      d3.event.sourceEvent.stopPropagation()
    @drag.on "drag", (d,i) ->
      c =
        x: self.scales.x.invert(d3.event.x)
        y: self.scales.y.invert(d3.event.y)
      self.shape.data.update i,c
      self.shape.update()
      d3.event.sourceEvent.stopPropagation()

    @drag.on "dragend", (d) ->
      d3.select(@).classed("dragging", false)
      self.shape.update()
      d3.event.sourceEvent.stopPropagation()

  update: (data) ->
    super(data)
    @_.classed
      draggable: true
      first: (d,i) -> i == 0 and not data.ring
      endpoint: (d,i) =>
        return false if data.ring
        i == 0 or i == @data.length-1

    @_.call(@drag)

class GuideLines extends Element
  class: "lines"
  update: (data) ->
    @data = data.faces

    @_ = @layer.selectAll(".line")
      .data @data, (d)-> d.id


    @_.enter()
      .append("line")
      .attr
        class: "line"
        "stroke-dasharray": "2,2"

    @_.exit().remove()

    @_.attr
      x1: (d) => @scales.x d.start.x
      y1: (d) => @scales.y d.start.y
      x2: (d) => @scales.x d.end.x
      y2: (d) => @scales.y d.end.y

module.exports =
  Points: Points
  GhostPoints: GhostPoints
  Lines: GuideLines

d3 = require "d3"
PolygonData = require "./data"
Elements = require "./elements"
OverlayImage = require "./overlay"

class Polygon
	events: d3.dispatch("closed","updated")
	constructor: (@parent,data=null,@editable=false) ->
    @_ = @parent.svg.append("g").attr("class","polygon")
    @_map = @parent._map

    @data = new PolygonData
    @lines = new Elements.Lines @
    @points = new Elements.Points @
    @ghosts = new Elements.GhostPoints @
    @overlay = new OverlayImage @
    @setEditable(@editable)

    @parent.on "updated:scales", (e,scales) =>
      @scales = scales
      @overlay.update @data
      @update()

	on: (event, callback) =>
		@events.on(event,callback)

	setEditable: (@editable=true)->
		@_.classed("editable",@editable)

	addPoint: =>
    e = d3.event

    return if e.defaultPrevented
    return false if @data.ring

    loc = @_map.unproject x: e.layerX, y: e.layerY
    console.log loc
    @data.add loc

    @update()

	asGeoJSON: =>
		@data.asGeoJSON()

	update: =>
		@events.updated(@data)

		@points.update @data
		@lines.update @data
		@ghosts.update @data

		@points.drag.on "dragend", (d,i)=>
			console.log "Stopped dragging"
			@overlay.update @data

		self = @
		@points.on "click", (d,i) ->
			e = d3.event
			el = d3.select @
			console.log "Clicked a point"
			if e.shiftKey # remove node
				self.data.remove(i)
			else if el.classed("first")
				self.data.closeRing()
				self.overlay.update self.data
				if self.data.ring
					self.events.closed self.data
			self.update()
			e.stopPropagation()

		@ghosts.on "click", (d,i) ->
			e = d3.event
			#d3.select(@).remove()
			g = i+1
			self.data.add(d.midpoint(),g)
			console.log "Added ghost point at array position #{g}"
			self.update()
			e.stopPropagation()

module.exports = Polygon

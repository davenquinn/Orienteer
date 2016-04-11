d3 = require "d3"
View = require("space-pen").View
Polygon = require "./polygon"

class EditorView extends View
	@content: ->
		@div id: "editor"

	afterAttach: (onDOM)=>
		return unless onDOM

		@svg = d3.select(@[0])
			.append("svg")
		console.log @svg

		@scales =
			x: d3.scale.identity()
			y: d3.scale.identity()

		drag = d3.behavior.drag()
			.on "drag", @onDrag
		@svg.call drag

		@areas =
			primary: @createPolygon
				class: "primary"
			secondary: null
		@trigger("editing:start", @areas)

	onDrag: =>
		@trigger "extent:updated",
			x: @extent.x.map (d)->d-d3.event.dx
			y: @extent.y.map (d)->d-d3.event.dy

	setupSecondary: =>
		@svg.on('click',null)
		@areas.secondary = @createPolygon class:"secondary"

	createPolygon: (options)=>
		polygon = new Polygon @
		polygon._.classed(options.class,true)
		@svg.on "click", polygon.addPoint

		polygon.on "closed", =>
			console.log "The polygon is closed"
			@trigger "editing:closed", @areas
		return polygon

	setExtent: (@extent) =>
		w = @parent().width()
		h = @parent().height()

		@svg.attr
			width: w
			height: h

		@scales =
			x: d3.scale.linear().domain(extent.x).range [0,w]
			y: d3.scale.linear().domain(extent.y).range [0,h]

		@trigger "updated:scales",@scales

module.exports = EditorView

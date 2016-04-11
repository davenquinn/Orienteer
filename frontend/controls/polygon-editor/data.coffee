$ = require "jquery"

count = 0
counter = ->
	count += 1

class Point
	constructor: (options) ->
		@id = counter()
		@x = options.x
		@y = options.y

class Face
	constructor: (options) ->
		@id = counter()
		@start = options.start
		@end = options.end

	midpoint: =>
		new Point
			x: (@start.x+@end.x)/2
			y: (@start.y+@end.y)/2

class PolygonData
	constructor: (options) ->
		@_count = 0
		@vertices = new Array
		@faces = new Array
		@midpoints = new Array
		@ring = false
	counter: =>
		@_count += 1
	add: (c,i=false) =>
		point = new Point c
		if i == false then i = @vertices.length
		@vertices.splice i,0,point

		@updateFaces(i,1)
		console.log @vertices
		console.log @faces

	updateFaces: (i,num)=>
		if @vertices.length < 2
			@faces = []
			return

		next = i+1
		next = 0 if next == @vertices.length

		a = new Face
			start: @vertices[i-1]
			end: @vertices[i]
		b = new Face
			start: @vertices[i]
			end: @vertices[next]

		loc = i-1
		loc++ if loc == -1

		@faces.splice loc,num,a,b
		@_sanitizeFaces(next)

	_sanitizeFaces: (next) =>
		appropriateLength = @vertices.length
		appropriateLength -= 1 if not @ring
		if @faces.length != appropriateLength
			@faces.pop(next)
		return

	asGeoJSON: =>
		type = if @ring then "Polygon" else "LineString"
		c = @vertices.map (d)->[d.x,d.y]
		if @ring
			c.push(c[0])
		data =
			type: type
			coordinates: [c]

	update: (i,c)=>
		@vertices[i] = $.extend(@vertices[i],c)

	remove: (i) =>
		@vertices.splice(i,1)
		console.log "Removed node at position #{i}"
		if @vertices.length < 3
			@ring = false

		@faces.splice i,1

		next = i
		next = 0 if next == @vertices.length
		if i != 0
			@faces[i-1].end = @vertices[next]
		if i == 0 and @ring
			@faces[@vertices.length-1].end = @vertices[next]

		@_sanitizeFaces(next)

	test_unique:
		vertex: (d)-> d.id
		face: (d)-> d.start.x+10*d.end.x
	closeRing: =>
		if @vertices.length < 3
			@ring = false
			return false
		@ring = true
		@faces.push new Face
			start: @vertices[@vertices.length-1]
			end: @vertices[0]

module.exports = PolygonData

d3 = require "d3"

class OverlayImage
    constructor: (@polygon) ->
        console.log "Creating image"
        @canvas = d3.select("#editor")
            .append("canvas")
            .attr("class","image-overlay")
    update: (data)=>
        if not data.ring
            return
        data = data.asGeoJSON()
        console.log data
        App.api.post "area", data, @setPolygon

    setPolygon: (data)=>
        offs =
            x: @polygon.scales.x data.offset[0]
            y: @polygon.scales.y data.offset[1]
        shape =
            width: @polygon.scales.x data.shape[0]
            height: @polygon.scales.y data.shape[1]
        @canvas.attr shape
        @canvas.style "right", offs.x
        @canvas.style "top", offs.y
        @img = new Image
        @img.src = data.image
        @ctx = @canvas[0][0].getContext('2d')
        @ctx.imageSmoothingEnabled = false;
        @ctx.mozImageSmoothingEnabled = false;
        @ctx.oImageSmoothingEnabled = false;
        @ctx.webkitImageSmoothingEnabled = false;
        @ctx.drawImage(@img,0,0)

module.exports = OverlayImage

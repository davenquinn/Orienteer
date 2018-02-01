{MapLayer, TileLayer} = require 'react-leaflet'
{GridLayer} = require 'leaflet'
tilelive = require '@mapbox/tilelive'
mbtiles = require 'mbtiles'
require("tilelive-modules/loader")(tilelive, {require: ['mbtiles']})
Promise = require 'bluebird'

class TileLiveLayer extends GridLayer
  constructor: (@id, @uri, options)->
    super()
    @options.updateWhenIdle = true
    @options.verbose ?= false
    console.log @uri
    loadTiles = Promise.promisify tilelive.load
    @__tileSourcePending = loadTiles(@uri)
    @initialize options

  createTile: (coords, done)->
    {z,x,y} = coords
    tile = document.createElement('img')
    @tileSource.getTile z,x,y, (err, buffer, opts)->
      if err then throw err
      #i_ = im.encodeSync 'png'
      blob = new Blob [buffer], {type: 'image/png'}
      console.log blob
      url = URL.createObjectURL(blob)
      tile.src = url
      tile.onload = =>
        console.log tile
        done(null, tile)
        URL.revokeObjectURL(url)
    return tile

  onAdd: (map)=>
    @tileSource = await @__tileSourcePending
    # We want to be able to check if we are currently
    # zooming
    @_zooming = false
    map.on "zoomstart",=>
      @_zooming = true
    map.on "zoomend",=>
      @_zooming = false

    super map

module.exports = TileLiveLayer

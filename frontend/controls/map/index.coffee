{Map, TileLayer, GridLayer, MapLayer} = require 'react-leaflet'
h = require 'react-hyperscript'
{Component} = require 'react'
style = require './style'
GIS = require 'gis-core'
path = require 'path'
MapnikLayer_ = require 'gis-core/frontend/mapnik-layer'
setupProjection = require "gis-core/frontend/projection"
parseConfig = require "gis-core/frontend/config"

class MapnikLayer extends MapLayer
  createLeafletElement: (props)->
    {name, xml} = props
    opts = @getOptions(props)
    console.log opts
    lyr = new MapnikLayer_ name, xml, opts
    return lyr

defaultOptions =
  tileSize: 256
  zoom: 0
  attributionControl: false
  continuousWorld: true
  debounceMoveend: true

class MapControl extends Component
  constructor: (props)->
    cfg = app.config.map
    cfg.basedir ?= path.dirname app.config.configFile
    cfg = parseConfig cfg

    @state = layers: cfg.layers

    options = {}
    for k,v of cfg
      continue if k == 'layers'
      options[k] ?= v

    if options.projection?
      s = options.projection
      projection = setupProjection s,
        minResolution: options.resolution.min # m/px
        maxResolution: options.resolution.max # m/px
        bounds: options.bounds
      options.crs = projection

    for k,v of defaultOptions
      if not options[k]?
        options[k] = v

    @state.options = options

    super props
    console.log @props

  createLeafletElement: (props)->
    map = super props
    console.log map
    map


  render: ->
    {center, zoom, crs} = @state.options
    console.log @state
    lyr = @state.layers[0]
    h Map, {center, zoom, crs, tileSize: 512}, [
      h MapnikLayer, lyr
    ]

module.exports = MapControl

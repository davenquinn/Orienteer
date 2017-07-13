{Map, TileLayer, GridLayer} = require 'react-leaflet'
h = require 'react-hyperscript'
{Component} = require 'react'
style = require './style'
GIS = require 'gis-core'
path = require 'path'
MapnikLayer_ = require 'gis-core/frontend/mapnik-layer'
setupProjection = require "gis-core/frontend/projection"
parseConfig = require "gis-core/frontend/config"

class MapnikLayer extends GridLayer
  constructor: (props, context)->
    super props, context
    console.log @props, @context

  createLeafletElement: (props)->
    {name, xml} = props
    lyr = new MapnikLayer_ name, xml, props
    console.log lyr
    lyr

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

    console.log options
    props.options = options
    super props

  render: ->
    position = [51.505, -0.09]

    console.log @state.layers
    h 'div', [
      h Map, @props.options, [
        h MapnikLayer, @state.layers[0]
      ]
    ]

module.exports = MapControl

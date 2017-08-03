{Map, MapLayer, LayersControl, ScaleControl} = require 'react-leaflet'
h = require 'react-hyperscript'
{Component} = require 'react'
style = require './style'
path = require 'path'
BaseMapnikLayer = require 'gis-core/frontend/mapnik-layer'
setupProjection = require "gis-core/frontend/projection"
parseConfig = require "gis-core/frontend/config"
MapDataLayer = require '../map-data-layer'
SelectBox = require './select-box'

{BaseLayer, Overlay} = LayersControl

class MapnikLayer extends MapLayer
  createLeafletElement: (props)->
    {name, xml} = props
    opts = @getOptions(props)
    lyr = new BaseMapnikLayer name, xml, opts
    return lyr

defaultOptions =
  tileSize: 256
  zoom: 0
  attributionControl: false
  continuousWorld: true
  debounceMoveend: true

class BoxSelectMap extends Map
  createLeafletElement: (props)->
    map = super props
    map.addHandler "boxSelect", SelectBox
    map.boxSelect.enable()
    map.on "boxSelected", (e)=>
      console.log "Box selected"
      app.data.selectByBox(e.bounds)
    return map

class MapControl extends Component
  constructor: (props)->
    super props

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
      {min, max} = options.resolution
      projection = setupProjection s,
        minResolution: min # m/px
        maxResolution: max # m/px
        bounds: options.bounds
      options.crs = projection

    for k,v of defaultOptions
      if not options[k]?
        options[k] = v

    @state.options = options

  render: ->
    # Add base layers
    children = @state.layers.map (lyr, i)->
      h BaseLayer,
        {name: lyr.name, checked: i==0, key: lyr.name},
        h(MapnikLayer, lyr)

    overlays = [
      h Overlay, name: 'Attitudes', checked: true, key: 'Attitudes',
        h MapDataLayer, records: @props.records
    ]

    {center, zoom, crs} = @state.options
    h BoxSelectMap, {center, zoom, crs, tileSize: 512, boxZoom: false}, [
      h LayersControl, position: 'topleft', children.concat(overlays)
      h ScaleControl, {imperial: false}
    ]

module.exports = MapControl

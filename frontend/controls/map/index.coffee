{Map, MapLayer, LayersControl, ScaleControl, TileLayer} = require 'react-leaflet'
h = require 'react-hyperscript'
{Component} = require 'react'
style = require './style'
path = require 'path'
BaseMapnikLayer = require 'gis-core/frontend/mapnik-layer'
setupProjection = require "gis-core/frontend/projection"
parseConfig = require "gis-core/frontend/config"
SelectBox = require './select-box'
BackButton = require './back-button'
BaseTileLiveLayer = require './tilelive-layer'
{BaseLayer, Overlay} = LayersControl

class TileLiveLayer extends MapLayer
  createLeafletElement: (props)->
    {id, uri} = props
    opts = @getOptions(props)
    lyr = new BaseTileLiveLayer id, uri, opts
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

    cfg = app.config

    @state = {
      center: app.config.center
    }

    options = {}
    for k,v of cfg
      continue if k == 'layers'
      options[k] ?= v

    for k,v of defaultOptions
      if not options[k]?
        options[k] = v

    @state.options = options

  render: ->
    # Add base layers
    {center, zoom, layers} = @state.options
    c = [center[1],center[0]]

    overlays = []
    ix = 0
    for k,uri of app.config.layers
      overlays.push h BaseLayer, {
          name: k, key: k, checked: ix == 0
        }, [
          h TileLiveLayer, {id:k,uri, detectRetina: true}
        ]
      ix += 1

    h BoxSelectMap, {center: c, zoom, boxZoom: false}, [
      h LayersControl, position: 'topleft', overlays
      #h LayersControl, position: 'topleft', overlays
      #h ScaleControl, {imperial: false}
      #h BackButton # We cause major problems with back-navigation for now
    ]

module.exports = MapControl

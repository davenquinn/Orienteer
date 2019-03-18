{Map, MapLayer, LayersControl, ScaleControl} = require 'react-leaflet'
h = require 'react-hyperscript'
{Component} = require 'react'
style = require './style'
path = require 'path'
BaseMapnikLayer = require 'gis-core/frontend/mapnik-layer'
setupProjection = require "gis-core/frontend/projection"
parseConfig = require "gis-core/frontend/config"
SelectBox = require './select-box'
BackButton = require './back-button'
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
    children = @state.layers.map (lyr, i)->
      h BaseLayer,
        {name: lyr.name, checked: i==0, key: lyr.name},
        h(MapnikLayer, lyr)
    {center, zoom} = @state.options

    overlays = @props.children
    overlays = [
      h TileLayer, {
        url: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        attribution: "&copy; <a href=&quot;http://osm.org/copyright&quot;>OpenStreetMap</a> contributors"
      }
    ]

    h BoxSelectMap, {center, zoom, boxZoom: false}, [
      h LayersControl, position: 'topleft', children
      #h LayersControl, position: 'topleft', overlays
      h ScaleControl, {imperial: false}
      #h BackButton # We cause major problems with back-navigation for now
      overlays...
    ]

module.exports = MapControl

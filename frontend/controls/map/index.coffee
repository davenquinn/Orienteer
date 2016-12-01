SelectBox = require "./select-box"
DataLayer = require "./data-layer"
React = require 'react'
ReactDOM = require 'react-dom'
GIS = require 'gis-core'
$ = require 'jquery'
path = require 'path'
React = require 'react'
BackButton = require './back-button'

CacheDatastore = require "../../shared/data/cache"

MapnikLayer = require 'gis-core/frontend/mapnik-layer'
setupProjection = require "gis-core/frontend/projection"
style = require './style'

class MapControl extends React.Component
  constructor: ->
    super
    window.map = @

    @state =
      dataIsConfigured: false
  render: ->
    React.createElement 'div'

  componentDidMount: ->
    @node = ReactDOM.findDOMNode @
    console.log "Component mounted"

    @settings = new CacheDatastore 'map-visible-layers'

    cfg = app.config.map
    cfg.basedir ?= path.dirname app.config.configFile
    console.log cfg
    @setHeight()

    layers = @settings.get()
    cfg.initLayer = layers[0]

    @map = new GIS.Map @node, cfg
    # Add overlay layer
    @dataLayer = new DataLayer
    @dataLayer.addTo @map
    ovr = {"Bedding attitudes": @dataLayer}
    @map.addControl new BackButton
    @map.addLayerControl {}, ovr
    @map.addScalebar()

    @map.on "viewreset dragend", @extentChanged
    @map.addHandler "boxSelect", SelectBox
    @map.boxSelect.enable()
    @map.invalidateSize()

    # Set height in javascript (temporarily
    # resolves awkward behavior with flexbox)
    $(window).on 'resize', @setHeight

    setupCache = =>
      # Update cached layer information when
      # map is changed
      @visibleLayers = (v.id for k,v of @map._layers)
        .filter (d)->d?
      @settings.set @visibleLayers

    @map.on 'layeradd layerremove', setupCache
    setupCache()

  # React lifecycle methods
  componentWillUnmount: ->
    @map.remove()

  componentDidUpdate: (prevProps, prevState)->
    console.log "Map updated"
    console.log @props.records
    c = @props.records.length
    if c > 0 and not @state.dataIsConfigured
      @addData @props.data
      @state.dataIsConfigured = true

  # Done with react lifecycle methods
  invalidateSize: =>
    # Shim for flexbox
    @map.invalidateSize()

  setHeight: =>
    $(@node).height window.innerHeight

  extentChanged: =>
    #@trigger "extents", @map.getBounds()

  setBounds: (b)=>
    @map.fitBounds(b)

  getBounds: =>
    b = @map.getBounds()
    out = [
      [b._southWest.lat, b._southWest.lng]
      [b._northEast.lat, b._northEast.lng]]

  addData: (@data)=>
    @dataLayer.setupData @props.data
    @map.on "box-selected", (e)=>
      @data.selectByBox(e.bounds)



module.exports = MapControl

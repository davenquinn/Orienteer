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
  @defaultProps:
    settings:
      bounds: null
  constructor: ->
    window.map = @

    @state =
      dataIsConfigured: false
      currentBounds: null
    super()

  render: ->
    React.createElement 'div'

  componentDidMount: ->
    @node = ReactDOM.findDOMNode @
    console.log "Component mounted"

    # Map runs its own state machine which is
    # not necessarily good
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
    @map.on "box-selected", (e)=>
      app.data.selectByBox(e.bounds)

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

    # Check if there are changes to records
    c = @props.records
    if @props.records.length != prevProps.records.length
      console.log "Dataset has changed"
      @dataLayer.updateData @props.records

    if @props.selection.length != prevProps.selection.length
      @dataLayer.updateSelection @props.selection

    if @props.hovered != prevProps.hovered
      @dataLayer.onHoverIn @props.hovered

    #{bounds} = @props.settings
    #if @_cachedBounds != bounds
    #  @setBounds bounds

  # Done with react lifecycle methods
  invalidateSize: =>
    # Shim for flexbox
    @map.invalidateSize()

  setHeight: =>
    $(@node).height window.innerHeight

  extentChanged: =>
    console.log "Map extents changed"
    #app.updateSettings {map: {bounds: {$set: @map.getBounds()}}}

  setBounds: (b)=>
    @map.fitBounds(b)

  getBounds: =>
    b = @map.getBounds()
    @_cachedBounds = [
      [b._southWest.lat, b._southWest.lng]
      [b._northEast.lat, b._northEast.lng]]
    @_cachedBounds

module.exports = MapControl

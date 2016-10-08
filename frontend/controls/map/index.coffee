Spine = require "spine"
SelectBox = require "./select-box"
DataLayer = require "./data-layer"
GIS = require 'gis-core'
$ = require 'jquery'
L = require 'leaflet'
path = require 'path'
React = require 'react'
ReactDOM = require 'react-dom'
BackButton = require './back-button'

CacheDatastore = require "../../shared/data/cache"

MapnikLayer = require 'gis-core/frontend/mapnik-layer'
setupProjection = require "gis-core/frontend/projection"

class Map extends Spine.Controller
  class: "viewer"
  constructor: ->
    super
    window.map = @

    @settings = new CacheDatastore 'map-visible-layers'

    cfg = app.config.map
    cfg.basedir ?= path.dirname app.config.configFile
    console.log cfg
    @setHeight()
    @leaflet = new GIS.Map @el[0], cfg
    # Add overlay layer
    @dataLayer = new DataLayer
    @dataLayer.addTo @leaflet
    ovr = {"Bedding attitudes": @dataLayer}
    @leaflet.addLayerControl {}, ovr
    @leaflet.addScalebar()

    @leaflet.on "viewreset dragend", @extentChanged
    @leaflet.addHandler "boxSelect", SelectBox
    @leaflet.addControl new BackButton
    @leaflet.invalidateSize()

    # Set height in javascript (temporarily
    # resolves awkward behavior with flexbox)
    $(window).on 'resize', @setHeight

    _ = =>
      # Update cached layer information when
      # map is changed
      @visibleLayers = (v.id for k,v of @leaflet._layers)
      @settings.set @visibleLayers

    @leaflet.on 'layeradd layerremove', _

    #Add a link to the homepage
    #el_ = @$ '.leaflet-top.leaflet-left'
    #.append "<div />"
    #e = React.createElement BackButton
    #ReactDOM.render e, el_[0]

  invalidateSize: =>
    # Shim for flexbox
    @leaflet.invalidateSize()

  setHeight: =>
    @el.height window.innerHeight

  extentChanged: =>
    @trigger "extents", @leaflet.getBounds()

  setBounds: (b)=>
    @leaflet.fitBounds(b)

  getBounds: =>
    b = @leaflet.getBounds()
    out = [
      [b._southWest.lat, b._southWest.lng]
      [b._northEast.lat, b._northEast.lng]]

  addData: (@data)=>
    @dataLayer.setupData @data
    @leaflet.on "box-selected", (e)=>
      f = @data.within(e.bounds)
      f.filter (d)->not d.hidden
      @data.selection.addSeveral f

module.exports = Map

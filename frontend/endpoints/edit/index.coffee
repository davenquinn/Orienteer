Spine = require 'spine'
$ = require 'jquery'
GIS = require "gis-core"
L = GIS.Leaflet

React = require 'react'
ReactDOM = require 'react-dom'

styles = require './styles'
Sidebar = require './sidebar'
DataLayer = require "./data-layer"

class EditorPage extends Spine.Controller
  constructor: ->
    super
    @el.addClass styles.page

    cfg = app.config.map
    cfg.basedir ?= path.dirname app.config.configFile

    sidebar = React.createElement Sidebar
    @sidebar = ReactDOM.render sidebar, @el[0]

    mapContainer = $('<div />')
      .addClass 'flex'
      .appendTo @el

    cfg.boxZoom = false
    @map = new GIS.Map mapContainer[0], cfg
    window.map = @map
    @map.addLayerControl()
    @map.addScalebar()
    @map.invalidateSize()

    lyr = new DataLayer
    lyr.addTo @map
    lyr.events.on 'selected', (d)=>
      @sidebar.setState item: d

module.exports = EditorPage

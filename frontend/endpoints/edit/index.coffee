Spine = require 'spine'
$ = require 'jquery'
GIS = require "gis-core"
L = GIS.Leaflet

React = require 'react'
ReactDOM = require 'react-dom'

styles = require './styles'
Sidebar = require './sidebar'
DataLayer = require "./data-layer"

oldLoc = null

class EditorPage extends Spine.Controller
  constructor: ->
    super
    @el.addClass styles.page

    @state =
      selected: null
      editing: false

    cfg = app.config.map
    cfg.basedir ?= path.dirname app.config.configFile

    toolbarHandlers =
      edit: @setupEditor
      cancel: => @setSelected null

    sidebar = React.createElement Sidebar,
      toolbarHandlers: toolbarHandlers
      newHandler: @setupEditor
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

    window.onresize = =>
      @map.invalidateSize()

    @lyr = new DataLayer
    @lyr.addTo @map
    @lyr.events.on 'selected', @setSelected

  setupEditor: =>
    @state.editing =
      complete: false
      closed: false
      enabled: true
      type: 'LineString'
      onChangeType: (t)=>
        console.log "Changing target type"
        @state.editing.type = t
        @lyr.editor.setType(@state.editing.type)
      onFinish: =>
        if @state.complete
          @lyr.editor.finalize()
        else
          @lyr.editor.doneAddingPoints()
    @state.item = {type: 'Feature',geometry: null}

    @sidebar.setState @state
    @lyr.setupEditor @state.selected

  setSelected: (d)=>
    @state.selected = d
    if d?
      oldLoc = [@map.getCenter(),@map.getZoom()]
      @map.fitBounds L.geoJson(d)
    else if oldLoc?
      @map.setView oldLoc[0],oldLoc[1], animation: false
    @lyr.setSelected d
    @sidebar.setState item: d

module.exports = EditorPage

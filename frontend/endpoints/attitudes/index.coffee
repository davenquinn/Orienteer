Spine = require "spine"
React = require 'react'
ReactDOM = require 'react-dom'
MapControl = require "../../controls/map"
SelectionControl = require "../../controls/selection"
DataPane = require "./data-pane"
MapDataLayer = require '../../controls/map-data-layer'
{LayersControl} = require 'react-leaflet'
h = require 'react-hyperscript'
SplitPane = require 'react-split-pane'

{Overlay} = LayersControl

d3 = require "d3"
$ = require "jquery"

style2 = require '../styles.styl'
style = require './style.styl'

f = d3.format "> 6.1f"

paneStyle =
  display: 'flex'
  flexDirection: 'column'

class AttitudePage extends React.Component
  constructor: (props)->
    super props

    @state =
      selection: []
      hovered: null
      records: []
      featureTypes: []

  render: ->
    s = null
    if @state.selection.length == 0
      s = display: 'none'
    else
      s = overflowY: 'scroll'

    h SplitPane, {
      split: "vertical"
      minSize: 300
      primary: "second"
      paneStyle
      pane2Style: s
      onChange: @onResizePane
    },[
      h MapControl, {settings: @props.settings.map},[
        h Overlay, name: 'Attitudes', checked: true, [
          h MapDataLayer, {
            records: @state.records
            hovered: @state.hovered
          }
        ]
      ]
      h 'div', className: style.sidebar, [
        h 'div', className: style.sidebarComponent, [
          h SelectionControl, {
            data: @props.data
            records: @state.selection
            hovered: @state.hovered
          }
        ]
        h DataPane, {
          records: @state.selection
          hovered: @state.hovered
          featureTypes: @state.featureTypes
        }
      ]
    ]

  # The below is a shim but it'll work for now
  componentDidMount: ->
    @props.data.selection.bind "selection:updated", @updateSelection
    @props.data.constructor.bind "hovered", @updateHovered
    @props.data.constructor.bind "updated", @updateData
    @props.data.constructor.bind "feature-types", (types)=>
      @setState featureTypes: types

  updateData: =>
    @setState records: @props.data.records

  componentWillUnmount: ->
    @props.data.selection.unbind "selection:updated", @updateSelection
    @props.data.constructor.unbind "hovered", @updateHovered

  updateSelection: (records)=>
    console.log "Selection updated",records
    @setState selection: records

    # This is quite a hack
    window.map.invalidateSize()

  updateHovered: (d)=>
    @setState hovered: d, records: @props.data.records

  onResizePane: (size)->
    console.log size

module.exports = AttitudePage

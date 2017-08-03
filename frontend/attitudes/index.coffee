Spine = require "spine"
React = require 'react'
ReactDOM = require 'react-dom'
MapControl = require "../controls/map"
SelectionControl = require "../controls/selection"
DataPane = require "./data-pane"
h = require 'react-hyperscript'
SplitPane = require 'react-split-pane'

d3 = require "d3"
$ = require "jquery"

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

    {records} = @props.data
    if not records?
      records = []

    h SplitPane, {
      split: "vertical"
      minSize: 300
      primary: "second"
      paneStyle
      pane2Style: s
      onChange: @onResizePane
    },[
      h MapControl, {settings: @props.settings.map, records}
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
    @props.data.constructor.bind "updated", @updateData.bind(this)
    @props.data.constructor.bind "feature-types", (types)=>
      @setState featureTypes: types

  updateData: ->
    { records, selection } = @props.data
    @setState {records, selection}

  componentWillUnmount: ->
    @props.data.constructor.unbind "hovered", @updateHovered

  onResizePane: (size)->
    console.log size

module.exports = AttitudePage

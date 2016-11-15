Spine = require "spine"
React = require 'react'
ReactDOM = require 'react-dom'
Map = require "../../controls/map"
SelectionControl = require "../../controls/selection"
DataPanel = require "../../controls/data-panel"
InfoBox = require "../../controls/info-box"

SplitPane = require 'react-split-pane'

d3 = require "d3"
$ = require "jquery"

style = require '../styles.styl'
style2 = require './style.styl'
FilterData = require "../../controls/filter-data"

f = d3.format "> 6.1f"

class MapControl extends React.Component
  render: ->
    React.createElement 'div'
  componentDidMount: ->
    el = ReactDOM.findDOMNode @
    @map = new Map el: el
    @map.addData @props.data
    console.log "Component mounted"
  componentWillUnmount: ->
    @map.leaflet.remove()
  shouldComponentUpdate: ->false

paneStyle =
  display: 'flex'
  'flex-direction': 'column'

class AttitudePage extends React.Component
  constructor: (props)->
    super props
    @state =
      selection: []

  render: ->
    s = null
    if @state.selection.length == 0
      s = display: 'none'

    <SplitPane
      split="vertical"
      minSize={300}
      primary="second"
      paneStyle={paneStyle}
      pane2Style={s}>
      <MapControl data={@props.data} />
      <SelectionControl data={@props.data} records={@props.selection}/>
    </SplitPane>

  # The below is a shim but it'll work for now
  componentDidMount: ->
    @props.data.selection.bind "selection:updated", @updateSelection

  componentWillUnmount: ->
    @props.data.selection.unbind "selection:updated", @updateSelection

  updateSelection: =>
    @setState selection: @props.data.selection.records

    # This is quite a hack
    window.map.invalidateSize()

  onResizePane: ->

module.exports = AttitudePage

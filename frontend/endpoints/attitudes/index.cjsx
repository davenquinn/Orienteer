Spine = require "spine"
React = require 'react'
ReactDOM = require 'react-dom'
Map = require "../../controls/map"
SelectionControl = require "../../controls/selection"
DataPane = require "./data-pane"

SplitPane = require 'react-split-pane'

d3 = require "d3"
$ = require "jquery"

style2 = require '../styles.styl'
style = require './style.styl'
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
  flexDirection: 'column'

class AttitudePage extends React.Component
  constructor: (props)->
    super props
    @state =
      selection: []
      hovered: null

  render: ->
    s = null
    if @state.selection.length == 0
      s = display: 'none'
    else
      s = overflowY: 'scroll'

    <SplitPane
      split="vertical"
      minSize={300}
      primary="second"
      paneStyle={paneStyle}
      pane2Style={s}
      onChange={@onResizePane}>
      <MapControl data={@props.data} />
      <div className={style.sidebar} >
        <div className={style.sidebarComponent}>
          <SelectionControl data={@props.data}
              records={@state.selection}
              hovered={@state.hovered} />
        </div>
        <DataPane
          records={@state.selection}
          hovered={@state.hovered} />
      </div>
    </SplitPane>

  # The below is a shim but it'll work for now
  componentDidMount: ->
    @props.data.selection.bind "selection:updated", @updateSelection
    @props.data.constructor.bind "hovered", @updateHovered

  componentWillUnmount: ->
    @props.data.selection.unbind "selection:updated", @updateSelection
    @props.data.constructor.unbind "hovered", @updateHovered

  updateSelection: =>
    @setState selection: @props.data.selection.records

    # This is quite a hack
    window.map.invalidateSize()

  updateHovered: (d)=>
    @setState hovered: d

  onResizePane: (size)->
    console.log size

module.exports = AttitudePage

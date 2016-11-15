Spine = require "spine"
React = require 'react'
ReactDOM = require 'react-dom'
Map = require "../../controls/map"
SelectionControl = require "../../controls/selection"
DataPanel = require "../../controls/data-panel"
TagManager = require "../../controls/tag-manager"

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
  flexDirection: 'column'

class AttitudePage extends React.Component
  constructor: (props)->
    super props
    @state =
      selection: []

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
      pane2Style={s}>
      <MapControl data={@props.data} />
      <div>
        <SelectionControl data={@props.data} records={@state.selection}/>
        <div>
          <TagManager />
        </div>
      </div>
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

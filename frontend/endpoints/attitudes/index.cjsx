Spine = require "spine"
React = require 'react'
ReactDOM = require 'react-dom'
MapControl = require "../../controls/map"
SelectionControl = require "../../controls/selection"
DataPane = require "./data-pane"

SplitPane = require 'react-split-pane'

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
      <MapControl
        records={@state.records}
        selection={@state.selection}
        hovered={@state.hovered} />
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
    @props.data.constructor.bind "updated", @updateData

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

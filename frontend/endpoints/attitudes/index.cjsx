Spine = require "spine"
React = require 'react'
ReactDOM = require 'react-dom'
Map = require "../../controls/map"
SelectionControl = require "../../controls/selection"
DataPanel = require "../../controls/data-panel"
InfoBox = require "../../controls/info-box"
template = require "./template.html"
infoTemplate = require "./info-box.html"

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

class AttitudePage extends React.Component
  constructor: (props)->
    super props
  render: ->
    <SplitPane
      split="vertical"
      size={-200}
      enableResizing={false}
      primary="second">
      <MapControl data={@props.data} />
      <SelectionControl data={@props.data} />
    </SplitPane>

  onResizePane: ->

module.exports = AttitudePage

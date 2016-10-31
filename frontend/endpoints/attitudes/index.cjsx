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

styles = require '../styles.styl'
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
    <SplitPane split="vertical" defaultSize={200} primary="first">
      <MapControl data={@props.data} />
    </SplitPane>

module.exports = AttitudePage

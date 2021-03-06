React = require 'react'
ReactDOM = require 'react-dom'
Dimensions = require 'react-dimensions'
d3 = require 'd3'
require 'd3-selection-multi'
{functions,math} = require 'attitude'
{planes,ellipses} = require './types'
style = require './main.styl'
h = require 'react-hyperscript'

proj = d3.geoOrthographic()
  .clipAngle 90
  .precision 0.1
  .rotate [0,-90]

path = d3.geoPath()
  .projection proj

class StereonetView extends React.Component
  @defaultProps:
    width: 500
  render: ->
    h 'svg', className: style.container
  componentDidMount: ->

    el = ReactDOM.findDOMNode @
    @svg = d3.select el

    @updateSize()
    # Setup basic element
    @container = @svg
      .append 'g'
        .attr 'class', 'orientation'
        .attr 'fill', 'white'

    @container.append "defs"
      .append "path"
        .datum({type: "Sphere"})
        .attrs
          d: path
          id: "sphere"

    @container.append "use"
      .attrs
        class: style.background
        "xlink:href": "#sphere"

    grat = d3.geoGraticule()
    @container.append 'path'
      .datum grat
      .attrs class: style.graticule

    @main = @container.append 'g'
    @hoverOverlay = @container.append 'g'
      .attrs class: 'hover-overlay'

    @container.append "use"
      .attrs
        class: style.neatline
        "xlink:href": "#sphere"

    @updatePaths()

    # Add dragging for debug purposes
    drag = d3.drag()
      .on 'drag', =>
        proj.rotate [-d3.event.x, -d3.event.y]
        @updatePaths()
    @container.call drag

  componentDidUpdate: (prevProps,prevState)->
    console.log prevProps, @props
    if prevProps.data != @props.data
      # This is currently broken
      @dataChanged()
    if prevProps.width != @props.width
      console.log "Scale was changed"
      @updateSize()
    else if prevProps.hovered != @props.hovered
      @updateHovered()

    @updatePaths()

  updateHovered: ->
    v = @props.hovered
    hovered = if v? then [v] else []

    @hoverOverlay.call planes, hovered
    @hoverOverlay.call ellipses, hovered

  dataChanged: ->
    @main.call planes, @props.data
    @main.call ellipses, @props.data

  updateSize: ->
    @svg.attrs height: @props.width, width: @props.width
    proj
      .scale @props.width/2-20
      .translate [@props.width/2, @props.width/2]

  updatePaths: ->
    @container.selectAll 'path'
      .attrs d: path

module.exports = StereonetView


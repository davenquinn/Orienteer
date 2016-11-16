React = require 'react'
ReactDOM = require 'react-dom'
Dimensions = require 'react-dimensions'
d3 = require 'd3'
require 'd3-selection-multi'
{functions,math} = require 'attitude'
{planes,ellipses} = require './types'
style = require './main.styl'

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
    <svg />
  componentDidMount: ->

    el = ReactDOM.findDOMNode @
    svg = d3.select el
      .attrs height: @props.width, width: @props.width

    proj
      .scale @props.width/2-20
      .translate [@props.width/2, @props.width/2]

    # Setup basic element
    @container = svg.append 'g'
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

    @container.append "use"
      .attrs
        class: style.neatline
        "xlink:href": "#sphere"

    @updatePaths()

    # Add dragging for debug purposes
    drag = d3.drag()
      .on 'drag', =>
        proj.rotate [d3.event.x, -d3.event.y]
        @updatePaths()
    @container.call drag

  componentDidUpdate: (prevProps,prevState)->
    console.log prevProps, @props
    if prevProps.data.length != @props.data.length
      console.log "Data was changed"
    @dataChanged()
    @updatePaths()

  dataChanged: =>
    data = @props.data.map (d)->d.properties
    @main.call planes, data
    @main.call ellipses, data

  updatePaths: =>
    @container.selectAll 'path'
      .attrs d: path

module.exports = StereonetView


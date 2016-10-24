React = require 'react'
ReactDOM = require 'react-dom'
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

stereonet = (el, data)->

  g = el.append 'g'
    .attr 'class', 'orientation'
    .attr 'fill', 'white'

  g.append "defs"
    .append "path"
      .datum({type: "Sphere"})
      .attrs
        d: path
        id: "sphere"

  grat = d3.geoGraticule()

  g.append "use"
    .attrs
      class: style.background
      "xlink:href": "#sphere"

  g.append 'path'
    .datum grat
    .attrs
      class: style.graticule
      d: path

  g.call planes, data
  g.call ellipses, data

  g.append "use"
    .attrs
      class: style.neatline
      "xlink:href": "#sphere"

  # Finally, draw all the paths at once
  g.selectAll 'path'
    .attrs d: path

  # Add dragging for debug purposes
  drag = d3.drag()
    .on 'drag', =>
      proj.rotate [d3.event.x, -d3.event.y]
      g.selectAll('path').attrs d: path
  g.call drag

class StereonetView extends React.Component
  render: ->
    <svg />
  componentDidMount: ->
    data = @props.data.map (d)->d.properties

    el = ReactDOM.findDOMNode @
    svg = d3.select el
      .attrs height: 800, width: 800
      .call stereonet, data
  componentDidUpdate: ->

module.exports = StereonetView


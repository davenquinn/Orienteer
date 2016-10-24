React = require 'react'
ReactFauxDOM = require 'react-faux-dom'
d3 = require 'd3'
require 'd3-selection-multi'
{functions,math} = require 'attitude'
{planes,ellipses} = require './types'
style = require './main.styl'

class StereonetView extends React.Component
  ###
  A mutable component wrapping a d3.js view
  that holds a stereonet
  ###
  constructor: ->
    @state =
      center: [0,-90]

  render: ->

    proj = d3.geoOrthographic()
      .clipAngle 90
      .precision 0.1
      .rotate @state.center

    path = d3.geoPath()
      .projection proj

    console.log "Rendering stereonet"
    data = @props.data.map (d)->d.properties
    el = ReactFauxDOM.createElement('svg')
    svg = d3.select el
      .attrs height: 800, width: 800

    g = svg.append 'g'
      .attr 'class', 'orientation'
      .attr 'fill', 'white'

    g.append "defs"
      .append "path"
        .datum({type: "Sphere"})
        .attrs
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
        console.log "Drag"
        console.log d3.event
        e = d3.event.sourceEvent
        @rotateProjection [e.x,e.y]
    g.call drag

    svg.node().toReact()

  rotateProjection: (c)=>
    c0 = @state.center
    center = [c0[0]+c[0],c0[0]-c[0]]
    @setState center: center

module.exports = StereonetView


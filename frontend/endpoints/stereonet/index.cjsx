React = require 'react'
ReactDOM = require 'react-dom'
{Link} = require 'react-router'
d3 = require 'd3'
require 'd3-selection-multi'
style = require './main.styl'
stereonet = require './control'

class StereonetPage extends React.Component
  render: ->
    <div>
      <Link className={style.homeLink} to="/">
        <i className='fa fa-home' />
      </Link>
      <svg />
    </div>
  componentDidMount: ->
    data = @props.data
      .records()
      .map (d)->d.properties

    el = ReactDOM.findDOMNode @
    svg = d3.select el
      .select "svg"
      .attrs height: 800, width: 800
      .call stereonet, data

module.exports = StereonetPage


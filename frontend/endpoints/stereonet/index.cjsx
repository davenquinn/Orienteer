React = require 'react'
ReactDOM = require 'react-dom'
{Link} = require 'react-router'
d3 = require 'd3'
require 'd3-selection-multi'
style = require './main.styl'

class StereonetPage extends React.Component
  render: ->
    <div>
      <Link className={style.homeLink} to="/">
        <i className='fa fa-home' />
      </Link>
    </div>
  componentDidMount: ->
    el = ReactDOM.findDOMNode @
    svg = d3.select el

module.exports = StereonetPage


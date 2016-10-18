React = require 'react'
ReactDOM = require 'react-dom'
Infinite = require 'react-infinite'
{Link} = require 'react-router'
d3 = require 'd3'
require 'd3-selection-multi'
style = require './main.styl'
stereonet = require './control'

class AttitudeList extends React.Component
  __renderChild: (d,i)=>
    <div>{d.id} ({i} of {@props.data.length})</div>
  render: ->
    <div>
      <h1>Attitudes</h1>
      <Infinite
        className={style.list}
        containerHeight={500}
        elementHeight={20}>
        {@props.data.map @__renderChild}
      </Infinite>
    </div>

class StereonetView extends React.Component
  render: ->
    <svg />
  componentDidMount: ->
    data = @props.data.map (d)->d.properties

    el = ReactDOM.findDOMNode @
    svg = d3.select el
      .select "svg"
      .attrs height: 800, width: 800
      .call stereonet, data

class StereonetPage extends React.Component
  render: ->
    <div className={style.wrap}>
      <div className={style.sidebar}>
        <Link className={style.homeLink} to="/">
          <i className='fa fa-home' /> Home
        </Link>
        <AttitudeList data={@props.data.records()} />
      </div>
      <div className={style.main}>
        <StereonetView data={@props.data.selection.records} />
      </div>
    </div>

module.exports = StereonetPage


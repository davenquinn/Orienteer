Spine = require "spine"
React = require 'react'
ReactDOM = require 'react-dom'
{Dragdealer} = require "dragdealer"
style = require './style'

int = (v) -> if v then 1 else 0

class Toggle extends React.Component
  @defaultProps:
    values: [false,true]
    labels: ["Disabled","Enabled"]
    enabled: false
    onChange: ->
  render: ->
    i = int(@props.enabled)
    <div className={"#{style.toggle} dragdealer"}>
      <div className='red-bar handle'>{@props.labels[i]}</div>
    </div>
  componentDidMount: ->
    el = ReactDOM.findDOMNode @
    @slider = new Dragdealer el,
      x: int @props.enabled
      steps: 2
      callback: (x)=>
        return if int(@props.enabled) == x
        enabled = if x == 1 then true else false
        @props.onChange @props.values[int(@props.enabled)]
    console.log @slider

module.exports = Toggle

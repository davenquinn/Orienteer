React = require 'react'
ReactDOM = require 'react-dom'

class MainPanel extends ReactComponent
  constructor: (props)->
    super props

  render: ->
    <div id="stereonet" />

  componentDidMount: ->
    @svg d3.select ReactDOM.findDOMNode(@)


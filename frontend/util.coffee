React = require 'react'
ReactDOM = require 'react-dom'

reactifySpine = (cls, options)->
  # Wrap Spine controller in React component
  class SpineWrapper extends React.Component
    constructor: (@props)->
      super @props
    render: ->
      React.createElement "div"
    componentDidMount: ->
      options.el = ReactDOM.findDOMNode @
      @component = new cls options
    componentWillUnmount: ->
    shouldComponentUpdate: ->false

module.exports =
  reactifySpine: reactifySpine

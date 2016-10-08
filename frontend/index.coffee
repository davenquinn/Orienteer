$ = require "jquery"
window.jQuery = $
window.$ = $
require "velocity-animate"
React = require 'react'
ReactDOM = require 'react-dom'

window.server_url = "http://0.0.0.0:8000"

Spine = require "spine"
Spine.jQuery = $
require "spine/lib/route"
App = require "./app"
setupMenu = require "./menu"

class UI extends React.Component
  render: ->
    React.createElement "div"
  componentDidMount: ->
    el = ReactDOM.findDOMNode @
    app = new App el: el
    setupMenu(app)
  shouldComponentUpdate: ->false

el = React.createElement UI
ReactDOM.render el, document.getElementById 'wrapper'



Spine.Route.setup()

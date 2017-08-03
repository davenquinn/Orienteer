$ = require "jquery"
window.jQuery = $
window.$ = $
require "velocity-animate"

window.server_url = "http://0.0.0.0:8000"

Spine = require "spine"
Spine.jQuery = $

React = require 'react'
ReactDOM = require 'react-dom'
{HashRouter,Route,Link} = require 'react-router-dom'
h = require 'react-hyperscript'
{remote} = require 'electron'

{reactifySpine} = require './util'
setupMenu = require './menu'
Map = require "./controls/map"
Frontpage = require "./frontpage"
Data = require "./data"
AttitudePage = require "./attitudes"
Stereonet = require "./endpoints/stereonet"
update = require 'immutability-helper'

styles = require './styles/layout.styl'

erf = (request, textStatus, errorThrown)->
  console.log request, textStatus, errorThrown

class App extends React.Component
  constructor: ->
    super()
    window.app = @
    @API = require "./api"
    @opts = require "./options"
    @state = remote.app.state

    # Share config from main process
    # Config can't be edited at runtime
    c = remote.app.config
    @config = JSON.parse(JSON.stringify(c))
    @state.data = new Data

    @data = @state.data

    @state.settings ?= {}

    @state.settings.map ?= {bounds: null}

  require: (m)->
    ## App-scoped require to preclude nesting
    require "./#{m}"

  updateSettings: (spec)->
    newState = update(@state.settings, spec)
    @setState settings: newState

  render: ->
    {settings, data} = @state

    class DataStereonet extends React.Component
      render: -> h Stereonet, {settings, data}

    class Attitude extends React.Component
      render: -> h AttitudePage, {settings, data}

    h "div#root", [
      h Route, path: "/", component: Frontpage, exact: true
      h Route, path:"/map", component: Attitude
      h Route, path: "/stereonet", component: DataStereonet
    ]

Router = -> h HashRouter, [ h App ]

ReactDOM.render(React.createElement(Router), document.getElementById 'wrapper')


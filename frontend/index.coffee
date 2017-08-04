$ = require "jquery"

window.server_url = "http://0.0.0.0:8000"

React = require 'react'
ReactDOM = require 'react-dom'
{HashRouter,Route,Link} = require 'react-router-dom'
h = require 'react-hyperscript'
{remote} = require 'electron'

setupMenu = require './menu'
Map = require "./controls/map"
Frontpage = require "./frontpage"
Data = require "./data-manager"
AttitudePage = require "./attitudes"
Stereonet = require "./endpoints/stereonet"
LogHandler = require "./log-handler"
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

    @defaultSubquery = """
                          SELECT *
                          FROM attitude_data
                          WHERE true
                       """
    query = @defaultSubquery

    {state} = remote.app
    @state = {
      query
      featureTypes: []
      records: []
      state...}

    @log = new LogHandler

    # Share config from main process
    # Config can't be edited at runtime
    c = remote.app.config
    @config = JSON.parse(JSON.stringify(c))
    @data = new Data logger: @log, onUpdated: @updateData.bind(@)
    @data.getData()

    @state.settings ?= {}

    @state.settings.map ?= {bounds: null}

  runQuery: (query)->
    @setState query: query
    @data.getData query

  require: (m)->
    ## App-scoped require to preclude nesting
    require "./#{m}"

  updateData: (changes)->
    @setState changes

  updateSettings: (spec)->
    newState = update(@state.settings, spec)
    @setState settings: newState

  render: ->
    {settings, records, query, featureTypes} = @state
    console.log "Re-rendering app with state", @state

    class DataStereonet extends React.Component
      render: -> h Stereonet, {settings, records}

    attitude = -> h AttitudePage, {settings, records, query, featureTypes}

    h "div#root", [
      h Route, path: "/", component: Frontpage, exact: true
      h Route, path:"/map", render: attitude
      h Route, path: "/stereonet", component: DataStereonet
    ]

Router = -> h HashRouter, [ h App ]

ReactDOM.render(React.createElement(Router), document.getElementById 'wrapper')


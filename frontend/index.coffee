$ = require "jquery"

window.server_url = "http://0.0.0.0:8000"

h = require 'react-hyperscript'
React = require 'react'
ReactDOM = require 'react-dom'
{HashRouter,Route,Link} = require 'react-router-dom'
{remote} = require 'electron'
{FocusStyleManager} = require '@blueprintjs/core'
setupMenu = require './menu'
Map = require "./controls/map"
Frontpage = require "./frontpage"
Data = require "./data-manager"
AttitudePage = require "./attitudes"
Stereonet = require "./endpoints/stereonet"
LogHandler = require "./log-handler"
update = require 'immutability-helper'
yaml = require 'js-yaml'
{readFileSync} = require 'fs'
styles = require './styles/layout.styl'
{remote} = require 'electron'

FocusStyleManager.onlyShowFocusOnTabs()

class App extends React.Component
  constructor: ->
    super()
    window.app = @
    @API = require "./api"
    @opts = require "./options"

    @config = remote.getGlobal('config')

    _ = readFileSync "#{__dirname}/sql/stored-filters.yaml", 'utf8'
    @subqueryIndex = yaml.load _

    query = @subqueryIndex[0].sql

    {state} = remote.app
    @state = {
      query
      featureTypes: []
      showSidebar: false
      records: []
      state...}

    setupMenu(@)

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
    return if query == @state.query
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

  toggleSidebar: ->
    @setState showSidebar: not @state.showSidebar

  render: ->
    {settings, records, query, featureTypes, showSidebar} = @state
    console.log "Re-rendering app with state", @state

    class DataStereonet extends React.Component
      render: -> h Stereonet, {settings, records}

    attitude = -> h AttitudePage, {settings, records, query, featureTypes, showSidebar}
    # The other pages of the app don't work right now
    return attitude()

    h "div#root", [
      h Route, path: "/", component: Frontpage, exact: true
      h Route, path:"/map", render: attitude
      h Route, path: "/stereonet", component: DataStereonet
    ]

Router = -> h HashRouter, [ h App ]

ReactDOM.render(React.createElement(Router), document.getElementById 'wrapper')


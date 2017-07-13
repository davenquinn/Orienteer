$ = require "jquery"
React = require 'react'
ReactDOM = require 'react-dom'
{createHistory, useBasename} = require 'history'
{Router, Route, IndexRoute, hashHistory} = require 'react-router'
{remote} = require 'electron'
{reactifySpine} = require '../util'
setupMenu = require '../menu'
Map = require "../controls/map"
Frontpage = require "./frontpage"
Data = require "./data"
AttitudePage = require "../endpoints/attitudes"
Stereonet = require "../endpoints/stereonet"
h = require 'react-hyperscript'

styles = require '../styles/layout.styl'

erf = (request, textStatus, errorThrown)->
  console.log request, textStatus, errorThrown

class App
  constructor: ->
    window.app = @
    @API = require "./api"
    @opts = require "./options"
    @state = remote.app.state

    # Share config from main process
    # Config can't be edited at runtime
    c = remote.app.config
    @config = JSON.parse(JSON.stringify(c))
    @data = new Data

  require: (m)->
    ## App-scoped require to preclude nesting
    require "./#{m}"

  toggleData: ->
    return

module.exports = ->
  app = new App
  #setupMenu(app)

  class DataStereonet extends React.Component
    render: -> h Stereonet, data: app.data

  class Attitude extends React.Component
    render: -> h AttitudePage, data: app.data

  router = h Router, history: hashHistory, [
      h Route, path: "/", [
        h IndexRoute, component: Frontpage
        h Route, path:"map", component: Attitude
        h Route, path: "stereonet", component: DataStereonet
      ]
    ]

  ReactDOM.render(router, document.getElementById 'wrapper')


$ = require "jquery"
Spine = require "spine"
React = require 'react'
ReactDOM = require 'react-dom'
{createHistory, useBasename} = require 'history'
{Router, Route, hashHistory} = require 'react-router'
{remote} = require "electron"
setupMenu = require "../menu"

Frontpage = require "./frontpage.cjsx"

Map = require "../controls/map"

Data = require "./data"
AttitudePage = require "../endpoints/attitudes"
NotesPage = require "../endpoints/notes"
EditorPage = require "../endpoints/edit"

styles = require '../styles/layout.styl'

erf = (request, textStatus, errorThrown)->
  console.log request, textStatus, errorThrown

class App extends Spine.Controller
  constructor: ->
    super
    window.app = @
    @API = require "./api"
    @opts = require "./options"
    @state = remote.app.state
    @query = require('./database')

    # Share config from main process
    # Config can't be edited at runtime
    c = remote.app.config
    @config = JSON.parse(JSON.stringify(c))

    @routes =
      "editor": =>
        @setupData(@editor)
      "attitudes": =>
        @setupData(@attitudes)

    @log "Created app"

    p = @state.page or 'attitudes'
    @routes[p]()

  setupData: (callback)=>
    @log "Getting data"
    if not @data?
      @data = new Data
    if callback?
      callback @data

  map: (data)=>
    @log "Setting up map"
    @map = new Map
      el: $("#main")
      parent: @
    @map.el.height $(window).height()
    @map.addData @data

  attitudes: (data) =>
    @log "Setting up attitudes"
    @__setPage AttitudePage, data: @data

  editor: (data) =>
    @log "Setting up editor"
    @__setPage EditorPage, data: @data

  __setPage: (pageclass, options={})=>
    options.el = $('<div id="main" />').appendTo @el
    @page = new pageclass(options)

class UI extends React.Component
  render: ->
    React.createElement "div"
  componentDidMount: ->
    el = ReactDOM.findDOMNode @
    @app = new App el: el
    setupMenu(app)
  componentWillUnmount: ->
  shouldComponentUpdate: ->false

module.exports = ->

  ReactDOM.render(
    <Router history={hashHistory}>
      <Route path="/" component={Frontpage} />
      <Route path="map" component={UI}/>
    </Router>, document.getElementById 'wrapper')


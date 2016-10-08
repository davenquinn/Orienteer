$ = require "jquery"
Spine = require "spine"
React = require 'react'
ReactDOM = require 'react-dom'
{createHistory, useBasename} = require 'history'
{Router, Route, IndexRoute, hashHistory} = require 'react-router'
{remote} = require "electron"
setupMenu = require "../menu"

Frontpage = require "./frontpage"

Map = require "../controls/map"

Data = require "./data"
AttitudePage = require "../endpoints/attitudes"
Stereonet = require "../endpoints/stereonet"
NotesPage = require "../endpoints/notes"
EditorPage = require "../endpoints/edit"

styles = require '../styles/layout.styl'

erf = (request, textStatus, errorThrown)->
  console.log request, textStatus, errorThrown

class App
  constructor: ->
    window.app = @
    @API = require "./api"
    @opts = require "./options"
    @state = remote.app.state
    @query = require('./database')

    # Share config from main process
    # Config can't be edited at runtime
    c = remote.app.config
    @config = JSON.parse(JSON.stringify(c))

    @setupData()
    @routes =
      "editor": =>
        @setupData(@editor)
      "attitudes": =>
        @setupData(@attitudes)


  setupData: (callback)=>
    if not @data?
      @data = new Data
    if callback?
      callback @data

  map: (data)=>
    @map = new Map
      el: $("#main")
      parent: @
    @map.el.height $(window).height()
    @map.addData @data

  attitudes: (data) =>
    @__setPage AttitudePage, data: @data

  editor: (data) =>
    @__setPage EditorPage, data: @data

  __setPage: (pageclass, options={})=>
    options.el = $('<div id="main" />').appendTo @el
    @page = new pageclass(options)

class UI extends React.Component
  render: ->
    React.createElement "div"

class Attitude extends React.Component
  constructor: (props)->
    super props
  render: ->
    React.createElement "div"
  componentDidMount: ->
    el = ReactDOM.findDOMNode @
    @app = new AttitudePage el: el, data: @props.data
  componentWillUnmount: ->
  shouldComponentUpdate: ->false

module.exports = ->
  app = new App
  setupMenu(app)

  class DataAttitude extends React.Component
    render: -> <Attitude data={app.data} />

  class DataStereonet extends React.Component
    render: -> <Stereonet data={app.data} />

  ReactDOM.render(
    <Router history={hashHistory}>
      <Route path="/">
        <IndexRoute component={Frontpage} />
        <Route path="map" component={DataAttitude}/>
        <Route path="stereonet" component={DataStereonet}/>
      </Route>
    </Router>, document.getElementById 'wrapper')


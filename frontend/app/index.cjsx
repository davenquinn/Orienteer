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
    @data = new Data

reactifySpine = (cls, options)->
  class SpineWrapper extends React.Component
    constructor: (props)->
      super props
    render: ->
      React.createElement "div"
    componentDidMount: ->
      options.el = ReactDOM.findDOMNode @
      @component = new cls options
    componentWillUnmount: ->
    shouldComponentUpdate: ->false

module.exports = ->
  app = new App
  setupMenu(app)

  class DataStereonet extends React.Component
    render: -> <Stereonet data={app.data} />
  Attitude = reactifySpine AttitudePage, data: app.data


  ReactDOM.render(
    <Router history={hashHistory}>
      <Route path="/">
        <IndexRoute component={Frontpage} />
        <Route path="map" component={Attitude}/>
        <Route path="stereonet" component={DataStereonet}/>
      </Route>
    </Router>, document.getElementById 'wrapper')


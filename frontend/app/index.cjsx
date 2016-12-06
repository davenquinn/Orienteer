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
    render: -> <Stereonet data={app.data} />

  class Attitude extends React.Component
    render: -> <AttitudePage data={app.data} />

  ReactDOM.render(
    <Router history={hashHistory}>
      <Route path="/">
        <IndexRoute component={Frontpage} />
        <Route path="map" component={Attitude}/>
        <Route path="stereonet" component={DataStereonet}/>
      </Route>
    </Router>, document.getElementById 'wrapper')


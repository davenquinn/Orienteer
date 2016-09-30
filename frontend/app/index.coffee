$ = require "jquery"
Spine = require "spine"
Map = require "../controls/map"
Data = require "./data"
AttitudePage = require "../endpoints/attitudes"
NotesPage = require "../endpoints/notes"
EditorPage = require "../endpoints/edit"

{remote} = require "electron"

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

  toggleEditor: =>
    e = @state.page == 'editor'
    @state.page = if e then 'attitudes' else 'editor'
    console.log @state.page
    remote.getCurrentWindow().reload()
module.exports = App

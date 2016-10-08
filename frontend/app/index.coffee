$ = require "jquery"
Spine = require "spine"
Map = require "../controls/map"
Data = require "./data"
AttitudePage = require "../endpoints/attitudes"
NotesPage = require "../endpoints/notes"
EditorPage = require "../endpoints/edit"
template = require "./frontpage.html"

{remote} = require "electron"

styles = require '../styles/layout.styl'

erf = (request, textStatus, errorThrown)->
  console.log request, textStatus, errorThrown

class IndexPage
  constructor: (opts)->
    @el = opts.el
    @el.html template(opts)

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
      "index": =>
        @setupData(@index)

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

  index: (data)=>
    @log "Setting up index"
    o = @config.projectName or "Orientations"
    @__setPage IndexPage, {project:o}

  __setPage: (pageclass, options={})=>
    options.el = $('<div id="main" />').appendTo @el
    @page = new pageclass(options)

  setHomepage: =>
    @state.page = 'index'
    remote.getCurrentWindow().reload()
module.exports = App

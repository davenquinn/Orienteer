$ = require "jquery"
Spine = require "spine"
Map = require "../controls/map"
Data = require "./data"
AttitudePage = require "../endpoints/attitudes"
NotesPage = require "../endpoints/notes"

remote = require "remote"

erf = (request, textStatus, errorThrown)->
  console.log request, textStatus, errorThrown

class App extends Spine.Controller
  constructor: ->
    super
    window.app = @
    @API = require "./api"
    @opts = require "./options"

    # Share config from main process
    # Config can't be edited at runtime
    c = remote.require("app").config
    @config = JSON.parse(JSON.stringify(c))

    if @routes?
      @routes
        "/map/": => @setupData @map
        "": => @setupData @attitudes
        "/notes/": @notes
    @log "Created app"
    @navigate ""

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
    @page = new AttitudePage
      el: $("#main")
      data: @data

  notes: =>
    @page = new NotesPage
      el: $("#main")

module.exports = App

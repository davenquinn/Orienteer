Spine = require "spine"
d3 = require "d3"
template = require "./template.html"

Map = require "../../controls/map"

class NotesPage extends Spine.Controller
  constructor: ->
    super
    @el.html template

    @map = new Map
      el: @$ ".map"

module.exports = NotesPage

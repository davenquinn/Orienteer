$ = require "jquery"
d3 = require "d3"
Spine = require "spine"
template = require "./tag-manager.html"

class TagManager extends Spine.Controller
  events:
    "submit form": "submit"
    "keypress input": "onKeypress"
  constructor: ->
    super
    throw "@selection required" unless @selection?

    @el.html template
    @ul = d3.select(@el[0]).select("ul")
    @tags = []
    @updateFromSelection()

  update: (tags)=>

    tags = @tags unless tags?

    if typeof tags[0] is 'string'
      # We've got a list of items that
      # don't have data on all/some status
      # In this case we assume that they
      # are present for all items.
      tags = tags.map (d)->
        {name: d, all: true}

    li = @ul.selectAll("li")
      .data tags, (d)->d.name

    li.exit().remove()
    li.enter()
      .append("li")
        .text (d) -> d.name
        .append "span"
          .html "<i class='fa fa-remove'></i>"
          .attr "class", "remove"
          .on "click", @removeTag

    li.attr "class", (d) -> if d.all then "all" else "some"

  updateFromSelection: (d)=>
    if @selection.empty() and d?
      tags = d.tags
    else
      tags = @selection.getTags()
    @update tags

  sanitizeInput: (text)-> text.toLowerCase()
      #.replace /[^\w-]+/g, '-'

  onKeypress: (e)->
    i = $(e.currentTarget)
    i.val @sanitizeInput i.val()

  removeTag: (d)=>
    @selection.removeTag d.name

  addTag: (name)->
    console.log "Adding tag",name
    @selection.addTag name

  submit: (e)->
    input = @$("form input")
    e.preventDefault()
    @addTag input.val()
    input.val ""

module.exports = TagManager

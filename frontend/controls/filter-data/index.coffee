Spine = require "spine"
d3 = require "d3"
template = require "./template.html"

states = [null,"all","none"]

allOther =
  name: "All other"
  status: null

cycleStatus = (d)->
  i = states.indexOf d.status
  i++
  i = 0 if i == states.length
  d.status = states[i]

names = (d)->d.name

class FilterData extends Spine.Controller
  events:
    "click button.clear": "clear"
  constructor: ->
    super
    throw "@data required" unless @data

    @mode = "all" # all or any

    @el.html template
    @_el = d3.select @el[0]

    @ul = @_el.append "ul"
      .attr "class", "tag-list"

    @listenTo @data.selection,
      "selection:tags-updated selection:updated",
      @buildList
    @buildInitial()

  buildInitial: =>
    data = @data.getTags()
    @tags = data.map (d)->
      bad = app.opts.badTags.indexOf(d) != -1
      out =
        name: d
        status: if bad then "none" else null

    @updateList()
    @update()

  buildList: =>
    data = @data.getTags()
    curr = @tags.map names
    for t in curr
      # if tag is removed
      if data.indexOf(t) == -1
        @tags.splice curr.indexOf(t),1

    for t in data
      # if tag is new
      if curr.indexOf(t) == -1
        @tags.push
          name: t
          status: null
    @updateList()

  updateList: =>
    @sel = @ul.selectAll "li"
      .data @tags, names
    @sel.enter()
      .append "li"
        .text names
        .on "click", (d)=>
          cycleStatus d
          @update()
    @sel.exit().remove()


  update: =>
    @sel.attr "class", (d)->d.status
    @data.updateFilter @tags
  clear: =>
    @tags.forEach (d)->d.status = null
    @update()




module.exports = FilterData

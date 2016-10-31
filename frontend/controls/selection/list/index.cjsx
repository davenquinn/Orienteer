Spine = require "spine"
$ = require "jquery"
d3 = require "d3"
React = require 'react'
style = require './style'

sf = d3.format ">8.1f"
df = d3.format ">6.1f"

class ListItem extends React.Component
  renderGroupData: ->
    d = @props.data
    n = if d.records? then d.records.length else 1
    <span className="group">{n} attitudes</span>
  render: ->
    d = @props.data
    strike = sf(d.properties.strike)
    dip = df(d.properties.dip)
    grouped = d.records?

    <li className="#{style.item}">
      <span className="remove">
        <i className='fa fa-remove'></i>
      </span>
      <span className="strike">{strike}º</span>
      <span className="dip">{dip}º</span>
      {@renderGroupData() if grouped}
    </li>

class SelectionList extends React.Component
  defaultProps:
    focusItem: ->
  constructor: (@props)->
    super @props

  update: =>
    @log "Updating selection list"
    @items = @ul.selectAll "li"
      .data @selection.visible(), (d)->d.id

    enter = @items.enter()
      .append "li"
        .html (d)->
          template
            strike: sf(d.properties.strike)
            dip: df(d.properties.dip)
            grouped: d.records?
            n: if d.records? then d.records.length else 1
        .on "mouseover", @data.hovered
        .on "mouseout", @data.hovered
        .on "click", @focusItem

    enter.select "span.remove"
      .on "click", @selection.update

    @items.exit().remove()

  focusItem: (d)=>
    # Make the item show in a separate viewer
    @trigger "focused", d

  viewGroup: (e)->
    node = e.currentTarget.parentNode
    target = d3.select node
    group =  target.data()[0]
    @trigger "group-selected", group

  renderItem: (d)->
    <ListItem hovered={d.hovered} data={d} key={d.id} />
  render: ->
    <ul className={style.list}>
      {@props.selection.map @renderItem}
    </ul>

module.exports = SelectionList

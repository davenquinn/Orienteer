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
      <span className="remove" onClick={@props.removeItem}>
        <i className='fa fa-remove'></i>
      </span>
      <span onClick={@props.focusItem}>
        <span className="strike">{strike}º</span>
        <span className="dip">{dip}º</span>
        {@renderGroupData() if grouped}
      </span>
    </li>

class SelectionList extends React.Component
  defaultProps:
    focusItem: ->
    removeItem: ->
  constructor: (@props)->
    super @props

  renderItem: (d)=>
    onRemove = =>@props.removeItem d
    onFocus = =>
      console.log d
      @props.focusItem d
    <ListItem
      hovered={d.hovered}
      data={d}
      key={d.id}
      focusItem={onFocus}
      removeItem={onRemove} />
  render: ->
    <ul className={style.list}>
      {@props.records.map @renderItem}
    </ul>

module.exports = SelectionList

Spine = require "spine"
$ = require "jquery"
d3 = require "d3"
React = require 'react'
style = require './style'

sf = d3.format ">8.1f"
df = d3.format ">6.1f"

class ListItem extends React.Component
  defaultProps:
    allowRemoval: false
  renderGroupData: ->
    d = @props.data
    n = if d.records? then d.records.length else 1
    <span className={style.group}>{n} attitudes</span>
  render: ->
    d = @props.data
    strike = sf(d.strike)
    dip = df(d.dip)
    grouped = d.records?

    cls = style.item
    if d.hovered
      cls += " #{style.hovered}"

    # This is crazy-inefficient
    <li className={cls}
      onMouseEnter={@mousein}>
      {@createRemoveButton() if @props.allowRemoval}
      <span onClick={@props.focusItem}>
        <span className={style.strike}>{strike}º</span>
        <span className={style.dip}>{dip}º</span>
        {@renderGroupData() if grouped}
      </span>
    </li>

  createRemoveButton: =>
    <span className="remove" onClick={@props.removeItem}>
      <i className='fa fa-remove'></i>
    </span>

  isHovered: =>
    app.data.isHovered @props.data
  # These handlers need some reworking
  # but can probably stand for now
  mousein: =>
    app.data.hovered @props.data, true
  mouseout: =>
    app.data.hovered @props.data, false

class SelectionList extends React.Component
  defaultProps:
    focusItem: ->
    removeItem: ->
    allowRemoval: false
  constructor: (@props)->
    super @props

  renderItem: (d)=>
    onRemove = =>@props.removeItem d
    onFocus = =>
      @props.focusItem d

    h = false
    if @props.hovered?
      h = d.id == @props.hovered.id
    <ListItem
      data={d}
      key={d.id}
      focusItem={onFocus}
      removeItem={onRemove}
      allowRemoval={@props.allowRemoval} />
  render: ->
    <ul className={style.list}>
      {@props.records.map @renderItem}
    </ul>

module.exports = SelectionList

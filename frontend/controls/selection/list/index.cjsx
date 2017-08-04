Spine = require "spine"
$ = require "jquery"
d3 = require "d3"
React = require 'react'
style = require './style'
h = require 'react-hyperscript'

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
    <tr className={cls} onClick={@props.focusItem} onMouseEnter={@mousein}>
      {@createRemoveButton() if @props.allowRemoval}
      <td className={style.strike}>{strike}</td>
      <td className={style.dip}>{dip}</td>
      <td>{@renderGroupData() if grouped}</td>
    </tr>

  createRemoveButton: =>
    <td className="remove" onClick={@props.removeItem}>
      <i className='fa fa-remove'></i>
    </td>

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

  renderItem: (d)=>
    onRemove = (event)=>
      @props.removeItem d
      event.stopPropagation()
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
    <table className={"pt-table pt-striped pt-condensed #{style.list}"}>
      <thead>
        <tr>
          {<td></td> if @props.allowRemoval}
          <td>Strike</td>
          <td>Dip</td>
          <td>Info</td>
        </tr>
      </thead>
      <tbody>
        {@props.records.map @renderItem}
      </tbody>
    </table>

module.exports = SelectionList

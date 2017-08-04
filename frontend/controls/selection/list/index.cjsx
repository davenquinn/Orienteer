Spine = require "spine"
$ = require "jquery"
d3 = require "d3"
React = require 'react'
style = require './style'
h = require 'react-hyperscript'
{Tag} = require '@blueprintjs/core'

f = d3.format ">.1f"

class ListItem extends React.Component
  defaultProps:
    allowRemoval: false
  render: ->
    {strike, dip, grouped,max_angular_error,
     min_angular_error, hovered, measurements} = @props.data

    cls = style.item
    if hovered
      cls += " #{style.hovered}"

    # This is crazy-inefficient
    <tr className={cls} onClick={@props.focusItem} onMouseEnter={@mousein}>
      <td>{f(strike)}</td>
      <td>{f(dip)}</td>
      <td>{f(max_angular_error)}</td>
      <td>{f(min_angular_error)}</td>
      <td>{<Tag>{measurements.length} attitudes</Tag> if grouped}</td>
      {@createRemoveButton() if @props.allowRemoval}
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
          <td>Str</td>
          <td>Dip</td>
          <td colSpan="2">Errors (º)</td>
          <td>Info</td>
          {<td></td> if @props.allowRemoval}
        </tr>
      </thead>
      <tbody>
        {@props.records.map @renderItem}
      </tbody>
    </table>

module.exports = SelectionList

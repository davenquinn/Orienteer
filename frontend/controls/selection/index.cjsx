#GroupedDataControl = require "./grouped-data"
SelectionList = require "./list"
ViewerControl = require './viewer'
React = require 'react'
style = require './style'

class SelectionControl extends React.Component
  render: ->
    a = @props.actions
    <div className="#{style.selectionControl}">
      <h3>Selection</h3>
      <SelectionList
        records={@props.records}
        removeItem={a.removeItem}
        focusItem={a.focusItem} />
      <p>
        <button
          className="group btn btn-default btn-sm"
          onClick={a.createGroup}>Group measurements</button>
      </p>
    </div>

class CloseButton extends React.Component
  render: ->
    <button className="clear btn btn-danger btn-tiny" onClick={@props.action}>
      <i className={"fa fa-#{@props.icon}"}></i>{@props.text}
    </button>

class Sidebar extends React.Component
  defaultProps:
    records: []
  constructor: (@props)->
    super @props
    @state =
      focused: null
  render: ->
    rec = @props.records

    # Render nothing for empty selection
    if rec.length == 0
      return <div />

    # A selection management class
    s = @props.data.selection

    closeButton = <CloseButton action={s.clear} text="Clear selection" icon="remove" />
    if @state.focused?
      closeButton = <CloseButton action={@clearFocus} text="Back to selection" icon="chevron-left" />
      core = <ViewerControl data={@state.focused} />
    else if rec.length == 1
      core = <ViewerControl data={rec[0]} />
    else
      actions =
        removeItem: s.update
        focusItem: @focusItem
        createGroup: s.createGroup
      core = <SelectionControl
                records={rec}
                actions={actions} />

    <div className={"#{style.sidebar} flex flex-container"} >
      <div className="modal-controls">
        {closeButton}
      </div>
      {core}
    </div>

  focusItem: (d)=>
    @setState focused: d

  clearFocus: (d)=>
    @setState focused: null

module.exports = Sidebar

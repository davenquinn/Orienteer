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
        hovered={@props.hovered}
        removeItem={a.removeItem}
        focusItem={a.focusItem}
        allowRemoval={true} />
      <p>
        <button
          className="group pt-button pt-intent-primary pt-icon-group-objects"
          onClick={@createGroup}>Group measurements</button>
      </p>
    </div>

  createGroup: =>
    app.data.createGroup @props.records

class CloseButton extends React.Component
  render: ->
    <button className={"pt-button pt-intent-danger pt-icon-#{@props.icon}"} onClick={@props.action}>
      {@props.children}
    </button>

class Sidebar extends React.Component
  defaultProps:
    records: []
    hovered: null
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

    closeButton = <CloseButton action={s.clear} icon="cross">Clear selection</CloseButton>
    if @state.focused?
      closeButton = <CloseButton action={@clearFocus} icon="chevron-left">Back to selection</CloseButton>
      core = <ViewerControl data={@state.focused} hovered={@props.hovered} focusItem={@focusItem} />
    else if rec.length == 1
      core = <ViewerControl data={rec[0]} hovered={@props.hovered} focusItem={@focusItem} />
    else
      actions =
        removeItem: s.update
        focusItem: @focusItem
        createGroup: s.createGroup
      core = <SelectionControl
                records={rec}
                hovered={@props.hovered}
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

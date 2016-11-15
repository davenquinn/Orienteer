#GroupedDataControl = require "./grouped-data"
SelectionList = require "./list"
ViewerControl = require './viewer'
React = require 'react'
style = require './style'

class SelectionControl extends React.Component
  render: ->
    a = @props.actions
    <div className="#{style.selectionControl} flex flex-container">
      <h3>Selection</h3>
      <p className="modal-controls">
        <span className="clear" onClick={a.clear}>
           <i className="fa fa-remove"></i>
        </span>
      </p>
      <SelectionList
        records={@props.records}
        removeItem={a.removeItem}
        focusItem={a.focusItem} />
      <p>
        <button
          className="group btn btn-default btn-sm"
          onClick={@props.createGroup}>Group measurements</button>
      </p>
    </div>

class Sidebar extends React.Component
  constructor: (@props)->
    super @props
    @state =
      focused: null
  render: ->
    rec = @state.records
    # A selection management class
    s = @props.data.selection

    if @state.focused?
      core = <ViewerControl
                data={@state.focused}
                close={@clearFocus} />
    else if rec.length == 1
      core = <ViewerControl
                data={@props.records[0]} />

    else if rec.length > 1
      actions =
        clear: s.clear
        removeItem: s.update
        focusItem: @focusItem
        createGroup: s.createGroup

      core = <SelectionControl
                records={rec}
                actions={actions} />
    else
      core = <div />

    <div className={style.sidebar}>
      {core}
    </div>

  focusItem: (d)=>
    @setState focused: d

  clearFocus: (d)=>
    @setState focused: null

module.exports = Sidebar

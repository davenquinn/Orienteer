$ = require "jquery"
Spine = require "spine"
SelectionControl = require "./base"
GroupedDataControl = require "./grouped-data"
ViewerControl = require './viewer'
{reactifySpine} = require '../../util'
React = require 'react'

class Sidebar extends React.Component
  constructor: (@props)->
    super @props
    @state =
      selection: @props.data.selection.records
      focused: null
  render: ->
    sel = @state.selection
    # A selection management class
    s = @props.data.selection

    if @state.focused?
      core = <ViewerControl data={@state.focused} />

    else if @state.selection.length > 0
      core = <SelectionControl
                selection={sel}
                clearSelection={s.clear}
                createGroup={s.createGroup} />
    else
      core = <div />

    <div>
      {core}
    </div>

  # The below is a shim but it'll work for now
  componentDidMount: ->
    @props.data.selection.bind "selection:updated", @updateSelection

  componentWillUnmount: ->
    @props.data.selection.unbind "selection:updated", @updateSelection

  updateSelection: =>
    @setState
      selection: @props.data.selection.records

  setState: (ns)->
    if ns.selection.length == 1 and not ns.focused?
      ns.focused = ns.selection[0]
    super ns

module.exports = Sidebar

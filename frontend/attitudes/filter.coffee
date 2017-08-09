{Component} = require 'react'
{EditableText, Menu, MenuItem, Popover, Button, Position} = require '@blueprintjs/core'
h = require 'react-hyperscript'
{db, storedProcedure} = require '../database'

udtmap =
  varchar: 'text'
  int4: 'integer'
  float8: 'double precision'
  bool: 'boolean'

formatType = (row)->
  {column_name, data_type, udt} = row
  if udt[0] == '_'
    udt = udt.substring(1)
  um = udtmap[udt]
  udt = um if um?

  if data_type == 'ARRAY'
    data_type = "{#{udt}}"
  if data_type == 'USER-DEFINED'
    data_type = udt
  [column_name, data_type]

class FilterPanel extends Component
  constructor: (props)->
    super props
    @state = {
      dataTypes: []
      value: @props.query
    }

    db.query storedProcedure('column-types')
      .map formatType
      .then @setupTypes

  setupTypes: (dataTypes)=>
    console.log dataTypes
    @setState {dataTypes}

  componentWillReceiveProps: (nextProps)->
    {query} = nextProps
    if query != @state.value
      @setState value: query.trim()

  render: ->

    h 'div.data-filter', [
      h 'h4', 'Filter data'
      h EditableText, {
        multiline: true, value: @state.value
        className: 'code-window filter-window'
        onConfirm: @onConfirm
        onChange: @onChange
      }
      h Popover, content: @menu(), position: Position.RIGHT, [
        h Button, text: "Stored query", iconName: 'database'
      ]
      @columnDefs()
    ]

  menu: ->
    h Menu, app.subqueryIndex.map (d)->
      h MenuItem, text: d.name, onClick: ->app.runQuery(d.sql)

  columnDefs: ->
    createRow = (args, el='td')->
      [column, type] = args
      h 'tr', [
        h el, column
        h el, type
      ]

    head = {column: "Column", type: "Type"}
    h 'div.data-types', [
      h 'table.pt-table.pt-striped', [
        h 'thead', {}, createRow(['Column','Type'], 'th')
        h 'tbody', @state.dataTypes.map (d)->
          createRow(d,'td')
      ]
    ]

  onChange: (value)=>
    @setState {value}

  onConfirm: (value)=>
    return if value == @props.value
    app.runQuery value

  reset: ->
    app.runQuery app.defaultSubquery

module.exports = FilterPanel

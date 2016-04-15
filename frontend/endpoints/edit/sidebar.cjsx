React = require 'react'
E = require 'elemental'

styles = require './styles'

class NewButton extends React.Component
  render: ->
    <button type='button' className='btn btn-default' onClick={@props.handler}>
      <i className="fa fa-plus"> New item</i>
    </button>

class EditControl extends React.Component
  constructor: (props)->
    super props
  render: ->
    h = @props.handlers
    console.log h
    if @props.complete
      txt = 'Done'
    else
      txt = 'Edit vertices'

    opts = ['LineString','Polygon'].map (d)=>
      {
        label:d
        value: d
        selected: @props.featureType==d
      }

    <div>
      <E.FormSelect
        label="Feature type"
        options={opts}
        onChange={h.onChangeType} />
      <E.Button
        type='default-success'
        onClick={h.onFinish}>{txt}</E.Button>
    </div>

class ItemPanel extends React.Component
  constructor: (props)->
    super props
  renderToolbar: ->
    handlers = @props.toolbarHandlers
    <div>
      <button
        type='button'
        className='btn btn-warning fa fa-pencil btn-sm'
        onClick={handlers.edit}> Edit</button>
      <button type='button' className='btn btn-danger fa fa-trash btn-sm'> Delete</button>
      <button
        type='button'
        className='btn btn-default fa btn-sm'
        onClick={handlers.cancel}>Cancel</button>
    </div>
  render: ->
    <div className={styles.item}>
      {@renderToolbar() unless @props.editing.enabled}
      {<EditControl
        featureType={@props.editing.targetType}
        handlers={@props.editHandlers} /> if @props.editing.enabled}
    </div>

class Sidebar extends React.Component
  constructor: (props)->
    super props
    @state =
      item: null
      editing:
        targetType: 'Polygon'
        enabled: false
        complete: false
  render: ->
    <div className={styles.sidebar}>
      {<NewButton handler={@props.newHandler} /> unless @state.item?}
      {<ItemPanel
        item={@state.item}
        editing={@state.editing}
        toolbarHandlers={@props.toolbarHandlers}
        editHandlers={@props.editHandlers} /> if @state.item?}
    </div>

module.exports = Sidebar

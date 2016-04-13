React = require 'react'
E = require 'elemental'

styles = require './styles'

class NewButton extends React.Component
  render: ->
    <button type='button' className='btn btn-default' onClick={@props.handler}>
      <i className="fa fa-plus"> New item</i>
    </button>

class EditControl extends React.Component
  render: ->
    if @props.complete
      txt = 'Edit vertices'
    else
      txt = 'Done'

    opts = ['LineString','Polygon'].map (d)->
      {label:d, value: d}

    <div>
      <E.FormSelect
        label="Feature type"
        options={opts}
        onChange={@props.onChangeType} />
      <E.Button
        type='default-success'
        onClick={@props.onFinish}>{txt}</E.Button>
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
        complete={@props.editing.complete}
        featureType={@props.editing.type}
        onChangeType={@props.editing.onChangeType}
        onFinish={@props.editing.onFinish} /> if @props.editing.enabled}
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
        toolbarHandlers={@props.toolbarHandlers} /> if @state.item?}
    </div>

module.exports = Sidebar

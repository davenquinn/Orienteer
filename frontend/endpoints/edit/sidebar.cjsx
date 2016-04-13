React = require 'react'
Elemental = require 'elemental'

styles = require './styles'

class NewButton extends React.Component
  render: ->
    <button type='button' className='btn btn-default'>
      <i className="fa fa-plus"> New item</i>
    </button>

class EditControl extends React.Component
  render: ->
    <div>
      <Elemental.FormSelect
        label="Select"
        options={[]}
        htmlFor="supported-conrols-select-disabled"
        firstOption="Select" disabled />
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
      {@renderToolbar() unless @props.editing}
      {<EditControl /> if @props.editing}
    </div>

class Sidebar extends React.Component
  constructor: (props)->
    super props
    @state =
      item: null
      editing: false
  render: ->
    <div className={styles.sidebar}>
      {<NewButton /> unless @state.item?}
      {<ItemPanel
        item={@state.item}
        editing={@state.editing}
        toolbarHandlers={@props.toolbarHandlers} /> if @state.item?}
    </div>

module.exports = Sidebar

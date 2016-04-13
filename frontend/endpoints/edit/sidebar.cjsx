React = require 'react'

styles = require './styles'

console.log styles.sidebar

newButton = <button type='button' className='btn btn-default'>
  <i className="fa fa-plus"> New item</i>
</button>

class ItemDescriptor extends React.Component
  constructor: (props)->
    super props
    @state = {}
  render: ->
    <div className={styles.item}>
      <button type='button' className='btn btn-warning fa fa-pencil btn-sm'> Edit</button>
      <button type='button' className='btn btn-danger fa fa-trash btn-sm'> Delete</button>
      <button
        type='button'
        className='btn btn-default fa btn-sm'
        onClick={@props.cancelHandler}>Cancel</button>
    </div>

class Sidebar extends React.Component
  constructor: (props)->
    super props
    @state =
      item: null
  render: ->
    <div className="#{styles.sidebar}">
       {newButton unless @state.item?}
       {<ItemDescriptor item={@state.item} cancelHandler={@props.cancelHandler} /> if @state.item?}
    </div>

module.exports = Sidebar

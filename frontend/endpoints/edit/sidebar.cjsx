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
      <button type='button' className='btn btn-warning fa fa-pencil'> Edit</button>
      <button type='button' className='btn btn-danger fa fa-trash'> Delete</button>
    </div>

class Sidebar extends React.Component
  constructor: (props)->
    super props
    @state =
      item: null
  render: ->
    console.log @state
    <div className="#{styles.sidebar}">
       {newButton unless @state.item?}
       {<ItemDescriptor item={@state.item} /> if @state.item?}
    </div>

module.exports = Sidebar

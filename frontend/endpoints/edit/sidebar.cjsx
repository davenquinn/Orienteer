React = require 'react'

styles = require './styles'

console.log styles.sidebar

newButton = <button type='button' className='btn btn-default'>
  New <i className="chevron-right"></i>
</button>


class Sidebar extends React.Component
  constructor: (props)->
    super props
    @state =
      item: null
  render: ->
    console.log @state
    <div className="#{styles.sidebar}">
       {newButton unless @state.item?}
    </div>

module.exports = Sidebar

React = require 'react'
E = require 'elemental'

class DataViewer extends React.Component
  defaultState:
    data: <span className='loading'>Loading...</span>
  render: ->
    <div>
      <a onClick={@props.onClose}>
        <i className='fa fa-chevron-left'></i> Back
      </a>
      <div className="data-container">{@state.data}</div>
    </div>

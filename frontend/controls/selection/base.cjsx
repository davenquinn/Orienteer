React = require 'react'
SelectionList = require "./list"

class SelectionControl extends React.Component
  render: ->
    <div className="selection-control flex flex-container">
      <h3>Selection</h3>
      <p className="modal-controls">
        <span className="clear" onClick={@props.clearSelection}>
           <i className="fa fa-remove"></i>
        </span>
      </p>
      <SelectionList selection={@props.selection} />
      <p>
        <button
          className="group btn btn-default btn-sm"
          onClick={@props.createGroup}>Group measurements</button>
      </p>
    </div>

module.exports = SelectionControl

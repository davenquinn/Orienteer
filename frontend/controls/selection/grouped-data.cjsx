React = require 'react'

class GroupedDataControl extends React.Component
  render: ->
    <h3>Group </h3>
    <p className="modal-controls">
      <span className="close"><i className="fa fa-remove" /></span>
    </p>
    <div className="toggle" />
    <div className="info" />
    <h4>Component planes</h4>
    <ul className="selection-list">
    </ul>
    <p>
      <button className="split btn btn-danger btn-sm">Split group</button>
    </p>

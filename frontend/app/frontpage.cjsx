React = require 'react'
{Link} = require 'react-router'

class Frontpage extends React.Component
  render: ->
    <ul>
      <li><Link to='/map'>Map</Link></li>
      <li><Link to='/stereonet'>Stereonet</Link></li>
    <ul>

module.exports = Frontpage

React = require 'react'
{Link} = require 'react-router'
style = require './main.styl'

class Frontpage extends React.Component
  render: ->
    <div className={style.main}>
      <ul>
        <li><Link to='/map'>Map</Link></li>
        <li><Link to='/stereonet'>Stereonet</Link></li>
      </ul>
    </div>

module.exports = Frontpage

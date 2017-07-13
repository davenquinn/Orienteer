React = require 'react'
{Link} = require 'react-router-dom'
style = require './main.styl'

class Frontpage extends React.Component
  render: ->
    <div className={style.main}>
      <h1>Orienteer</h1>
      <p className='subtitle'>
        An application to manage the collection of attitude data
      </p>
      <ul>
        <li><Link to='/map'>Map</Link></li>
        <li><Link to='/stereonet'>Stereonet</Link></li>
      </ul>
    </div>

module.exports = Frontpage

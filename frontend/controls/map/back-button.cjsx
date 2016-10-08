React = require 'react'
ReactDOM = require 'react-dom'
{Link, hashHistory} = require 'react-router'
L = require 'leaflet'


class HomeButton extends React.Component
  render: ->
    <div className='leaflet-control leaflet-home-btn leaflet-bar'>
      <i onclick={@goHome} className='fa fa-home' />
    </div>
  componentDidMount: ->
    L.DomEvent
      .addListener(@, 'click', L.DomEvent.stopPropagation)
      .addListener(@, 'click', L.DomEvent.preventDefault)

  goHome: ->
    console.log "Going home"
    hashHistory.push '/'

Control = L.Control.extend
  options:
    position: 'topleft',
  onAdd: (map)->
    controlDiv = L.DomUtil.create('div', 'leaflet-home-btn leaflet-bar')
    L.DomEvent
      .addListener(controlDiv, 'click', L.DomEvent.stopPropagation)
      .addListener(controlDiv, 'click', L.DomEvent.preventDefault)
      .addListener(controlDiv, 'click', -> hashHistory.push '/')
    controlUI = L.DomUtil.create('a', 'leaflet-draw-edit-remove', controlDiv)
    controlUI.title = 'Go home'
    controlUI.href = '#'
    L.DomUtil.create('i', 'fa fa-home',controlUI)
    controlDiv

module.exports = Control

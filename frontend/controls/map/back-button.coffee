React = require 'react'
ReactDOM = require 'react-dom'
{Link, browserHistory} = require 'react-router'
L = require 'leaflet'
{MapControl} = require 'react-leaflet'

Control = L.Control.extend
  options:
    position: 'topleft',
  onAdd: (map)->
    controlDiv = L.DomUtil.create('div', 'leaflet-home-btn leaflet-bar')
    L.DomEvent
      .addListener(controlDiv, 'click', L.DomEvent.stopPropagation)
      .addListener(controlDiv, 'click', L.DomEvent.preventDefault)
      .addListener(controlDiv, 'click', -> location.hash = '')
    controlUI = L.DomUtil.create('a', 'leaflet-draw-edit-remove', controlDiv)
    controlUI.title = 'Go home'
    controlUI.href = '#'
    L.DomUtil.create('i', 'fa fa-home',controlUI)
    controlDiv

class HomeButton extends MapControl
  createLeafletElement: ->
    return new Control

module.exports = HomeButton

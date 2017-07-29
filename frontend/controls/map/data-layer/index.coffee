d3 = require "d3"
require 'd3-selection-multi'
require 'd3-jetpack'
L = require "leaflet"
setupMarkers = require "./markers"
marker = require './strike-dip'
{MapLayer} = require 'react-leaflet'
{Component} = require 'react'
{findDOMNode} = require 'react-dom'
h = require 'react-hyperscript'

class DataLayer extends MapLayer
  createLeafletElement: ->
    new L.SVG padding: 0.1

  render: ->
    h 'svg', {}, [h 'g', {}]

  componentDidMount: ->
    # Bind renderer to SVG
    @leafletElement._container = findDOMNode @
    super.componentDidMount()


module.exports = DataLayer

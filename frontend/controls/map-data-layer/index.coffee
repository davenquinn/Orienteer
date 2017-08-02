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
mapType = require 'react-leaflet/lib/propTypes/map'

fmt = d3.format(".0f")

class StrikeDip extends Component
  render: ->
    {transform} = @props
    scalar =  5+0.2*@props.zoom
    h 'g.strike-dip.marker', {transform}, [
      h 'line', {x2:5, stroke: 'black'}
      h 'line', {y1: -10, y2: 10, stroke: 'black'}
      h 'text.dip-magnitude', {
        x: 10
        textAnchor: 'middle'
        dy: scalar/2
        fontSize: scalar
        transform: "rotate(#{-@props.strike} 10 0)"
      }, fmt(@props.dip)
    ]

class DataLayer extends MapLayer
  @contextTypes: {
    map: mapType
  }
  constructor: (props)->
    @state = {zoom: null}
    super props

  createLeafletElement: ->
    new L.SVG padding: 0.1

  render: ->
    {map} = @context

    data = @props.records.filter (d)->not d.in_group

    projFn = (x,y)->
      map.latLngToLayerPoint(new L.LatLng(y,x))

    @zoom = map.getZoom()
    children = data.map (d)=>
      {id, strike, dip} = d
      transform = @markerTransform(d, @state.zoom, projFn)
      h StrikeDip, {key: id, strike, dip, transform, zoom: @zoom}

    projection = d3.geoTransform
      point: (x,y)->
        point = projFn(x,y)
        return @stream.point point.x, point.y

    pathGenerator = d3.geoPath().projection(projection)

    childFeatures = data.map (d)->
      h 'path', {
        key: d.id
        className: d.geometry.type
        d: pathGenerator(d)
      }

    h 'svg.data-layer.leaflet-zoom-hide', {}, [
      h('g.features',childFeatures)
      h('g.markers',children)
    ]

  componentDidMount: ->
    # Bind renderer to SVG
    @leafletElement._container = findDOMNode @
    @context.map.on 'zoomend', =>
      @setState zoom: @context.map.getZoom()
    super

  markerTransform: (d, zoom, projFn)->
    s = d.strike
    c = d.center.coordinates
    c = projFn(c[0],c[1])
    "translate(#{c.x} #{c.y}) rotate(#{s} 0 0) scale(#{1+0.2*zoom})"

module.exports = DataLayer

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

class EventedComponent extends Component
  constructor: (props)->
    super props
    @props.onMousedown = =>
      app.data.selection.update @props.key
    @props.onMouseover = =>
      app.data.hovered @props.key
    @props.onMouseout = @props.onMouseover

class StrikeDip extends EventedComponent
  render: ->
    {transform, onMouseover, onMousedown, onMouseout} = @props
    scalar =  5+0.2*@props.zoom
    h 'g.strike-dip.marker', {
        transform
        onMouseover
        onMousedown
        onMouseout
      }, [
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

class Feature extends EventedComponent
  render: ->
    h 'path', @props

class DataLayer extends MapLayer
  @contextTypes: {
    map: mapType
  }
  constructor: (props)->
    @state = {zoom: null}
    @map = null
    super props

  setupProjection: (map)=>
    @map = map
    proj = (x,y)->
      map.latLngToLayerPoint(new L.LatLng(y,x))
    projection = d3.geoTransform
      point: (x,y)->
        point = proj(x,y)
        return @stream.point point.x, point.y

    @projFn = proj
    @pathGenerator = d3.geoPath().projection(projection)

  createLeafletElement: ->
    new L.SVG padding: 0.1

  render: ->
    {map} = @context
    if @map != map
      @setupProjection(map)

    data = @props.records.filter (d)->not d.in_group

    {zoom} = @state
    children = data.map (d)=>
      {id, strike, dip} = d
      transform = @markerTransform(d, zoom)
      h StrikeDip, {key: id, strike, dip, transform, zoom}

    childFeatures = data.map (d)=>
      h Feature, {
        key: d.id
        className: d.geometry.type
        d: @pathGenerator(d)
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

  markerTransform: (d, zoom)=>
    s = d.strike
    c = d.center.coordinates
    c = @projFn(c[0],c[1])
    "translate(#{c.x} #{c.y}) rotate(#{s} 0 0) scale(#{1+0.2*zoom})"

module.exports = DataLayer

d3 = require "d3"
L = require "leaflet"
{MapLayer} = require 'react-leaflet'
{Component} = require 'react'
{findDOMNode} = require 'react-dom'
h = require 'react-hyperscript'
mapType = require 'react-leaflet/lib/propTypes/map'
classNames = require 'classnames'
{instanceOf} = require 'prop-types'

fmt = d3.format(".0f")

eventHandlers = (record)->
  onMouseDown = ->
    app.data.updateSelection record
  onMouseOver = ->
    app.data.hovered record
  onMouseOut = ->
    app.data.hovered null
  {onMouseOver, onMouseDown}


class StrikeDip extends Component
  render: ->
    {transform, record} = @props
    {strike, dip, selected, hovered} = record
    scalar =  5+0.2*@props.zoom

    className = classNames 'strike_dip', 'marker', {
      hovered,
      selected
    }

    handlers = eventHandlers(record)
    h "g", {transform, className, handlers...}, [
      h 'line', {x2:5, stroke: 'black'}
      h 'line', {y1: -10, y2: 10, stroke: 'black'}
      h 'text.dip-magnitude', {
        x: 10
        textAnchor: 'middle'
        dy: scalar/2
        fontSize: scalar
        transform: "rotate(#{-strike} 10 0)"
      }, fmt(dip)
    ]

class Feature extends Component
  render: ->
    {record, d} = @props
    handlers = eventHandlers(record)
    {selected, hovered} = record

    className = classNames record.geometry.type,
      {hovered, selected}

    h "path", {className, d, handlers...}

class DataLayer extends MapLayer
  constructor: (props)->
    console.log "Created data layer"
    super props
    @state = {zoom: null}
    @map = null

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
      {id} = d
      transform = @markerTransform(d, zoom)

      h StrikeDip, {key: id, record: d, transform, zoom}

    childFeatures = data.map (d)=>
      h Feature, {
        key: d.id
        record: d
        d: @pathGenerator(d)
      }

    h 'svg.data-layer.leaflet-zoom-hide', {}, [
      h('g.features',childFeatures)
      h('g.markers',children)
    ]

  componentDidMount: ->
    console.log "Mounted data layer"
    # Bind renderer to SVG
    @leafletElement._container = findDOMNode @
    @context.map.on 'zoomend', =>
      @setState zoom: @context.map.getZoom()
    super arguments...

  componentWillUnmount: ->
    console.log "Unmounted data layer"
    super arguments...

  markerTransform: (d, zoom)=>
    s = d.strike
    c = d.center.coordinates
    c = @projFn(c[0],c[1])
    "translate(#{c.x} #{c.y}) rotate(#{s} 0 0) scale(#{1+0.2*zoom})"

module.exports = DataLayer

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
  {onMouseOver, onMouseOut, onMouseDown}

class StrikeDip extends Component
  constructor: (props)->
    super props
    @state = @buildState()

  shouldComponentUpdate: (nextProps)->
    {record, zoom} = @props
    return true if zoom != nextProps.zoom
    return true if record != nextProps.record
    return false

  buildState: (props)->
    props ?= @props
    {record, projection} = props
    c = record.center.coordinates
    location = projection(c[0],c[1])
    {location}

  componentWillReceiveProps: (nextProps)->
    if nextProps.zoom != @props.zoom
      @setState @buildState(nextProps)

  render: ->
    {record, projection, zoom} = @props
    {location} = @state
    {strike, dip, selected, hovered, center} = record
    scalar =  5+0.2*zoom

    className = classNames 'strike_dip', 'marker', {
      hovered,
      selected
    }

    transform = "translate(#{location.x} #{location.y})
                 rotate(#{strike} 0 0)
                 scale(#{0.5+0.1*zoom})"

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
  constructor: (props)->
    super props
    @state = @buildState()

  shouldComponentUpdate: (nextProps)->
    {record, pathGenerator} = @props
    return true if pathGenerator != nextProps.pathGenerator
    return true if record != nextProps.record
    return false

  buildState: (props)->
    props ?= @props
    {record, pathGenerator} = props
    d = pathGenerator(record)
    {d}

  componentWillReceiveProps: (nextProps)->
    if nextProps.pathGenerator != @props.pathGenerator
      @setState @buildState(nextProps)

  render: ->
    {record, pathGenerator} = @props
    handlers = eventHandlers(record)
    {selected, hovered} = record

    className = classNames record.geometry.type,
      {hovered, selected}

    {d} = @state
    h "path", {className, d, handlers...}

class DataLayer extends MapLayer
  constructor: (props)->
    console.log "Created data layer"
    super props
    @state = {zoom: null}

  buildProjection: =>
    console.log "Building projection"
    {map} = @context
    zoom = map.getZoom()
    proj = (x,y)->
      map.latLngToLayerPoint(new L.LatLng(y,x))
    projection = d3.geoTransform
      point: (x,y)->
        point = proj(x,y)
        return @stream.point point.x, point.y
    pathGenerator = d3.geoPath().projection(projection)
    @setState {projection: proj, pathGenerator, zoom}

  createLeafletElement: ->
    new L.SVG padding: 0.1

  render: ->
    console.log "Rendering data layer"
    {records} = @props
    {projection, pathGenerator, zoom} = @state

    data = records.filter (d)->not d.in_group

    children = data.map (record)=>
      h StrikeDip, {key: record.id, record, projection, zoom}

    childFeatures = data.map (record)=>
      h Feature, {
        key: record.id
        record
        pathGenerator
      }

    h 'svg.data-layer.leaflet-zoom-hide', {}, [
      h('g.features',childFeatures)
      h('g.markers',children)
    ]

  componentDidMount: ->
    console.log "Mounted data layer"
    # Bind renderer to SVG
    @leafletElement._container = findDOMNode @
    @buildProjection()
    @context.map.on 'zoomend', @buildProjection
    super arguments...

  componentWillUnmount: ->
    console.log "Unmounted data layer"
    super arguments...

module.exports = DataLayer

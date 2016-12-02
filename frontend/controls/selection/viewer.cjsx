React = require 'react'
$ = require 'jquery'
d3 = require "d3"
style = require './style'
SelectionList = require './list'

sf = d3.format ">8.1f"
df = d3.format ">6.1f"

strikeDip = (d)->
  strike = sf(d.strike)
  dip = df(d.dip)
  <span><span className="strike">{strike}º</span> <span className="dip">{dip}º</span></span>

class GroupedAttitudeControl extends React.Component
  renderListItem: (d)->
    <ListItem data={d} key={d.id} />
  render: ->
    # Group type selector should go here...
    rec = app.data.get(@props.data.measurements...)
    <div>
      <h4>Component planes ({rec.length})</h4>
      <SelectionList
        records={rec}
        hovered={@props.hovered} />
      <p>
        <button
          className="split btn btn-danger btn-sm"
          onClick={@props.data.requestDestruction}>
          Split group
        </button>
      </p>
    </div>

class DataViewer extends React.Component
  constructor: (props)->
    super props
    @state =
      content: <span className='loading'>Loading...</span>

  componentDidMount: ->
    if not @props.data?
      @setState content: <p>Hover over data to display fit statistics.</p>
    else
      url = "#{window.server_url}/elevation/attitude/#{@props.data.id}/data.html"
      $.get url, @onNetworkData

  onNetworkData: (data)=>
    c = <div dangerouslySetInnerHTML={__html:data} />
    @setState content: c

  renderGroupData: ->
    <GroupedAttitudeControl
      data={@props.data}
      hovered={@props.hovered} />

  render: ->
    grouped = @props.data.is_group
    <div>
      <h2>{if grouped then 'Group' else 'Attitude'} {@props.data.id}</h2>
      <ul>
        <li>{strikeDip @props.data}</li>
      </ul>
      {@renderGroupData() if grouped}
      <div className="data-container">
        <h4>Axis-aligned residuals</h4>
        <img src={"#{window.server_url}/elevation/attitude/#{@props.data.id}/axis-aligned.png"} />
        <h4>Errorbar comparison</h4>
        <img src={"#{window.server_url}/elevation/attitude/#{@props.data.id}/errorbars.png"} />
      </div>
    </div>

module.exports = DataViewer

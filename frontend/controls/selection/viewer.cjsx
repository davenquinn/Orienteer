React = require 'react'
$ = require 'jquery'
Switch = require 'react-switch-button'
d3 = require "d3"

sf = d3.format ">8.1f"
df = d3.format ">6.1f"

class ListItem extends React.Component
  render: ->
    d = @props.data
    strike = sf(d.properties.strike)
    dip = df(d.properties.dip)
    <li>
      <span onClick={@props.focusItem}>
        <span className="strike">{strike}º</span>
        <span className="dip">{dip}º</span>
      </span>
    </li>

class GroupedAttitudeControl extends React.Component
  renderListItem: (d)->
    <ListItem data={d} key={d.id} />
  render: ->
    <div>
      <Switch name='plane-type'
          label="Parallel"
          labelRight="Single"
          defaultChecked={@props.data.same_plane} />
      <h4>Component planes</h4>
      <ul className="selection-list">
        {@props.data.records.map @renderListItem}
      </ul>
      <p>
        <button className="split btn btn-danger btn-sm">
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
    <GroupedAttitudeControl data={@props.data} />

  render: ->
    grouped = @props.data.records?
    <div>
      <a onClick={@props.close}>
        <i className='fa fa-chevron-left'></i> Back
      </a>
      <div>
        <h2>{if grouped then 'Group' else 'Attitude'} {@props.data.id}</h2>
        {@renderGroupData() if grouped}
        <div className="data-container">{@state.content}</div>
      </div>
    </div>

module.exports = DataViewer

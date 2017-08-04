React = require 'react'
$ = require 'jquery'
d3 = require "d3"
style = require './style'
SelectionList = require './list'
{Button, Intent} = require '@blueprintjs/core'

sf = d3.format ">8.1f"
df = d3.format ">6.1f"

strikeDip = (d)->
  strike = sf(d.strike)
  dip = df(d.dip)
  <span><span className="strike">{strike}º</span> <span className="dip">{dip}º</span></span>

class GroupedAttitudeControl extends React.Component
  render: ->
    # Group type selector should go here...
    rec = app.data.get(@props.data.measurements...)
    <div>
      <h6>Component planes</h6>
      <SelectionList
        records={rec}
        hovered={@props.hovered} />
      <p>
        <Button intent={Intent.DANGER} iconName='ungroup' onClick={@shouldDestroyGroup}>Ungroup</Button>
      </p>
    </div>

  shouldDestroyGroup: =>
    app.data.destroyGroup @props.data.id

class DataViewer extends React.Component
  @defaultProps:
    hovered: false
    focusItem: ->
    data: null
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
    method = if grouped then @props.focusItem else ->

    <div>
      <h4>{if grouped then 'Group' else 'Attitude'} {@props.data.id}</h4>
      <SelectionList records={[@props.data]} focusItem={method} />
      {@renderGroupData() if grouped}
      <div className="data-container">
        <h6>Axis-aligned residuals</h6>
        <img src={"#{window.server_url}/elevation/attitude/#{@props.data.id}/axis-aligned.png"} />
      </div>
    </div>

module.exports = DataViewer

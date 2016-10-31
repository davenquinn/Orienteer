React = require 'react'
$ = require 'jquery'

class DataViewer extends React.Component
  constructor: (@props)->
    super @props
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

  render: ->
    <div>
      <a onClick={@props.onClose}>
        <i className='fa fa-chevron-left'></i> Back
      </a>
      <div className="data-container">{@state.content}</div>
    </div>

module.exports = DataViewer

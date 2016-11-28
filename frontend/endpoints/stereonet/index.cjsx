React = require 'react'
Infinite = require 'react-infinite'
StereonetView = require './control'
{Link} = require 'react-router'
d3 = require 'd3'
require 'd3-selection-multi'
style = require './main.styl'
stereonet = require '../controls/stereonet'

class ListItem extends React.Component
  handleClick: =>
    console.log @props.data
    app.data.selection.update @props.data

  render: ->
    clsname = if @props.selected then "selected" else ""
    <div onClick={@handleClick} className={clsname}>
      {if @props.selected then "selected" else @props.data.id  }
    </div>

class AttitudeList extends React.Component
  __renderChild: (d,i)=>
    sel = app.data.selection.records
    <ListItem
      data={d}
      key={d.id}
      selected={@props.selection.indexOf(d) != -1}/>
  render: ->
    <div>
      <h1>Attitudes</h1>
      <Infinite
        className={style.list}
        containerHeight={500}
        elementHeight={20}>
        {@props.data.map @__renderChild}
      </Infinite>
    </div>

class StereonetPage extends React.Component
  constructor: (@props)->
    recs = @props.data.records()
      .filter (d)->not d.group?
    @state =
      records: recs
      selection: app.data.selection.records
  updateSelection: =>
    @setState
      selection: app.data.selection.records

  componentDidMount: ->
    @props.data.selection.bind "selection:updated", @updateSelection

  componentWillUnmount: ->
    @props.data.selection.unbind "selection:updated", @updateSelection

  render: ->
    # Filter data so that attitudes that are
    # part of a group are not included in
    # selection
    recs = @props.data.records()
      .filter (d)->not d.group?

    <div className={style.wrap}>
      <div className={style.sidebar}>
        <Link className={style.homeLink} to="/">
          <i className='fa fa-home' /> Home
        </Link>
        <AttitudeList
          data={@state.records}
          selection={@state.selection} />
      </div>
      <div className={style.main}>
        <StereonetView data={@state.selection} />
      </div>
    </div>

module.exports = StereonetPage


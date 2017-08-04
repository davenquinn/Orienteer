Spine = require "spine"
React = require 'react'
ReactDOM = require 'react-dom'
MapControl = require "../controls/map"
SelectionControl = require "../controls/selection"
DataPane = require "./data-pane"
h = require 'react-hyperscript'
SplitPane = require 'react-split-pane'
{Tab2, Tabs2} = require '@blueprintjs/core'
FilterPanel = require './filter'
MapDataLayer = require '../controls/map-data-layer'

d3 = require "d3"
$ = require "jquery"

style = require './style.styl'

f = d3.format "> 6.1f"

paneStyle =
  display: 'flex'
  flexDirection: 'column'

class AttitudePage extends React.Component
  render: ->
    {records, featureTypes, query, showSidebar} = @props
    selection = records.filter (d)->d.selected
    hovered = records.find (d)->d.hovered

    s = if showSidebar then {} else {display: 'none'}

    selectionPanel = h SelectionControl, records: selection, hovered

    dataManagementPanel = h DataPane, {
      records: selection
      hovered
      featureTypes
    }

    h SplitPane, {
      split: "vertical"
      minSize: 300
      primary: "second"
      paneStyle
      pane2Style: s
      onChange: @onResizePane
    },[
      h MapControl, {settings: @props.settings.map}, [
        h MapDataLayer, {records}
      ]
      h Tabs2, className: 'sidebar-outer', [
        h Tab2, id: 'selection-panel', title: 'Selection', panel: selectionPanel
        h Tab2, id: 'data-panel', title: 'Data', panel: dataManagementPanel
        h Tab2, id: 'sql-panel', title: 'Filter', panel: h(FilterPanel, {query})
        h Tab2, id: 'options', title: 'Options', panel: h('div')
      ]
    ]

  onResizePane: (size)->
    console.log size

module.exports = AttitudePage

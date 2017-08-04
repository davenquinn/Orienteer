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
  constructor: (props)->
    super props

  render: ->
    {records, featureTypes, query} = @props
    selection = records.filter (d)->d.selected
    hovered = records.find (d)->d.hovered

    s = null
    if selection.length == 0
      s = display: 'none'
    else
      s = overflowY: 'scroll'

    tab1Panel = h 'div', className: style.sidebar, [
      h 'div', className: style.sidebarComponent, [
        h SelectionControl, {
          records: selection
          hovered
        }
      ]
      h DataPane, {
        records: selection
        hovered
        featureTypes
      }
    ]

    tab2Panel = h FilterPanel, {query}

    console.log @props.settings.map

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
      h 'div.sidebar-outer', [
        h Tabs2, [
          h Tab2, id: 'selection-panel', title: 'Selection', panel: tab1Panel
          h Tab2, id: 'sql-panel', title: 'Filter', panel: tab2Panel
          h Tab2, id: 'options', title: 'Options', panel: h('div')
        ]
      ]
    ]


  onResizePane: (size)->
    console.log size

module.exports = AttitudePage

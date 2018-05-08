Spine = require "spine"
React = require 'react'
ReactDOM = require 'react-dom'
MapControl = require "../controls/map"
SelectionControl = require "../controls/selection"
DataPane = require "./data-pane"
h = require 'react-hyperscript'
SplitPane = require 'react-split-pane'
{Tab2, Tabs2, Hotkey, Hotkeys, HotkeysTarget } = require '@blueprintjs/core'
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
    @state = {splitPosition: 350, selectedTabId: 1}

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

    {selectedTabId} = @state

    if @state.splitPosition < 600
      panels = [
          h Tab2, id: 1, title: 'Selection', panel: selectionPanel
          h Tab2, id: 2, title: 'Data', panel: dataManagementPanel
      ]
    else
      selectedTabId = 1 if selectedTabId == 2
      panels = [
        h Tab2, id: 1, title: 'Selection / Data', panel: h 'div.combined-panel', [
          selectionPanel, dataManagementPanel
        ]
      ]


    h SplitPane, {
      split: "vertical"
      minSize: 350
      defaultSize: @state.splitPosition
      primary: "second"
      paneStyle
      pane2Style: s
      onChange: @onResizePane
    },[
      h MapControl, {settings: @props.settings.map}, [
        h MapDataLayer, {records}
      ]
      h Tabs2, {className: 'sidebar-outer', selectedTabId, onChange: @onChangeTab}, [
        panels...
        h Tab2, id: 3, title: 'Filter', panel: h(FilterPanel, {query})
        h Tab2, id: 4, title: 'Options', panel: h('div')
      ]
    ]

  onChangeTab: (selectedTabId)=>
    @setState {selectedTabId}

  onResizePane: (size)=>
    @setState splitPosition: size
    console.log size

  renderHotkeys: ->
    h Hotkeys, [
      h Hotkey, label: "Clear selection", combo:"backspace", global: true, onKeyDown: app.data.clearSelection
    ]

HotkeysTarget AttitudePage

module.exports = AttitudePage

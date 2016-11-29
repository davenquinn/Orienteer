React = require 'react'
Measure = require 'react-measure'
Stereonet = require "../../controls/stereonet"
TagManager = require "../../controls/tag-manager"
{debounce} = require "underscore"
style = require './style'

class DataPane extends React.Component
  constructor: (props)->
    super props
    @state =
      width: 300
    # Create debounced method for setting size
    @setSize = debounce(@_setSize, 200)

  render: ->
    <Measure onMeasure={@setSize}>
      <div className={style.sidebarComponent}>
        <TagManager />
        <Stereonet
          data={@props.records}
          hovered={@props.hovered}
          width={@state.width} />
      </div>
    </Measure>

  _setSize: (dimensions)=>
    @setState width: dimensions.width

module.exports = DataPane

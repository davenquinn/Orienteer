React = require 'react'
Measure = require 'react-measure'
Stereonet = require "../controls/stereonet"
TagManager = require "../controls/tag-manager"
SelectType = require "../controls/select-type"
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
        <div>
          <h6>Tags</h6>
          <TagManager records={@props.records} hovered={@props.hovered} />
        </div>
        <div>
          <h6>Data type</h6>
          <SelectType
            records={@props.records}
            featureTypes={@props.featureTypes} />
        </div>
        <Stereonet
          data={@props.records}
          hovered={@props.hovered}
          width={@state.width} />
      </div>
    </Measure>

  _setSize: (dimensions)=>
    @setState width: dimensions.width

module.exports = DataPane

React = require 'react'
Select = require 'react-select'
require "react-select/dist/react-select.css"

class SelectType extends React.Component
  render: ->
    recs = @props.records.map (d)->d.class

    allSame = recs.every (e)->e == recs[0]
    if allSame
      rec = recs[0] or null
    else
      rec = 'multiple'

    types = @props.featureTypes
    t = types.map (d)->
      {value: d.id, label: d.id}
    if @props.records.length > 1
      t.push {value: 'multiple', label: 'Multiple'}

    onChange = (type)=>
      console.log "Changed select to #{type}"
      if type?
        val = type.value
      else
        val = 'null'
      app.data.changeClass val, @props.records

    <Select name="select-type" value={rec} options={t} onChange={onChange} />

module.exports = SelectType


React = require 'react'
Select = require 'react-select'
h = require 'react-hyperscript'
require "react-select/dist/react-select.css"

class SelectType extends React.Component
  render: ->
    {records, hovered, featureTypes} = @props
    recs = if hovered? then [hovered] else records
    recs = recs.map (d)->d.class

    allSame = recs.every (e)->e == recs[0]
    if allSame
      rec = recs[0] or null
    else
      rec = 'multiple'

    t = featureTypes.map (d)->
      {value: d.id, label: d.id, color: d.color}
    if recs.length > 1
      t.push {value: 'multiple', label: 'Multiple', color: 'gray'}

    onChange = (type)=>
      return false if hovered?
      console.log "Changed select to #{type}"
      if type?
        val = type.value
      else
        val = 'null'
      app.data.changeClass val, @props.records

    renderOption = (opt)->
      v = opt.value.replace('_',' ')
      v.charAt(0).toUpperCase()+v.slice(1)
      return v

    h Select, {name: "select-type", value: rec, options:t, onChange, optionRenderer:renderOption}

module.exports = SelectType


React = require 'react'
Select = require 'react-select'
require "react-select/dist/react-select.css"

class SelectType extends React.Component
  render: ->
    recs = @props.records.map (d)->d.class

    allSame = recs.every (e)->e == recs[0]
    console.log recs
    if allSame
      rec = recs[0] or 'null'
    else
      rec = 'multiple'

    types = @props.featureTypes
    t = types.map (d)->
      {value: d.id, label: d.id}
    if @props.records.length > 0
      t.push {value: 'multiple', label: 'Multiple'}
    t.push {value: null, label: 'None'}

    onChange = (type)=>
      console.log type
      app.data.changeClass type.value, @props.records

    <Select
        name="select-type"
        value={rec}
        options={t}
        onChange={onChange} />

module.exports = SelectType


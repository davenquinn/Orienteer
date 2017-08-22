React = require 'react'
ReactDOM = require 'react-dom'
style = require './style'
h = require 'react-hyperscript'
{Tag, Intent} = require '@blueprintjs/core'

buildTagData = (records)->
  func = (a, d)->
    Array::push.apply a, d.tags
    return a
  arr = records.reduce func, []
  func = (d, name)->
    d[name] = 0 unless name of d
    d[name] += 1
    return d
  data = arr.reduce func, {}
  arr = []
  for tag, num of data
    arr.push
      name: tag
      all: num >= records.length
  return arr

class TagForm extends React.Component
  constructor: (props)->
    super props
    @state = {value: ''}

  render: ->
    vals =
      onSubmit: @submitForm
    h 'form.form-inline', vals, [
      h 'input.pt-input.pt-fill', {
        autoComplete: "off"
        type: "text"
        name: "tag"
        value: @state.value
        placeholder: "Tag"
        onChange: @sanitizeField
      }
    ]

  sanitizeField: (event)=>
    val = event.target.value
    @setState value: val.toLowerCase()

  submitForm: (event)=>
    event.preventDefault()
    @props.onUpdate @state.value
    @setState value: ''

class TagManager extends React.Component
  render: ->
    {hovered, records} = @props

    rec = if hovered? then [hovered] else records
    tags = buildTagData(rec)
    val = if hovered? then 'Hovered item' else 'Selection'

    h 'div.tag-manager', [
      h 'div.header', [
        h 'h6', 'Tags'
        h 'h6.info', val
      ]
      h "p.tag-list", tags.map ({all,name})=>
        intent = if all then Intent.SUCCESS else null
        h Tag, {onRemove: @removeTag, intent, name: name, className: 'pt-minimal'}, name
      h TagForm, onUpdate: @addTag
    ]

  addTag: (name)=>
    console.log "Adding tag #{name}"
    app.data.addTag name, @props.records

  removeTag: (evt, {name})=>
    app.data.removeTag name, @props.records

module.exports = TagManager

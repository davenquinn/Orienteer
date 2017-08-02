React = require 'react'
ReactDOM = require 'react-dom'
style = require './style'
h = require 'react-hyperscript'

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

class TagItem extends React.Component
  render: ->
    cls = if @props.all then "all" else "some"
    h "li", className: cls, [
      @props.name
      h 'span.remove', onClick: @onRemove, [
        h 'i.fa.fa-remove'
      ]
    ]

  onRemove: =>
    console.log "Removing item"
    @props.removeFunction @props.name

class TagForm extends React.Component
  constructor: (props)->
    super props
    @state = {value: ''}

  render: ->
    vals =
      onSubmit: @submitForm
    h 'form.form-inline', vals, [
      h 'input.form-control.input-small', {
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
    tags = buildTagData(@props.records)

    h 'div.tagManager', [
      h "ul.tagList", tags.map (t)=>
        h TagItem, {
          name: t.name
          all: t.all
          removeFunction: @removeTag
        }
      h TagForm, onUpdate: @addTag
    ]
  componentDidMount: ->
    el = ReactDOM.findDOMNode @

  addTag: (name)=>
    console.log "Adding tag #{name}"
    app.data.addTag name, @props.records

  removeTag: (name)=>
    app.data.removeTag name, @props.records

module.exports = TagManager

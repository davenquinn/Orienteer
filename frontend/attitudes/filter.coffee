{Component} = require 'react'
{EditableText} = require '@blueprintjs/core'
h = require 'react-hyperscript'

class FilterPanel extends Component
  render: ->

    h 'div', [
      h EditableText, {
        multiline: true, minLines: 5, defaultValue: @props.query
        className: 'code-window filter-window'
        onConfirm: @onConfirm
      }
      h 'button.pt-button.pt-icon-undo', onClick: @reset, "Reset query"
    ]

  onConfirm: (value)->
    app.runQuery value

  reset: ->
    app.runQuery app.defaultSubquery

module.exports = FilterPanel

React = require 'react'
{Link} = require 'react-router-dom'
style = require './main.styl'
h = require 'react-hyperscript'

class Frontpage extends React.Component
  render: ->
    h 'div', className: style.main, [
      h 'h1', "Orienteer"
      h 'p', className: 'subtitle',
        "An application to manage the collection of attitude data"
      h 'ul', [
        h 'li', [
          h(Link, to:'/map', "Map")
        ]
        h 'li', [
          h(Link, to:'/stereonet', "Stereonet")
        ]
      ]
    ]

module.exports = Frontpage

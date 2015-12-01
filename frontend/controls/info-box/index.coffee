Spine = require "spine"
Stereonet = require "../stereonet"
template = require "./template.html"
data_template = require "./data-template.html"
$ = require "jquery"

class InfoBox extends Spine.Controller
  className: "info-box"
  group: null
  constructor: ->
    super
    @$el.hide()
    @$el.addClass "info-box"
    @$el.html template

    @stereonet = new Stereonet
      el: @$(".stereonet")
      data: @data
      selection: @data.selection

    @$el.show 500

    @listenTo @data, "hovered", @onHover

  onHover: (d)=>
    return unless d.hovered
    d.server_url = window.server_url
    @$(".data").html data_template(d)

module.exports = InfoBox

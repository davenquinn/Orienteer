Spine = require "spine"
$ = require "jquery"
Stereonet = require "../stereonet"
TagManager = require "../tag-manager"
template = require "./template.html"

Data = require "../../app/data"
CollapsiblePanel = require "../ui/collapsible"

class ModalControl extends Spine.Controller
  idx:
    "tag-manager": TagManager
    "stereonet": Stereonet

  events:
    "click nav li": "switchControl"
  constructor: ->
    super
    if @active?
      @setupControl @active

  setupControl: (control, duration=500)=>
    create = =>
      str = "<div class='#{control} control' />"
      @control = new @idx[control]
        el: $(str).appendTo(@el).hide()
        data: Data
        selection: window.app.data.selection
      @control.el
        .addClass "control"
        .css marginRight: "-20rem"
        .velocity {
          marginRight: 0
          duration: 500},
          display: "block"
      @$ "nav li.#{control}"
        .addClass "active"

    if @control?
      @removeControl create, duration
    else
      create()

  removeControl: (callback, duration=500)=>
    @$("li").removeClass "active"
    @control.el.hide duration, =>
      console.log @control
      try
        @control.release()
      catch e
      @control = null
      callback()
  switchControl: (e)=>
    console.log "Switching control"
    el = $(e.currentTarget)
    return if el.hasClass "active"
    for i of @idx
      console.log i
      if el.hasClass i
        @setupControl i
        return

class DataPanel extends CollapsiblePanel
  className: "data-panel flex-container"
  width: "35rem"
  group: null
  constructor: ->
    super
    @el.css
      display: "none"
      width: @width
    @el.html template

    @modal = new ModalControl
      el: @$ ".modal-controls"
      active: "tag-manager"

  _show: (shouldShow)->
    if shouldShow
      @el
        .css
          marginRight: "-#{@width}"
        .velocity {
          marginRight: "0"
          duration: @options.animationDuration},
          display: "flex"
    else
      # make invisible
      @el
        .velocity {
          marginRight: "-#{@width}"
          duration: @options.animationDuration}, display: "none"

module.exports = DataPanel

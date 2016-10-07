$ = require "jquery"
window.jQuery = $
window.$ = $
require "velocity-animate"
d3 = require 'd3'
require 'd3-selection-multi'

window.server_url = "http://0.0.0.0:8000"

Spine = require "spine"
Spine.jQuery = $
require "spine/lib/route"
App = require "./app"
setupMenu = require "./menu"

app = new App el: $ 'body'
setupMenu(app)
Spine.Route.setup()

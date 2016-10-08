$ = require "jquery"
window.jQuery = $
window.$ = $
require "velocity-animate"

window.server_url = "http://0.0.0.0:8000"

Spine = require "spine"
Spine.jQuery = $
require "spine/lib/route"
setupApp = require "./app"
setupMenu = require "./menu"

setupApp()

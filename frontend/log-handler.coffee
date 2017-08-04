{Position, Toaster} = require '@blueprintjs/core'


class LogHandler
  constructor: ->
    @toaster = Toaster.create { className: 'error-handler', position: Position.Top }
  error: (msg)->
    console.error msg
    @toaster.show {
      message: msg
      intent: 'danger'
      iconName: 'error'
    }
  success: (msg)->
    console.log msg
    @toaster.show {
      message: msg
      intent: 'success'
      iconName: 'tick-circle'
      timeout: 2000
    }

module.exports = LogHandler

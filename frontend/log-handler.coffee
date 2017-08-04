{Position, Toaster, Intent} = require '@blueprintjs/core'


class LogHandler
  constructor: ->
    @toaster = Toaster.create { className: 'log-overlay', position: Position.Top }
  error: (msg)->
    console.error msg
    @toaster.show {
      message: msg
      intent: Intent.DANGER
      iconName: 'error'
    }
  success: (msg)->
    console.log msg
    @toaster.show {
      message: msg
      intent: Intent.SUCCESS
      iconName: 'tick-circle'
      timeout: 2000
    }

module.exports = LogHandler

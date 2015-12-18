notify = require "gulp-notify"

module.exports =
  handleErrors: ->
    args = Array::slice.call(arguments)
    # Send error to notification center with gulp-notify
    notify
      .onError message: "<%= error.message %>"
      .apply this, args

    # Keep gulp from hanging on this task
    @emit "end"

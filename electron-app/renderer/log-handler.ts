/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const { Position, Toaster, Intent } = require("@blueprintjs/core");

class LogHandler {
  constructor() {
    this.toaster = Toaster.create({
      className: "log-overlay",
      position: Position.Top,
    });
  }
  error(msg) {
    console.error(msg);
    return this.toaster.show({
      message: msg,
      intent: Intent.DANGER,
      iconName: "error",
    });
  }
  success(msg) {
    console.log(msg);
    return this.toaster.show({
      message: msg,
      intent: Intent.SUCCESS,
      iconName: "tick-circle",
      timeout: 2000,
    });
  }
}

module.exports = LogHandler;

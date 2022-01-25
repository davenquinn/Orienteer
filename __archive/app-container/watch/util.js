/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const notify = require("gulp-notify");

module.exports = {
  handleErrors() {
    const args = Array.prototype.slice.call(arguments);
    // Send error to notification center with gulp-notify
    notify.onError({ message: "<%= error.message %>" }).apply(this, args);

    // Keep gulp from hanging on this task
    return this.emit("end");
  },
};

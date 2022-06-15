const Spine = require("spine");
const d3 = require("d3");
const template = require("./template.html");

const Map = require("../../controls/map");

class NotesPage extends Spine.Controller {
  constructor() {
    super();
    this.el.html(template);

    this.map = new Map({
      el: this.$(".map"),
    });
  }
}

module.exports = NotesPage;

/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const $ = require("jquery");
const d3 = require("d3");
const Spine = require("spine");
const template = require("./tag-manager.html");

class TagManager extends Spine.Controller {
  static initClass() {
    this.prototype.events = {
      "submit form": "submit",
      "keypress input": "onKeypress",
    };
  }
  constructor() {
    this.update = this.update.bind(this);
    this.updateFromSelection = this.updateFromSelection.bind(this);
    this.removeTag = this.removeTag.bind(this);
    super();
    if (this.selection == null) {
      throw "@selection required";
    }

    this.el.html(template);
    this.ul = d3.select(this.el[0]).select("ul");
    this.tags = [];
    this.updateFromSelection();
  }

  update(tags) {
    if (tags == null) {
      ({ tags } = this);
    }

    if (typeof tags[0] === "string") {
      // We've got a list of items that
      // don't have data on all/some status
      // In this case we assume that they
      // are present for all items.
      tags = tags.map((d) => ({
        name: d,
        all: true,
      }));
    }

    const li = this.ul.selectAll("li").data(tags, (d) => d.name);

    li.exit().remove();
    li.enter()
      .append("li")
      .text((d) => d.name)
      .append("span")
      .html("<i class='fa fa-remove'></i>")
      .attr("class", "remove")
      .on("click", this.removeTag);

    return li.attr("class", function (d) {
      if (d.all) {
        return "all";
      } else {
        return "some";
      }
    });
  }

  updateFromSelection(d) {
    let tags;
    if (this.selection.empty() && d != null) {
      ({ tags } = d);
    } else {
      tags = this.selection.getTags();
    }
    return this.update(tags);
  }

  sanitizeInput(text) {
    return text.toLowerCase();
  }
  //.replace /[^\w-]+/g, '-'

  onKeypress(e) {
    const i = $(e.currentTarget);
    return i.val(this.sanitizeInput(i.val()));
  }

  removeTag(d) {
    return this.selection.removeTag(d.name);
  }

  addTag(name) {
    console.log("Adding tag", name);
    return this.selection.addTag(name);
  }

  submit(e) {
    const input = this.$("form input");
    e.preventDefault();
    this.addTag(input.val());
    return input.val("");
  }
}
TagManager.initClass();

module.exports = TagManager;

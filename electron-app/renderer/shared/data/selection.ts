/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const Spine = require("spine");
const tags = require("./tags");

class Selection extends Spine.Module {
  static initClass() {
    this.include(Spine.Events);
  }
  constructor() {
    this.getTags = this.getTags.bind(this);
    this.empty = this.empty.bind(this);
    this.notify = this.notify.bind(this);
    this.addSeveral = this.addSeveral.bind(this);
    this.fromRecords = this.fromRecords.bind(this);
    this._add = this._add.bind(this);
    this.add = this.add.bind(this);
    this._remove = this._remove.bind(this);
    this.remove = this.remove.bind(this);
    this.update = this.update.bind(this);
    this.contains = this.contains.bind(this);
    this.clear = this.clear.bind(this);
    this._tagRemoved = this._tagRemoved.bind(this);
    this._tagAdded = this._tagAdded.bind(this);
    super();
    this.records = [];
  }

  getTags() {
    const { records } = this;
    let arr = tags.get(records);
    const func = function (d, name) {
      if (!(name in d)) {
        d[name] = 0;
      }
      d[name] += 1;
      return d;
    };
    const data = arr.reduce(func, {});
    arr = [];
    for (let tag in data) {
      const num = data[tag];
      arr.push({
        name: tag,
        all: num >= records.length,
      });
    }
    return arr;
  }

  empty() {
    return !this.records.length;
  }

  notify() {
    return this.trigger("selection:updated", this.records);
  }

  addSeveral(records) {
    for (let d of Array.from(records)) {
      this._add(d);
    }
    return this.notify();
  }

  fromRecords(records) {
    this.records = records;
    return this.notify();
  }

  _add(d) {
    const i = this.records.indexOf(d);
    if (i !== -1) {
      return;
    }
    this.records.push(d);
    return (d.selected = true);
  }
  add(d) {
    this._add(d);
    return this.notify();
  }

  _remove(d) {
    const i = this.records.indexOf(d);
    if (i >= 0) {
      this.records.splice(i, 1);
    }
    return (d.selected = false);
  }
  remove(d) {
    this._remove(d);
    return this.notify();
  }

  update(d) {
    // Either adds or removes depending on presence
    const i = this.records.indexOf(d);
    if (i === -1) {
      this.records.push(d);
    } else {
      this.records.splice(i, 1);
    }
    return this.notify();
  }

  contains(d) {
    return this.records.indexOf(d) >= 0;
  }

  clear() {
    this.records = [];
    return this.notify();
  }

  _tagRemoved(name, opts) {
    if (opts == null) {
      opts = {};
    }
    const records = opts.records || this.records;
    records.forEach(function (d) {
      const i = d.tags.indexOf(name);
      if (i >= 0) {
        return d.tags.splice(i, 1);
      }
    });
    return this.trigger("tags-updated", this.getTags());
  }

  _tagAdded(name, opts) {
    // Adds tag to each record and
    // signals application that it is done
    if (opts == null) {
      opts = {};
    }
    const records = opts.records || this.records;
    records.forEach(function (d) {
      const i = d.tags.indexOf(name);
      if (i === -1) {
        return d.tags.push(name);
      }
    });
    return this.trigger("tags-updated", this.getTags());
  }
}
Selection.initClass();

module.exports = Selection;

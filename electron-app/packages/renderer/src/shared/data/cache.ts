/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
class CacheDatastore {
  constructor(name) {
    this.get = this.get.bind(this);
    this.set = this.set.bind(this);
    this.exists = this.exists.bind(this);
    this.name = name;
  }

  get() {
    const data = window.localStorage.getItem(this.name);
    return JSON.parse(data);
  }

  set(data) {
    const _ = JSON.stringify(data);
    return window.localStorage.setItem(this.name, _);
  }

  exists() {
    return this.get() != null;
  }
}

module.exports = CacheDatastore;

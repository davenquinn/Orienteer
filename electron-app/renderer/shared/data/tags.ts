/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const getTags = function (records) {
  const func = function (a, d) {
    Array.prototype.push.apply(a, d.tags);
    return a;
  };
  return records.reduce(func, []);
};

module.exports = {
  get: getTags,
  getUnique(records) {
    const tags = [];
    for (let d of Array.from(getTags(records))) {
      if (tags.indexOf(d) === -1) {
        tags.push(d);
      }
    }
    return tags;
  },
};

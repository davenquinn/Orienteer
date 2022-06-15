/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const d3 = require("d3");
require("d3-selection-multi");
const { functions } = require("attitude");
const style = require("./main.styl");

const opts = {
  degrees: true,
  traditionalLayout: false,
  n: 200,
  adaptive: false,
};

const drawPlanes = function (el, data) {
  const fn = functions.plane(opts);

  const planes = el.selectAll("g.plane").data(data, (d) => d.id);

  planes.enter().append("g").attr("class", "plane").each(fn);

  planes.exit().remove();

  el.selectAll(".error").classed(style.error, true);

  return el.selectAll(".nominal").classed(style.nominal, true);
};

const drawEllipses = function (el, data) {
  const ell = functions.errorEllipse(opts);

  const ell_ = data.map(ell);

  const mx = d3.max(ell_, (d) => d.area);

  const scale = d3.scalePow().domain([0, mx]).range([0.2, 0]).exponent(0.1);

  const sel = el.selectAll("path.ellipse").data(ell_);

  sel
    .enter()
    .append("path")
    .attr("class", `${style.ellipse} ellipse`)
    .attr("fill-opacity", 1); //(d)->scale(d.area)

  return sel.exit().remove();
};

module.exports = {
  planes: drawPlanes,
  ellipses: drawEllipses,
};

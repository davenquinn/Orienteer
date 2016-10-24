d3 = require 'd3'
require 'd3-selection-multi'
{functions} = require 'attitude'
style = require './main.styl'

opts = degrees: true, traditionalLayout: false, n:200, adaptive: false

drawPlanes = (el,data)->

  fn = functions.plane opts

  planes = el
    .selectAll 'g.plane'
    .data data, (d)->d.id

  planes.enter()
    .append 'g'
    .attr 'class','plane'
    .each fn

  planes.exit().remove()

  el.selectAll '.error'
    .attrs class: style.error

  el.selectAll '.nominal'
    .attrs class: style.nominal

drawEllipses = (el, data)->

  ell = functions.errorEllipse opts

  ell_ = data.map(ell)

  mx = d3.max ell_, (d)->d.area

  scale = d3.scalePow()
    .domain [0,mx]
    .range [0.2,0]
    .exponent 0.1

  sel = el.selectAll 'path.ellipse'
    .data ell_

  sel.enter()
    .append 'path'
    .attr 'class', "#{style.ellipse} ellipse"
    .attr 'fill-opacity', 1#(d)->scale(d.area)

  sel.exit().remove()

module.exports =
  planes: drawPlanes
  ellipses: drawEllipses

d3 = require 'd3'
require 'd3-selection-multi'
{functions} = require 'attitude'
style = require './main.styl'

opts = degrees: true, traditionalLayout: false, n:10

drawPlanes = (el,data)->

  fn = functions.plane opts

  con = el.append 'g'
    .attr 'class','planes'

  planes = con
    .selectAll 'g.plane'
    .data data

  planes.enter()
    .append 'g'
    .each fn

  con.selectAll '.error'
    .attrs class: style.error

  con.selectAll '.nominal'
    .attrs class: style.nominal

drawEllipses = (el, data)->

  con = el.append 'g'
    .attr 'class','ellipses'

  ell = functions.errorEllipse opts

  ell_ = data.map(ell)

  mx = d3.max ell_, (d)->d.properties.area

  scale = d3.scalePow()
    .domain [0,mx]
    .range [0.2,0]
    .exponent 0.1

  sel = con.selectAll 'path'
    .data ell_

  sel.enter()
    .append 'path'
    .attr 'class', style.ellipse
    .attr 'fill-opacity', (d)->scale(d.properties.area)

module.exports =
  planes: drawPlanes
  ellipses: drawEllipses

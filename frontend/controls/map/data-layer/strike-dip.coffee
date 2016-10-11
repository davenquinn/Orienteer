d3 = require 'd3'
# Class to create a strike-dip marker
module.exports = (d)->
  i = d3.select @
    .attrs class: "marker"

  i.append "line"
      .attrs
        x1: 0
        x2: 5
        y1: 0
        y2: 0
        stroke: "black"

  i.append "line"
    .attrs
      x1: 0
      x2: 0
      y1: -10
      y2: 10
      stroke: "black"

  i.append "text"
    .text d3.format(".0f")(d.properties.dip)
    .attrs
      class: "dip-magnitude"
      x: 10
      y: 0
      "text-anchor": "middle"
      transform: "rotate(#{-d.properties.strike} 10 0)"

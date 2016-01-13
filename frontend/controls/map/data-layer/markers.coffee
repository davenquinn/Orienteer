d3 = require "d3"

circleMarker = (sel, r)->
  sel
    .attr
        markerWidth: r
        markerHeight: r
        refX: r/2
        refY: r/2
    .append "circle"
        .attr
            class: 'circle-endpoint'
            cx: r/2
            cy: r/2
            r: r

arrowMarker = (sel)->
  sel
    .attr
        markerWidth: 13
        markerHeight: 13
        refX: 2
        refY: 6
        orient: "auto"
    .append "path"
        .attr
            class: 'arrow-endpoint'
            d: "M2,2 L2,11 L10,6 L2,2"

module.exports = (svg)->
  defs = svg.append("defs")
  defs.append("marker")
    .attr "id", "markerCircle"
    .call circleMarker, 3

  defs.append("marker")
    .attr "id", "markerArrow"
    .call arrowMarker

  defs.append("marker")
    .attr "id", "hoverArrow"
    .call arrowMarker

  defs.append("marker")
    .attr "id", "selectedArrow"
    .call arrowMarker

  defs.append("marker")
    .attr "id", "hoverCircle"
    .call circleMarker, 4

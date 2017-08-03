L = require "leaflet"

class BoxSelect extends L.Map.BoxZoom
  _onMouseUp: (e)->
    @_finish()
    return unless @_moved
    s = @_map.containerPointToLatLng @_startPoint
    e = @_map.containerPointToLatLng @_point

    bounds = new L.LatLngBounds s,e
    @_map.fire 'boxSelected', bounds: bounds

module.exports = BoxSelect

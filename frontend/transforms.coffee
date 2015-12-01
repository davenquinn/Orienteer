radians = (angle) -> angle*(Math.PI/180)
degrees = (angle) -> angle*(180/Math.PI)

a = 3396190
b = 3376200

factor = Math.pow(b/a,2)

module.exports =
    planetographic: (lat) ->
        lat = Math.tan(radians(lat))/factor
        degrees(Math.atan(lat))
    fudge: (lat) ->
        lat += .00741

class Feature
  hovered: false
  hidden: false
  selected: false
  group: null
  constructor: (o)->

    @grouped = o.type == 'group'
    @type = 'Feature'
    @geometry = o.geometry
    @id = o.id
    @measurements = o.measurements
    @tags = o.tags or []
    @properties =
      strike: o.strike
      dip: o.dip
      center: o.center
      axes: o.axes
      covariance: o.covariance
      n_samples: o.n_samples
      angular_errors: [
        o.min_angular_error
        o.max_angular_error
      ]

module.exports = Feature

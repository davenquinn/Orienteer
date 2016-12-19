module.exports = (o)->
  # Create a feature from a row object
  {
    grouped: o.type == 'group'
    type: 'Feature'
    geometry: o.geometry
    member_of: o.member_of
    id: o.id
    is_group: o.is_group
    in_group: o.in_group
    measurements: o.measurements
    tags: o.tags or []
    properties:
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
  }

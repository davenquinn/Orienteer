SELECT
  id,
  ST_Transform(geometry,949900) geometry,
  measurements,
  member_of,
  type,
  strike,
  dip,
  class,
  is_group,
  in_group,
  max_angular_error,
  min_angular_error,
  n_samples,
  ST_Transform(center,949900) center,
  principal_axes AS axes,
  tags,
  hyperbolic_axes
FROM
  attitude_data
WHERE correlation_coefficient < 1;

SELECT
  id,
  ST_Transform(geometry, 4326) geometry,
  measurements,
  member_of,
  type,
  strike,
  dip,
  rake,
  class,
  is_group,
  in_group,
  max_angular_error,
  min_angular_error,
  n_samples,
  ST_Transform(center, 4326) center,
  principal_axes AS axes,
  tags,
  hyperbolic_axes
FROM
  attitude_data
WHERE correlation_coefficient < 1;

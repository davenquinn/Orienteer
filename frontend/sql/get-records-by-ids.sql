SELECT
  id,
  geometry geometry,
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
  location center,
  principal_axes AS axes,
  tags,
  hyperbolic_axes
FROM
  attitude_data
WHERE correlation_coefficient < 1
  AND id IN (SELECT * FROM unnest($1::integer[]));

SELECT
  id,
  geometry geometry,
  measurements,
  type,
  strike,
  dip,
  max_angular_error,
  min_angular_error,
  n_samples,
  location center,
  principal_axes AS axes,
  tags,
  covariance
FROM
  attitude_data
WHERE
  correlation_coefficient < 1;

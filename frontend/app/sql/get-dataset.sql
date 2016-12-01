SELECT
  id,
  geometry geometry,
  measurements,
  type,
  strike,
  dip,
  max_angular_error,
  min_angular_error,
  location center,
  covariance
FROM
  attitude_data
WHERE
  correlation_coefficient < 1;

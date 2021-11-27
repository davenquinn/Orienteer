CREATE SCHEMA IF NOT EXISTS orienteer_api;

CREATE OR REPLACE VIEW attitude AS
SELECT
  id,
  ST_Transform(geometry, $GEOGRAPHIC_SRID) geometry,
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
  ST_Transform(center, $GEOGRAPHIC_SRID) center,
  principal_axes AS axes,
  tags,
  hyperbolic_axes
FROM
  orienteer.attitude_data
WHERE correlation_coefficient < 1;

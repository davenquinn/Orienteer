
DROP SCHEMA orienteer_api CASCADE;
CREATE SCHEMA orienteer_api;

CREATE VIEW orienteer_api.attitude AS
SELECT
  id,
  ST_Transform(geometry, :geographic_srid) geometry,
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
  ST_Transform(ST_Centroid(geometry), :geographic_srid) center,
  principal_axes AS axes,
  tags,
  hyperbolic_axes
FROM
  orienteer.attitude_data
WHERE correlation_coefficient < 1;

CREATE FUNCTION orienteer_api.project_bounds() RETURNS geometry AS $$
  SELECT 
    ST_Envelope(ST_Union(ST_Transform(geometry, :geographic_srid))) 
  FROM orienteer.dataset_feature;
$$ LANGUAGE SQL

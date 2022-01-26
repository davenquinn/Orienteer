
DROP SCHEMA orienteer_api CASCADE;
CREATE SCHEMA orienteer_api;

CREATE VIEW orienteer_api.feature_class AS
SELECT * FROM orienteer.feature_class;

-- Tags
CREATE VIEW orienteer_api.tag AS
SELECT * FROM orienteer.tag;

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
  color,
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
$$ LANGUAGE SQL;

/* Tags */
CREATE OR REPLACE FUNCTION orienteer_api.add_tag(
  tag text,
  attitudes integer[]
) RETURNS setof orienteer.attitude_tag AS $$
  WITH ins AS (
    INSERT INTO orienteer.tag (name)
    SELECT (tag::text)
    ON CONFLICT DO NOTHING
  )
  INSERT INTO orienteer.attitude_tag (attitude_id, tag_name)
  SELECT
    id,
    tag::text AS tag
  FROM unnest(attitudes::integer[]) AS id
  ON CONFLICT DO NOTHING
  RETURNING *;
$$ LANGUAGE SQL;


CREATE FUNCTION orienteer_api.remove_tag(
  tag text,
  attitudes integer[]
) RETURNS setof orienteer.attitude_tag AS $$
WITH q1 AS (
-- Delete from relationship table
  DELETE
  FROM orienteer.attitude_tag
  WHERE tag_name=tag::text
    AND attitude_id IN (SELECT * FROM unnest(attitudes::integer[]) AS a)
  RETURNING *
),
-- Delete tag from tag table if not represented in dataset
--   if we add any sort of persistent data to tags, it might
--   be good to revisit this subquery
q2 AS (
  DELETE FROM orienteer.tag
  WHERE name=tag::text
  AND (
    SELECT count(tag_name)
    FROM orienteer.attitude_tag
    WHERE tag_name=tag::text) = 0
)
-- Return results of first query
SELECT * FROM q1;
$$ LANGUAGE SQL;

/* If the API is running, make sure it is refreshed */
NOTIFY pgrst, 'reload schema';
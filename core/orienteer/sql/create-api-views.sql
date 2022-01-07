
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
$$ LANGUAGE SQL;

/* Tags */
CREATE FUNCTION orienteer_api.insert_tag(
  __tag text,
  __attitudes integer[]
) RETURNS orienteer.attitude_tag AS $$
  -- First add new tag if needed (to prevent bad foreign key
  --    relation)
  -- We could use upsert but then we'd be limited
  -- to PostgreSQL 9.5 or newer
  WITH ins AS (
    INSERT INTO orienteer.tag (name)
    SELECT (__tag::text)
    WHERE NOT EXISTS (
      SELECT name FROM orienteer.tag WHERE name=__tag::text)),
  -- Insert only tag-attitude relationships that aren't
  -- already in database
  a AS (
    SELECT
      id,
      __tag::text AS tag
    FROM unnest(__attitudes::integer[]) AS id)
  INSERT INTO orienteer.attitude_tag (tag_name, attitude_id)
  SELECT tag, id FROM a
  WHERE a.id NOT IN (
    SELECT attitude_id
    FROM orienteer.attitude_tag
    WHERE tag_name = __tag::text)
  RETURNING *;
$$ LANGUAGE SQL;

CREATE FUNCTION orienteer_api.remove_tag(
  __tag text,
  __attitudes integer[]
) RETURNS orienteer.attitude_tag AS $$
WITH q1 AS (
-- Delete from relationship table
  DELETE
  FROM orienteer.attitude_tag
  WHERE tag_name=__tag::text
    AND attitude_id IN (SELECT * FROM unnest(__attitudes::integer[]) AS a)
  RETURNING *),
-- Delete tag from tag table if not represented in dataset
--   if we add any sort of persistent data to tags, it might
--   be good to revisit this subquery
q2 AS (
  DELETE FROM orienteer.tag
  WHERE name=__tag::text
  AND (
    SELECT count(tag_name)
    FROM orienteer.attitude_tag
    WHERE tag_name=__tag::text) = 0)
-- Return results of first query
SELECT * FROM q1;
$$ LANGUAGE SQL;
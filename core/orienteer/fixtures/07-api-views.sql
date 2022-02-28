
DROP SCHEMA orienteer_api CASCADE;
CREATE SCHEMA orienteer_api;

CREATE VIEW orienteer_api.feature_class AS
SELECT * FROM orienteer.feature_class;

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
CREATE VIEW orienteer_api.tag AS
SELECT * FROM orienteer.tag;

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

CREATE VIEW orienteer_api.feature_trace AS
SELECT
  id,
  ST_Transform(geometry, :geographic_srid) geometry,
  class,
  color,
  tags
FROM
  orienteer.attitude_data
WHERE correlation_coefficient < 1;



CREATE OR REPLACE FUNCTION
  imagery.tile_envelope(
    _x integer,
    _y integer,
    _z integer,
    _tms text = 'mars_mercator'
  ) RETURNS geometry(Polygon, 949900)
AS $$
  SELECT ST_Transform(
    ST_TileEnvelope(
      _z, _x, _y,
      (SELECT bounds FROM imagery.tms WHERE name = _tms)
    ),
    949900
  );
$$ LANGUAGE SQL STABLE;

/* A function to create vector tiles that doesn't require a separate tile server.
  This could be upgraded to pg_tileserv eventually.
 */
CREATE OR REPLACE FUNCTION orienteer_api.vector_tile(
  x integer,
  y integer,
  z integer
) RETURNS bytea AS $$
  WITH tile_loc AS (
    SELECT tile_utils.envelope(x, y, z, 'mars_mercator') envelope 
  ),
  features AS (
    -- Features in tile envelope
    SELECT * FROM orienteer.attitude_data, tile_loc
    WHERE geometry && tile_loc.envelope
      AND (ST_XMax(geometry)-ST_XMin(geometry)) > tile_utils.tile_width(z)/1024
  ), trace AS (
    SELECT
      id,
      ST_AsMVTGeom(
        ST_Simplify(geometry, tile_utils.tile_width(z)/1024),
        tile_loc.envelope
      ) AS geom,
      class,
      color,
      tags
    FROM features, tile_loc
  ), orientation AS (
    SELECT
      id,
      ST_AsMVTGeom(center, tile_loc.envelope) AS geom,
      class,
      color,
      tags
    FROM features, tile_loc
  )
  -- Concat the layers together...
  SELECT ST_AsMVT(trace, 'trace') || ST_AsMVT(orientation, 'orientation')
  FROM trace, orientation;
$$ LANGUAGE SQL STABLE;

NOTIFY pgrst, 'reload schema';
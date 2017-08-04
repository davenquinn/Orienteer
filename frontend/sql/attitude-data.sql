CREATE OR REPLACE VIEW attitude_data AS
  WITH tagged AS (
    -- Aggregate tags
    SELECT
      t.attitude_id fid,
      array_agg(t.tag_name) AS tags
    FROM attitude_tag t
    GROUP BY fid),
  a AS (
    -- Basic selection for join
    -- between features and attitudes
    SELECT
      geometry,
      feature_id,
      class,
      a.id,
      a.member_of
    FROM attitude a
    JOIN dataset_feature f
      ON a.feature_id = f.id),
  b AS (
    -- Get geometry from features
    -- (both single and grouped)
    SELECT
      member_of id,
      null AS feature_id,
      CASE WHEN every(class IS NOT null) THEN min(class)
      ELSE null END AS class,
      st_union(geometry) AS geometry,
      array_agg(id) AS measurements
    FROM a
    -- Select only single attitudes that
    -- are part of a group
    WHERE feature_id IS NOT null
      AND member_of IS NOT null
    GROUP BY member_of
    UNION ALL
    -- Add data from single attitudes
    SELECT
      id,
      feature_id,
      class,
      geometry,
      null as measurements
    FROM a
    WHERE feature_id IS NOT null)
  SELECT
    a.id,
    b.feature_id,
    b.geometry,
    b.measurements,
    b.class,
    a.type,
    a.strike,
    a.dip,
    a.correlation_coefficient,
    a.max_angular_error,
    a.min_angular_error,
    a.n_samples,
    a.member_of,
    tagged.tags,
    ST_Centroid(b.geometry) AS location,
    a.principal_axes,
    a.hyperbolic_axes,
    (b.feature_id IS null) AS is_group,
    (a.member_of IS NOT null) AS in_group
  FROM attitude a
    RIGHT JOIN b ON a.id = b.id
    LEFT JOIN tagged ON a.id = tagged.fid



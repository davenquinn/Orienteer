CREATE OR REPLACE VIEW orienteer.attitude_data AS
  WITH tagged AS (
    -- Aggregate tags
    SELECT
      t.attitude_id fid,
      array_agg(t.tag_name) AS tags
    FROM orienteer.attitude_tag t
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
    FROM orienteer.attitude a
    JOIN orienteer.dataset_feature f
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
    WHERE feature_id IS NOT null
  ),
  /* Get dataset and instrument for each measurement
     on the assumption that all grouped measurements are
     from the same dataset and instrument (null is returned
     otherwise).
  */
  ia AS (
    SELECT
      a.id,
      a.member_of,
      dataset_id dataset,
      instrument
    FROM orienteer.attitude a
    LEFT JOIN orienteer.dataset_feature f ON a.feature_id = f.id
    LEFT JOIN orienteer.dataset d ON f.dataset_id = d.id
  ),
  paired_instruments AS (
    SELECT
      a1.member_of id,
      array_agg(a1.dataset) dataset,
      array_agg(a1.instrument) inst
    FROM ia a1
    LEFT JOIN ia a2
      ON a1.member_of = a2.id
    WHERE a1.member_of IS NOT null
    GROUP BY a1.member_of
  ),
  instrument_attitude AS (
    SELECT
      id,
      CASE WHEN dataset[1] = ALL(dataset)
      THEN dataset[1]
      ELSE NULL
      END AS dataset,
      CASE WHEN inst[1] = ALL(inst)
      THEN inst[1]
      ELSE NULL
      END AS instrument
    FROM paired_instruments
    UNION ALL
    SELECT id,dataset,instrument FROM ia
    WHERE dataset IS NOT null
  )
  SELECT
    a.id,
    b.feature_id,
    b.geometry,
    b.measurements,
    b.class,
    a.type,
    a.strike,
    a.dip,
    a.rake,
    a.correlation_coefficient,
    a.max_angular_error,
    a.min_angular_error,
    a.n_samples,
    a.member_of,
    tagged.tags,
    a.center,
    a.principal_axes,
    a.hyperbolic_axes,
    (b.feature_id IS null) AS is_group,
    (a.member_of IS NOT null) AS in_group,
    dataset,
    instrument
  FROM orienteer.attitude a
  RIGHT JOIN b ON a.id = b.id
  LEFT JOIN tagged ON a.id = tagged.fid
  LEFT JOIN instrument_attitude ia
         ON a.id = ia.id


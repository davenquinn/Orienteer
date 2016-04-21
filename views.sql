CREATE OR REPLACE VIEW attitude_data AS
  WITH
    attitude_data AS (
      SELECT
      	a.*,
      	f.geometry
      FROM attitude a
      JOIN dataset_feature f
      ON a.id = f.id),
    group_location AS (
      SELECT
        a.group_id,
        array_agg(a.id) measurements,
        ST_Union(a.geometry) geometry
      FROM attitude_data a
      WHERE a.group_id IS NOT NULL
      GROUP BY a.group_id),
    group_data AS (
      SELECT
        -group_id id,
        geometry,
        ST_Centroid(geometry) AS location,
        strike,
        dip,
        same_plane,
        measurements
      FROM group_location l
      JOIN attitude_group g ON g.id = l.group_id)
  SELECT
  	id,
  	geometry,
  	location,
  	strike,
  	dip,
  	null AS same_plane,
  	null AS measurements
  FROM attitude_data
  WHERE group_id IS NULL
  UNION
  SELECT * FROM group_data;

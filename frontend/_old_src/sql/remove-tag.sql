WITH q1 AS (
-- Delete from relationship table
  DELETE
  FROM attitude_tag
  WHERE tag_name=$1::text
    AND attitude_id IN (SELECT * FROM unnest($2::integer[]) AS a)
  RETURNING *),
-- Delete tag from tag table if not represented in dataset
--   if we add any sort of persistent data to tags, it might
--   be good to revisit this subquery
q2 AS (
  DELETE FROM tag
  WHERE name=$1::text
  AND (
    SELECT count(tag_name)
    FROM attitude_tag
    WHERE tag_name=$1::text) = 0)
-- Return results of first query
SELECT * FROM q1;

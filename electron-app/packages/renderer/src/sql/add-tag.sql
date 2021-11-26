-- First add new tag if needed (to prevent bad foreign key
--    relation)
-- We could use upsert but then we'd be limited
-- to PostgreSQL 9.5 or newer
WITH ins AS (
  INSERT INTO tag (name)
  SELECT ($1::text)
  WHERE NOT EXISTS (
    SELECT name FROM tag WHERE name=$1::text)),
-- Insert only tag-attitude relationships that aren't
-- already in database
a AS (
  SELECT
    id,
    $1::text AS tag
  FROM unnest($2::integer[]) AS id)
INSERT INTO attitude_tag (tag_name, attitude_id)
SELECT tag, id FROM a
WHERE a.id NOT IN (
  SELECT attitude_id
  FROM attitude_tag
  WHERE tag_name = $1::text)
RETURNING *;

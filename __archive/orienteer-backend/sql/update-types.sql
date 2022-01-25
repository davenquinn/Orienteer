WITH b AS (
  SELECT $2::integer[] AS arr)
UPDATE dataset_feature f
SET
  class=NULLIF($1::text,'null')
FROM attitude a, b
WHERE (a.member_of=ANY(b.arr) OR a.id=ANY(b.arr))
  AND a.feature_id = f.id
RETURNING *

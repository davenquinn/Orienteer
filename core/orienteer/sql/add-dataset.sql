-- Adds dataset for dataset_feature based on overlap
-- If you don't want this to be autoset, set it on feature
--  creation
WITH d AS (
SELECT
  id,
  footprint,
  ST_Area(footprint) area
FROM orienteer.dataset
),
fd AS (
SELECT DISTINCT ON (f.id)
  f.id feature_id,
  d.id dataset_id
FROM orienteer.dataset_feature f
JOIN d ON ST_Contains(
  d.footprint,
  ST_Transform(f.geometry, ST_SRID(d.footprint))
)
WHERE f.dataset_id IS null
ORDER BY f.id, d.area
)
UPDATE orienteer.dataset_feature
SET
  dataset_id=fd.dataset_id,
  dataset_id_autoset=true
FROM fd
WHERE id=fd.feature_id;

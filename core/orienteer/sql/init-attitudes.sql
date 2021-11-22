INSERT INTO orienteer.attitude
  (feature_id, "type")
SELECT
  f.id,
  'single'
FROM orienteer.dataset_feature f
LEFT OUTER JOIN orienteer.attitude a ON a.feature_id = f.id
WHERE f.type = 'Attitude'
  AND a.id IS NULL

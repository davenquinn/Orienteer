INSERT INTO attitude
  (feature_id)
SELECT
  f.id
FROM dataset_feature f
LEFT OUTER JOIN attitude a ON a.feature_id = f.id
WHERE f.type = 'Attitude'
  AND a.id IS NULL

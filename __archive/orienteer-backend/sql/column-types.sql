SELECT
  column_name,
  data_type,
  udt_name udt
FROM information_schema.columns
WHERE table_name='attitude_data'

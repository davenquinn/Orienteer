ALTER TABLE orienteer.dataset_feature
ADD COLUMN source_polygon integer
REFERENCES map_data.polygon(id)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE orienteer.dataset_feature
ADD COLUMN source_line integer
REFERENCES map_data.linework(id)
ON DELETE CASCADE
ON UPDATE CASCADE;
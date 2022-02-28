ALTER TABLE orienteer.project
ADD FOREIGN KEY (srid) REFERENCES spatial_ref_sys(srid);
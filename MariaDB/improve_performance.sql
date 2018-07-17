ALTER TABLE regioncentercoordinateslist ADD INDEX idx_region_name (RegionName);
ALTER TABLE parentregionlist ADD INDEX idx_region_name (RegionName);
ALTER TABLE parentregionlist ADD INDEX idx_region_type_region_name (RegionType, RegionName);
ALTER TABLE trainmetrostationcoordinateslist ADD INDEX idx_region_name (RegionName);
